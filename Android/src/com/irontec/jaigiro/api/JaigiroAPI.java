package com.irontec.jaigiro.api;

import java.io.IOException;
import android.provider.Settings.Secure;
import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.os.AsyncTask;
import android.os.Handler;
import android.preference.PreferenceManager;
import android.util.Log;
import android.widget.EditText;

import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.loopj.android.http.AsyncHttpClient;
import com.loopj.android.http.AsyncHttpResponseHandler;
import com.loopj.android.http.RequestParams;

public class JaigiroAPI {

	private static final String TAG = JaigiroAPI.class.getSimpleName();
	protected static final String SENDER_ID = "GCM_SENDER_ID";
	private static final String TW_ID = "jaigiro_tw_id";
	private static final String FB_ID = "jaigiro_fb_id";
	private static final String USER_IMAGE = "jaigiro_user_image";
	private static final String USER_NAME = "jaigiro_user_name";
	private static final String GCM_REGID = "jaigiro_api_gcm_regid";
	private static final String IS_GCM_REGISTERED = "jaigiro_api_isgcm_registered";

	private static final String BASE_URL = "http://jaigiro.net/kontrola/";
	private static final String TYPE = "api/";
	
	public static final String GET_JAIAK = "get-jaiak";
	public static final String GET_JAIAK_COORDS = "get-jaiak-by-coords";
	public static final String GET_PLACES_WITH_PARTIES = "get-jaien-herriak-by-coords";
	public static final String GET_PARTIES_FROM_PLACE = "get-herriko-jaiak";
	public static final String GET_EVENTS_BY_PARTY = "get-ekintzak-by-jaiak";
	public static final String SEARCH = "search-jaiak";
	public static final String IM_GOING = "banator";
	public static final String PROPOSE = "new-sugerentzia";
	public static final String PROPOSE_EVENT = "new-ekintza-sugerentzia";
	public static final String WIDGET_PARTIES = "get-next-banator";
	
	public static final Integer ERROR_TOKEN_EXPIRED = -10;
	public static final Integer ERROR_REGISTERED_EMAIL = -600;
	public static final Integer ERROR_REGISTERED_USER = -601;
	public static final Integer ERROR_PASSWORD_TOO_SHORT = -602;
	public static final Integer ERROR_CHECKIN_TIME = -202;
	public static final Integer ERROR_INVALID_RESET_PASSWORD_EMAIL = -801;
	public static final Integer ERROR_MALFORMED_EMAIL = -800;
	public static final Integer ERROR_BAD_PARAMS = -1001;
	public static final Integer ERROR_DUPLICATED_PLACE = -666;

	private static SharedPreferences mPreferences;
	private static Editor mEditor;

	private static String suuid;

	private static AsyncHttpClient client = new AsyncHttpClient();


	public static void get(String url, RequestParams params, AsyncHttpResponseHandler responseHandler) {
		client.get(getAbsoluteUrl(url), params, responseHandler);
	}

	public static void post(String url, RequestParams params, AsyncHttpResponseHandler responseHandler) {
		client.post(getAbsoluteUrl(url), params, responseHandler);
	}

	public static String getAbsoluteUrl(String relativeUrl) {
		Log.d(TAG, BASE_URL + TYPE + relativeUrl);
		return BASE_URL + TYPE + relativeUrl;
	}

	public static Long getIdFacebook(Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		return mPreferences.getLong(FB_ID, 0);
	}

	public static void setIdFacebook(Long idFacebook, String name, String imageUrl, Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		mEditor = mPreferences.edit();
		mEditor.putLong(FB_ID, idFacebook);
		mEditor.putString(USER_IMAGE, imageUrl);
		mEditor.putString(USER_NAME, name);
		mEditor.commit();
	}

	public static void setIdTwitter(Long idTwitter, String name, String imageUrl, Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		mEditor = mPreferences.edit();
		mEditor.putLong(TW_ID, idTwitter);
		mEditor.putString(USER_IMAGE, imageUrl);
		mEditor.putString(USER_NAME, name);
		mEditor.commit();
	}

	public static Long getIdTwitter(Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		return mPreferences.getLong(TW_ID, 0);
	}
	
	public static String getUserImage(Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		return mPreferences.getString(USER_IMAGE, null);
	}
	
	public static void clearUserImage(Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		mEditor = mPreferences.edit();
		mEditor.putString(USER_IMAGE, null);
		mEditor.commit();
	}
	
	public static String getUserName(Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		return mPreferences.getString(USER_NAME, null);
	}

	public static void setGCMRegid(Context context, String regId) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		mEditor = mPreferences.edit();
		mEditor.putString(GCM_REGID, regId);
		mEditor.commit();
	}

	public static String getGCMRegid(Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		return mPreferences.getString(GCM_REGID, null);
	}

	public static void clear(Context context) {
		mPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		mEditor = mPreferences.edit();
		mEditor.remove(FB_ID);
		mEditor.remove(TW_ID);
		mEditor.commit();
	}

	@SuppressWarnings({ "unchecked", "rawtypes" })
	public static void registerGCM(final Activity activity, final Handler handler) {
		new AsyncTask() {
			@Override
			protected Object doInBackground(Object... params) {
				GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(activity);

				String android_id = Secure.getString(activity.getContentResolver(), Secure.ANDROID_ID); 
				String regId = android_id;
				try {
					regId += gcm.register(SENDER_ID);
				} catch (IOException e) {
				}
				setGCMRegid(activity.getBaseContext(), regId);
				handler.sendEmptyMessage(0);
				return null;
			}
		}.execute(null, null, null);
	}
}