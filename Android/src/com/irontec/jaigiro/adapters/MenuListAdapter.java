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

import android.annotation.SuppressLint;
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

public class MenuListAdapter extends BaseAdapter {

	Context context;
	String[] mTitle;
	//String[] mSubTitle;
	int[] mIcon;
	LayoutInflater inflater;
	private CircularImageView avatar;

//	public MenuListAdapter(Context context, String[] title, String[] subtitle,
//			int[] icon) {
//		this.context = context;
//		this.mTitle = title;
//		this.mSubTitle = subtitle;
//		this.mIcon = icon;
//	}
	
	public MenuListAdapter(Context context, String[] title, int[] icon) {
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

	@SuppressLint("DefaultLocale")
	public View getView(int position, View convertView, ViewGroup parent) {
		TextView txtTitle;
		TextView txtSubTitle;
		
		inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		
		ImageView imgIcon;
		//LinearLayout imgIconLayout;
		
		if (position == 0) {
			View itemHeader = inflater.inflate(R.layout.drawer_list_header, parent, false);
			txtTitle = (TextView) itemHeader.findViewById(R.id.title);
			//txtSubTitle = (TextView) itemView.findViewById(R.id.subtitle);

			imgIcon = (ImageView) itemHeader.findViewById(R.id.icon);
			//imgIconLayout = (LinearLayout) itemHeader.findViewById(R.id.iconLayout);
			avatar = (CircularImageView) itemHeader.findViewById(R.id.circular_image);
			
			if (!ApplicationSettings.isGuestMode(context)) {
				new DownloadImageTask(avatar).execute(JaigiroAPI.getUserImage(context));
				txtTitle.setText(JaigiroAPI.getUserName(context).toUpperCase());
				txtTitle.setTextColor(context.getResources().getColor(R.color.background_pink));
			}else {
				txtTitle.setText("KAIXO!");
			}
			//imgIconLayout.setVisibility(View.GONE);
			
			return itemHeader;
		} else {
			View itemView = inflater.inflate(R.layout.drawer_list_item, parent, false);
			txtTitle = (TextView) itemView.findViewById(R.id.title);
			//txtSubTitle = (TextView) itemView.findViewById(R.id.subtitle);
			imgIcon = (ImageView) itemView.findViewById(R.id.icon);
			//imgIconLayout = (LinearLayout) itemView.findViewById(R.id.iconLayout);
			txtTitle.setText(mTitle[position]);
			imgIcon.setImageResource(mIcon[position]);
			
//			switch (position) {
//			case 1:
//			case 4:
//				txtTitle.setTextColor(context.getResources().getColor(R.color.background_pink));
//				break;
//			case 2:
//				txtTitle.setTextColor(context.getResources().getColor(R.color.background_blue));
//				break;
//			case 3:
//				txtTitle.setTextColor(context.getResources().getColor(R.color.background_green));
//				break;
//			}
			return itemView;
		}
		
		//txtSubTitle.setText(mSubTitle[position]);
		
	}
	
	private class DownloadImageTask extends AsyncTask<String, Void, Bitmap> {
		CircularImageView bmImage;

	    public DownloadImageTask(CircularImageView bmImage) {
	        this.bmImage = bmImage;
	    }

	    protected Bitmap doInBackground(String... urls) {
	        String urldisplay = urls[0];
	        Bitmap mIcon11 = null;
	        try {
	            InputStream in = new java.net.URL(urldisplay).openStream();
	            mIcon11 = BitmapFactory.decodeStream(in);
	        } catch (Exception e) {
	            e.printStackTrace();
	        }
	        return mIcon11;
	    }

	    protected void onPostExecute(Bitmap result) {
	        bmImage.setImageBitmap(result);
	    }
	}

}