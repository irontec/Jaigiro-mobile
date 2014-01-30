package com.irontec.jaigiro.services;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.ExecutionException;

import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.ClientProtocolException;
import org.apache.http.client.HttpClient;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.app.Service;
import android.appwidget.AppWidgetManager;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.IBinder;
import android.util.Log;

import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.models.Festa;
import com.irontec.jaigiro.providers.WidgetProvider;

public class RemoteFetchService extends Service {

	private static final String TAG = RemoteFetchService.class.getSimpleName();
	private int appWidgetId = AppWidgetManager.INVALID_APPWIDGET_ID;

	public static ArrayList<Festa> listItemList;

	@Override
	public IBinder onBind(Intent arg0) {
		return null;
	}

	/*
	 * Retrieve appwidget id from intent it is needed to update widget later
	 * initialize our AQuery class
	 */
	@Override
	public int onStartCommand(Intent intent, int flags, int startId) {
		if (intent.hasExtra(AppWidgetManager.EXTRA_APPWIDGET_ID))
			appWidgetId = intent.getIntExtra(
					AppWidgetManager.EXTRA_APPWIDGET_ID,
					AppWidgetManager.INVALID_APPWIDGET_ID);
		fetchDataFromWeb();
		return super.onStartCommand(intent, flags, startId);
	}

	/**
	 * method which fetches data(json) from web aquery takes params
	 * remoteJsonUrl = from where data to be fetched String.class = return
	 * format of data once fetched i.e. in which format the fetched data be
	 * returned AjaxCallback = class to notify with data once it is fetched
	 */
	private void fetchDataFromWeb() {
		Log.d(TAG, "FETCHING");
		String result = null;
		try {
			result = new WidgetDataTask().execute().get();
		} catch (InterruptedException e) {
			e.printStackTrace();
		} catch (ExecutionException e) {
			e.printStackTrace();
		}
		Log.d(TAG, "RESULT");
		Log.d(TAG, result);
		processResult(result);
	}

	private class WidgetDataTask extends AsyncTask<Void, Void, String> {

		protected String doInBackground(Void... params) {
			HttpClient httpclient = new DefaultHttpClient();
			HttpPost httppost = new HttpPost(JaigiroAPI.getAbsoluteUrl(JaigiroAPI.WIDGET_PARTIES));
			HttpResponse response;
			String result = null;
			try {
				List<NameValuePair> nameValuePairs = new ArrayList<NameValuePair>(2);
				nameValuePairs.add(new BasicNameValuePair("uuid", JaigiroAPI.getGCMRegid(getBaseContext())));
				nameValuePairs.add(new BasicNameValuePair("device", "android"));
				httppost.setEntity(new UrlEncodedFormEntity(nameValuePairs));
				response = httpclient.execute(httppost);
				result = EntityUtils.toString(response.getEntity());
			} catch (ClientProtocolException e) {
				e.printStackTrace();
			} catch (IOException e) {
				e.printStackTrace();
			}
			return result;
		}
	}

	/**
	 * Json parsing of result and populating ArrayList<ListItem> as per json
	 * data retrieved from the string
	 */
	private void processResult(String result) {
		Log.i("Resutl",result);
		listItemList = new ArrayList<Festa>();
		try {
			JSONObject response = new JSONObject(result);
			JSONArray festak = response.getJSONArray("jaiak");
			if (festak.length() > 0 ) {
				for (int i = 0; i < festak.length(); i++) {
					Festa festa = new Festa(festak.getJSONObject(i));
					listItemList.add(festa);
				}
			}
		} catch (JSONException e) {
			e.printStackTrace();
		}
		populateWidget();
	}

	/**
	 * Method which sends broadcast to WidgetProvider
	 * so that widget is notified to do necessary action
	 * and here action == WidgetProvider.DATA_FETCHED
	 */
	private void populateWidget() {
		Log.d(TAG, "POPULATING WIDGET");
		Intent widgetUpdateIntent = new Intent();
		widgetUpdateIntent.setAction(WidgetProvider.DATA_FETCHED);
		widgetUpdateIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
		sendBroadcast(widgetUpdateIntent);

		this.stopSelf();
	}
}
