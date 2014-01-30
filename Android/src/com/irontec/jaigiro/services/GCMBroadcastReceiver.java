package com.irontec.jaigiro.services;

import org.json.JSONException;
import org.json.JSONObject;

import android.app.Activity;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.google.android.gms.gcm.GoogleCloudMessaging;
import com.irontec.jaigiro.MainActivity;
import com.irontec.jaigiro.R;

public class GCMBroadcastReceiver extends BroadcastReceiver {

	static final String TAG = GCMBroadcastReceiver.class.getSimpleName();
	public static final int NOTIFICATION_ID = 1;

	private NotificationManager mNotificationManager;
	NotificationCompat.Builder builder;
	Context ctx;


	@Override
	public void onReceive(Context context, Intent intent) {
		GoogleCloudMessaging gcm = GoogleCloudMessaging.getInstance(context);
		ctx = context;
		String messageType = gcm.getMessageType(intent);
		if (GoogleCloudMessaging.MESSAGE_TYPE_SEND_ERROR.equals(messageType)) {
			sendNotification(intent.getExtras(), "Send error");
		} else if (GoogleCloudMessaging.MESSAGE_TYPE_DELETED.equals(messageType)) {
			sendNotification(intent.getExtras(), "Deleted messages on server");
		} else {
			sendNotification(intent.getExtras(), "Received");
		}
		setResultCode(Activity.RESULT_OK);
	}

	// Put the GCM message into a notification and post it.
	private void sendNotification(Bundle extras, String string) {

		mNotificationManager = (NotificationManager)
				ctx.getSystemService(Context.NOTIFICATION_SERVICE);
		String msg = extras.getString("msg");

		Intent selectedIntent = new Intent(ctx.getApplicationContext(), MainActivity.class);

		PendingIntent content = PendingIntent.getActivity(ctx.getApplicationContext(), 0, selectedIntent, PendingIntent.FLAG_UPDATE_CURRENT);

		NotificationCompat.Builder mBuilder =
				new NotificationCompat.Builder(ctx)
		.setSmallIcon(R.drawable.ic_launcher)
		.setContentTitle(ctx.getResources().getString(R.string.app_name))
		.setStyle(new NotificationCompat.BigTextStyle()
		.bigText(msg))
		.setContentText(msg);

		mBuilder.setContentIntent(content);
		mNotificationManager.notify(NOTIFICATION_ID, mBuilder.build());
	}
}