package com.irontec.jaigiro.mobhawk;

import java.io.BufferedInputStream;
import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStream;
import java.io.InputStreamReader;
import java.net.URL;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;
import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

import org.json.JSONException;
import org.json.JSONObject;

import com.irontec.jaigiro.R;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.pm.PackageManager.NameNotFoundException;
import android.net.Uri;
import android.os.AsyncTask;
import android.os.Handler;

public class MobHawk {

	private static MobHawk instance;

	private Activity mActivity;

	private Integer mVersionCode = -1;

	private final static int STATUS_UPDATE_NEEDED_AND_BLOCKED = 1;
	private final static int STATUS_UPDATE_NEEDED = 2;

	private final static int CASTELLANO = 0;
	private final static int INGLES = 1;
	private final static int EUSKERA = 2;
	private final static int CATALAN = 3;

	private AlertDialog.Builder mDialogBuilder;
	private AlertDialog mDialog;

	private Boolean mUpdate = false;
	private Boolean mSilence = false;
	private Boolean mMustBlock = false;
	private Messages mMessages = new Messages();
	
	private String mAppPackageName;

	private Handler mHandler;

	private class Messages {
		public String es;
		public String en;
		public String eu;
		public String ca;
	}

	public static MobHawk getInstance() {
		if (instance == null) {
			instance = new MobHawk();
		}
		return instance;
	}

	private MobHawk() {}

	public void setActivity(Activity activity) {
		this.mActivity = activity;
		this.mAppPackageName = activity.getPackageName();
	}

	public void call(String app, String version, Handler handler) {
		this.mHandler = handler;
		new MobHawkCheck().execute(app,version);
	}

	private class MobHawkCheck extends AsyncTask<String, Void, JSONObject> {

		protected JSONObject doInBackground(String... params) {
			JSONObject json = null;
			try {
				// Load CAs from an InputStream
				// (could be from a resource or ByteArrayInputStream or ...)
				CertificateFactory cf = CertificateFactory.getInstance("X.509");
				// From https://www.washington.edu/itconnect/security/ca/load-der.crt
				InputStream cert = mActivity.getResources().openRawResource(R.raw.mobhawk);
				InputStream caInput = new BufferedInputStream(cert);
				Certificate ca;
				try {
					ca = cf.generateCertificate(caInput);
					System.out.println("ca=" + ((X509Certificate) ca).getSubjectDN());
				} finally {
					caInput.close();
				}
				// Create a KeyStore containing our trusted CAs
				String keyStoreType = KeyStore.getDefaultType();
				KeyStore keyStore = KeyStore.getInstance(keyStoreType);
				keyStore.load(null, null);
				keyStore.setCertificateEntry("ca", ca);

				// Create a TrustManager that trusts the CAs in our KeyStore
				String tmfAlgorithm = TrustManagerFactory.getDefaultAlgorithm();
				TrustManagerFactory tmf = TrustManagerFactory.getInstance(tmfAlgorithm);
				tmf.init(keyStore);

				// Create an SSLContext that uses our TrustManager
				SSLContext context = SSLContext.getInstance("TLS");
				context.init(null, tmf.getTrustManagers(), null);

				// Tell the URLConnection to use a SocketFactory from our SSLContext
				URL url = new URL("https://mob-hawk.irontec.com/check?app=" + params[0] +"&version=" + params[1]);
				HttpsURLConnection urlConnection =
						(HttpsURLConnection)url.openConnection();
				urlConnection.setSSLSocketFactory(context.getSocketFactory());

				BufferedReader r = new BufferedReader(new InputStreamReader(urlConnection.getInputStream()));
				StringBuilder total = new StringBuilder();
				String line;
				while ((line = r.readLine()) != null) {
					total.append(line);
				}
				json = new JSONObject(total.toString());
			} catch (IOException e) {
				e.printStackTrace();
			} catch (JSONException e) {
				e.printStackTrace();
			} catch (KeyManagementException e) {
				e.printStackTrace();
			} catch (NoSuchAlgorithmException e) {
				e.printStackTrace();
			} catch (KeyStoreException e) {
				e.printStackTrace();
			} catch (CertificateException e) {
				e.printStackTrace();
			}
			return json;
		}

		protected void onPostExecute(JSONObject result) {
			parseResponse(result);
			mHandler.sendEmptyMessage(0);
		}
	}

	public static Integer getAppVersionCode(Activity activity) throws NameNotFoundException {
		return activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionCode;
	}

	public static String getAppVersionName(Activity activity) throws NameNotFoundException {
		return activity.getPackageManager().getPackageInfo(activity.getPackageName(), 0).versionName;
	}

	public Boolean isBlocked() {
		return mMustBlock;
	}

	public void parseResponse(JSONObject response) {
		try {
			if (response.has("update"))
				mUpdate = response.getBoolean("update");
			
			if (response.has("silence"))
				mSilence = response.getBoolean("silence");
			
			if (response.has("mustBlock"))
				mMustBlock = response.getBoolean("mustBlock");
			
			if (!mSilence && response.has("silence")) {
				JSONObject jsonMessages = response.getJSONObject("messages");
				mMessages.es = jsonMessages.getString("es");
				mMessages.en = jsonMessages.getString("en");
				mMessages.eu = jsonMessages.getString("eu");
				mMessages.ca = jsonMessages.getString("ca");
			}
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	public void takeActions() {

		if (mSilence) {return;} // If silence then nothing happens
		if (mUpdate && mMustBlock) {
			riseAlarm(STATUS_UPDATE_NEEDED_AND_BLOCKED); // Needs to be updated and will be blocked
		} else if (mUpdate) {
			riseAlarm(STATUS_UPDATE_NEEDED); // Needs to be updated
		}
	}

	private void riseAlarm(int status) {
		mDialogBuilder = new AlertDialog.Builder(mActivity);
		mDialogBuilder.setMessage(mMessages.es);
		mDialogBuilder.setCancelable(false);
		mDialogBuilder.setPositiveButton("Ok", new DialogInterface.OnClickListener() {
			public void onClick(DialogInterface dialog, int id) {
				accept();
			}
		});
		mDialogBuilder.setNegativeButton("Google Play Store", new DialogInterface.OnClickListener() {
			@Override
			public void onClick(DialogInterface dialog, int which) {
				try {
				    mActivity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("market://details?id=" + mAppPackageName)));
				} catch (android.content.ActivityNotFoundException anfe) {
					mActivity.startActivity(new Intent(Intent.ACTION_VIEW, Uri.parse("http://play.google.com/store/apps/details?id=" + mAppPackageName)));
				}
			}
		});
		mDialog = mDialogBuilder.create();
		mDialog.show();
	}

	private void accept() {
		mDialog.cancel();
	}

}
