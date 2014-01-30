package com.irontec.jaigiro.providers;

import com.irontec.jaigiro.R;
import com.irontec.jaigiro.services.RemoteFetchService;
import com.irontec.jaigiro.services.WidgetService;

import android.annotation.TargetApi;
import android.appwidget.AppWidgetManager;
import android.appwidget.AppWidgetProvider;
import android.content.Context;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.widget.RemoteViews;

public class WidgetProvider extends AppWidgetProvider {

	public static final String DATA_FETCHED = "com.irontec.jaigiro.DATA_FETCHED";

	@Override
	public void onUpdate(Context context, AppWidgetManager appWidgetManager,
			int[] appWidgetIds) {
		final int N = appWidgetIds.length;
		for (int i = 0; i < N; i++) {
			Intent serviceIntent = new Intent(context, RemoteFetchService.class);
			serviceIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID,
					appWidgetIds[i]);
			context.startService(serviceIntent);
		}
		super.onUpdate(context, appWidgetManager, appWidgetIds);
	}

	@TargetApi(Build.VERSION_CODES.HONEYCOMB)
	@SuppressWarnings("deprecation")
	private RemoteViews updateWidgetListView(Context context, int appWidgetId) {

		RemoteViews remoteViews = new RemoteViews(context.getPackageName(), R.layout.widget_layout);

		Intent svcIntent = new Intent(context, WidgetService.class);
		svcIntent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, appWidgetId);
		svcIntent.setData(Uri.parse(svcIntent.toUri(Intent.URI_INTENT_SCHEME)));
		remoteViews.setRemoteAdapter(appWidgetId, R.id.listViewWidget, svcIntent);
		remoteViews.setEmptyView(R.id.listViewWidget, R.id.empty_view);
		return remoteViews;
	}

	@Override
	public void onReceive(Context context, Intent intent) {
		super.onReceive(context, intent);
		if (intent.getAction().equals(DATA_FETCHED)) {
			int appWidgetId = intent.getIntExtra(
					AppWidgetManager.EXTRA_APPWIDGET_ID,
					AppWidgetManager.INVALID_APPWIDGET_ID);
			AppWidgetManager appWidgetManager = AppWidgetManager.getInstance(context);
			RemoteViews remoteViews = updateWidgetListView(context, appWidgetId);
			appWidgetManager.updateAppWidget(appWidgetId, remoteViews);
		}

	}

}
