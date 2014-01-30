package com.irontec.jaigiro.providers;

import java.text.ParseException;
import java.util.ArrayList;

import com.irontec.jaigiro.R;
import com.irontec.jaigiro.models.Festa;
import com.irontec.jaigiro.services.RemoteFetchService;

import android.annotation.TargetApi;
import android.appwidget.AppWidgetManager;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.util.Log;
import android.widget.RemoteViews;
import android.widget.RemoteViewsService.RemoteViewsFactory;

/**
 * If you are familiar with Adapter of ListView,this is the same as adapter
 * with few changes
 * here it now takes RemoteFetchService ArrayList<ListItem> for data
 * which is a static ArrayList
 * and this example won't work if there are multiple widgets and 
 * they update at same time i.e they modify RemoteFetchService ArrayList at same
 * time.
 * For that use Database or other techniquest
 */
@TargetApi(Build.VERSION_CODES.HONEYCOMB)
public class ListProvider implements RemoteViewsFactory {
	private static final String TAG = ListProvider.class.getSimpleName();
	private ArrayList<Festa> listItemList = new ArrayList<Festa>();
	private Context context = null;
	private int appWidgetId;

	public ListProvider(Context context, Intent intent) {
		this.context = context;
		appWidgetId = intent.getIntExtra(AppWidgetManager.EXTRA_APPWIDGET_ID, AppWidgetManager.INVALID_APPWIDGET_ID);
		populateListItem();
	}

	@SuppressWarnings("unchecked")
	private void populateListItem() {
		Log.d(TAG, "POPULATING");
		if(RemoteFetchService.listItemList != null )
			listItemList = (ArrayList<Festa>) RemoteFetchService.listItemList.clone();
		else
			listItemList = new ArrayList<Festa>();
	}

	@Override
	public int getCount() {
		return listItemList.size();
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	/*
	 *Similar to getView of Adapter where instead of View
	 *we return RemoteViews 
	 * 
	 */
	@Override
	public RemoteViews getViewAt(int position) {
		final RemoteViews remoteView = new RemoteViews(
				context.getPackageName(), R.layout.widget_item);
		Festa listItem = listItemList.get(position);
		try {
			remoteView.setTextViewText(R.id.eguna, listItem.getEguna());
			remoteView.setTextViewText(R.id.hilabetea, listItem.getHilabetea());
		} catch (ParseException e) {
			e.printStackTrace();
		}
		remoteView.setTextViewText(R.id.izena, listItem.izena);
		remoteView.setTextViewText(R.id.deskribapena, listItem.deskribapena);
		remoteView.setTextViewText(R.id.count, (position + 1) + "/" + listItemList.size());

		return remoteView;
	}


	@Override
	public RemoteViews getLoadingView() {
		return null;
	}

	@Override
	public int getViewTypeCount() {
		return 1;
	}

	@Override
	public boolean hasStableIds() {
		return true;
	}

	@Override
	public void onCreate() {
	}

	@Override
	public void onDataSetChanged() {
	}

	@Override
	public void onDestroy() {
	}

}
