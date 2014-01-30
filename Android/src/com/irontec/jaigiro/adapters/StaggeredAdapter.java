package com.irontec.jaigiro.adapters;

import java.util.ArrayList;

import com.irontec.jaigiro.R;
import com.irontec.jaigiro.helpers.ColorUtils;
import com.irontec.jaigiro.helpers.ImageLoader;
import com.irontec.jaigiro.helpers.ScaleImageView;
import com.irontec.jaigiro.models.Festa;
import com.irontec.jaigiro.widgets.StaggeredGridView.LayoutParams;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Transformation;

import android.annotation.SuppressLint;
import android.content.Context;
import android.graphics.Bitmap;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;

public class StaggeredAdapter extends BaseAdapter {

	private LayoutInflater mInflater;
	private ArrayList<Festa> mFestak;
	private Context mContext;

	public StaggeredAdapter(Context context, int textViewResourceId, ArrayList<Festa> festak) {
		mInflater = LayoutInflater.from(context);
		mFestak = festak;
		mContext = context;
	}
	
	public Festa getItemAtPosition(int position) {
		return mFestak.get(position);
	}
	
	@SuppressLint("DefaultLocale")
	@Override
	public View getView(int position, View convertView, ViewGroup parent) {

		final LayoutParams lp;
		ViewHolder holder;

		if (convertView == null) {
			if (position == 0) {
				convertView = mInflater.inflate(R.layout.element_item_large, parent, false);
				lp = new LayoutParams(convertView.getLayoutParams());
				lp.span = 4;
			} else {
				convertView = mInflater.inflate(R.layout.element_item, parent, false);
				lp = new LayoutParams(convertView.getLayoutParams());
				lp.span = 2;
			}
			holder = new ViewHolder();
			holder.imageView = (ScaleImageView) convertView .findViewById(R.id.imageView1);
			holder.herria = (TextView) convertView.findViewById(R.id.herria);
			convertView.setTag(holder);
		}

		holder = (ViewHolder) convertView.getTag();
		holder.herria.setText(mFestak.get(position).herria.toUpperCase());
		
		Picasso.with(mContext).load(mFestak.get(position).kartela)
		.into(holder.imageView);

		return convertView;
	}

	public int getCustomColor(int color) {
		switch (color) {
		case 0:
			return mContext.getResources().getColor(R.color.background_green);
		case 1:
			return mContext.getResources().getColor(R.color.background_pink);
		case 2:
			return mContext.getResources().getColor(R.color.background_blue);
		default:
			return mContext.getResources().getColor(R.color.background_green);
		}
	}
	
	static class ViewHolder {
		ScaleImageView imageView;
		LinearLayout imageHeader;
		TextView herria;
	}

	public void addAll(ArrayList<Festa> newFestak) {
		mFestak.addAll(newFestak);
		Log.d("Adapter", ""+mFestak.size());
	}

	@Override
	public int getCount() {
		return 0;
	}

	@Override
	public Object getItem(int position) {
		return null;
	}

	@Override
	public long getItemId(int position) {
		return 0;
	}
}
