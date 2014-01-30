package com.irontec.jaigiro.helpers;

import java.net.URLEncoder;
import java.util.ArrayList;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.preference.PreferenceManager;
import android.util.Log;

import com.irontec.jaigiro.R;
import com.sromku.simple.fb.Permissions;
import com.sromku.simple.fb.SimpleFacebook;
import com.sromku.simple.fb.SimpleFacebook.OnProfileRequestListener;
import com.sromku.simple.fb.SimpleFacebook.OnPublishListener;
import com.sromku.simple.fb.SimpleFacebookConfiguration;
import com.sromku.simple.fb.entities.Feed;

public class FacebookHelper {
	
	protected static final String TAG = FacebookHelper.class.getSimpleName();
	public static String APP_ID = "FACEBOOK_APP_ID";
	public static String ACCESS_TOKEN = "access_token";
	public static Editor mEditor;
	private static SimpleFacebook mSimpleFacebook;
	
	private static SharedPreferences mSharedPreferences;
	static Permissions[] permissions = new Permissions[] {
			Permissions.BASIC_INFO,
			Permissions.PUBLISH_ACTION
	};
	
	public static boolean isConnected(Activity activity) {
		if (mSimpleFacebook == null) {
			mSimpleFacebook = getSimpleFacebookInstance(activity);
		}
		return mSimpleFacebook.isLogin();
	}
	
	public static SimpleFacebook getSimpleFacebookInstance(Activity activity) {
		if (mSimpleFacebook == null) {
			SimpleFacebookConfiguration configuration = new SimpleFacebookConfiguration.Builder()
			.setAppId(APP_ID)
			.setPermissions(permissions)
			.build();
			
			mSimpleFacebook = SimpleFacebook.getInstance(activity);
			mSimpleFacebook.setConfiguration(configuration);
			return mSimpleFacebook;
		} else {
			return mSimpleFacebook;
		}
	}
	
	public static void setFacebookAccessToken(Context context, SimpleFacebook mSimpleFacebook) {
		mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
    	mEditor = mSharedPreferences.edit();
    	mEditor.putString(ACCESS_TOKEN, mSimpleFacebook.getAccessToken());
    	mEditor.commit();
	}
	
	public static void disconnectFacebook(Context context) {
		mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		mEditor = mSharedPreferences.edit();
		mEditor.remove(ACCESS_TOKEN);
		mEditor.commit();
	}
	
	public static void publishFeed(Activity activity) {
		OnPublishListener onPublishListener = new SimpleFacebook.OnPublishListener()
		{

		    @Override
		    public void onFail(String reason) {
		    	
		    }

		    @Override
		    public void onException(Throwable throwable) {
		    	
		    }

		    @Override
		    public void onThinking() {}

		    @Override
		    public void onComplete(String postId) {
		    	
		    }
		};

		String caption = "";
		String description = "";
		Feed feed = null;
		feed = new Feed.Builder()
	    .setMessage("")
	    .setName("")
	    .setCaption(caption)
	    .setDescription(description)
	    .setPicture("")
	    .setLink(caption)
	    .build();
		
		if (feed != null) {
			if (mSimpleFacebook == null) {
				mSimpleFacebook = getSimpleFacebookInstance(activity);
			}
			mSimpleFacebook.publish(feed, onPublishListener);
		}
		
	}

}
