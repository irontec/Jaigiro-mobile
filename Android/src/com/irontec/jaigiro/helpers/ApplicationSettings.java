package com.irontec.jaigiro.helpers;

import java.util.Calendar;

import com.sromku.simple.fb.SimpleFacebook;

import android.content.Context;
import android.content.SharedPreferences;
import android.content.SharedPreferences.Editor;
import android.preference.PreferenceManager;

public class ApplicationSettings {

	private static SharedPreferences mSharedPreferences;
	private static String IS_GUEST_MODE = "jaigiro_is_guest_mode";
	private static String SEARCH_MAX_DISTANCE = "jaigiro_search_max_distance";
	private static String SEARCH_MAX_DATE = "jaigiro_search_max_date";
	public static Editor mEditor;
	
	public static void setIsGuestMode(Context context, Boolean state) {
		mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
    	mEditor = mSharedPreferences.edit();
    	mEditor.putBoolean(IS_GUEST_MODE, state);
    	mEditor.commit();
	}
	
	public static boolean isGuestMode(Context context) {
		mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		return mSharedPreferences.getBoolean(IS_GUEST_MODE, false);
	}
	
	public static void setMaxSearchDistance(Context context, Long distance) {
		mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
    	mEditor = mSharedPreferences.edit();
    	mEditor.putLong(SEARCH_MAX_DISTANCE, distance);
    	mEditor.commit();
	}
	
	public static Long getMaxSearchDistance(Context context) {
		mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		return mSharedPreferences.getLong(SEARCH_MAX_DISTANCE, 50);
	}
	
	public static void setMaxSearchDate(Context context, Long time) {
		mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
    	mEditor = mSharedPreferences.edit();
    	mEditor.putLong(SEARCH_MAX_DATE, time);
    	mEditor.commit();
	}
	
	public static Long getMaxSearchDate(Context context) {
		Calendar date = Calendar.getInstance();  
		date.add( Calendar.YEAR, 1 );
		mSharedPreferences = PreferenceManager.getDefaultSharedPreferences(context);
		return mSharedPreferences.getLong(SEARCH_MAX_DATE, date.getTimeInMillis());
	}
	
}
