package com.irontec.jaigiro.adapters;

import java.io.InputStream;
import java.lang.ref.WeakReference;
import java.net.URL;

import org.apache.http.HttpEntity;
import org.apache.http.HttpResponse;
import org.apache.http.HttpStatus;
import org.apache.http.client.methods.HttpGet;
import org.apache.http.impl.client.DefaultHttpClient;

import com.irontec.jaigiro.R;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.helpers.ApplicationSettings;
import com.irontec.jaigiro.helpers.CircularImageView;

import android.content.Context;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.LinearGradient;
import android.os.AsyncTask;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class MenuListBottomAdapter extends BaseAdapter {

	Context context;
	String[] mTitle;
	//String[] mSubTitle;
	int[] mIcon;
	LayoutInflater inflater;
	private CircularImageView avatar;

	public MenuListBottomAdapter(Context context, String[] title, int[] icon) {
		this.context = context;
		this.mTitle = title;
		this.mIcon = icon;
	}

	@Override
	public int getCount() {
		return mTitle.length;
	}

	@Override
	public Object getItem(int position) {
		return mTitle[position];
	}

	@Override
	public long getItemId(int position) {
		return position;
	}

	public View getView(int position, View convertView, ViewGroup parent) {
		TextView txtTitle;
		TextView txtSubTitle;

		inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);

		ImageView imgIcon;

		View itemView = inflater.inflate(R.layout.drawer_list_item, parent, false);
		txtTitle = (TextView) itemView.findViewById(R.id.title);
		imgIcon = (ImageView) itemView.findViewById(R.id.icon);
		txtTitle.setText(mTitle[position]);
		imgIcon.setImageResource(mIcon[position]);

//		switch (position) {
//		case 1:
//		case 4:
//			txtTitle.setTextColor(context.getResources().getColor(R.color.background_pink));
//			break;
//		case 2:
//			txtTitle.setTextColor(context.getResources().getColor(R.color.background_blue));
//			break;
//		case 3:
//			txtTitle.setTextColor(context.getResources().getColor(R.color.background_green));
//			break;
//		}
		return itemView;
	}
	
}