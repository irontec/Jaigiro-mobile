package com.irontec.jaigiro.adapters;

import java.util.ArrayList;
import java.util.Random;

import com.irontec.jaigiro.R;
import com.irontec.jaigiro.helpers.ColorUtils;
import com.irontec.jaigiro.helpers.SquaredImageView;
import com.irontec.jaigiro.models.Festa;
import com.squareup.picasso.Picasso;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.TextView;

public class FestaListAdapter extends BaseAdapter {

	private ArrayList<Festa> mData = new ArrayList<Festa>();
	private LayoutInflater mInflater;
	private Context mContext;

	public FestaListAdapter(Context context, ArrayList<Festa> list) {
		this.mContext = context;
		this.mInflater = (LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.mData = list; 
	}

	public void addItem(final Festa item) {
		mData.add(item);
		notifyDataSetChanged();
	}
	
	public void addAllItems(final ArrayList<Festa> items) {
		mData.addAll(items);
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		return mData.size();
	}

	@Override
	public Festa getItem(int position) {
		return mData.get(position);
	}

	@Override
	public long getItemId(int position) {
		return 0;
	}

	@Override
	public View getView(int position, View convertView, ViewGroup parent) {
		ViewHolder holder = null;
		if (convertView == null) {
			convertView = mInflater.inflate(R.layout.row_festa, null);
			holder = new ViewHolder();
			holder.argazkia = (SquaredImageView) convertView.findViewById(R.id.argazkia);
			holder.herria = (TextView) convertView.findViewById(R.id.herria);
			holder.data = (TextView) convertView.findViewById(R.id.data);
			holder.izena = (TextView) convertView.findViewById(R.id.izena);
			holder.background = (LinearLayout) convertView.findViewById(R.id.textBackground);
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}
		
		Festa festa = mData.get(position);
		
		Picasso.with(mContext)
		.load(festa.thumb)
		.resize(100, 100)
		.centerCrop()
		.into(holder.argazkia);
		
		holder.izena.setText(festa.izena);
		holder.data.setText(festa.hasiera);
		holder.herria.setText(festa.herria.toUpperCase());
		int color = ColorUtils.getCustomColor(festa.color, mContext);
		if (position % 2 == 0) {
			holder.herria.setBackgroundColor(mContext.getResources().getColor(android.R.color.white));
			holder.background.setBackgroundColor(color);
			holder.herria.setTextColor(color);
			holder.herria.setBackgroundColor(mContext.getResources().getColor(android.R.color.white));
			holder.izena.setTextColor(mContext.getResources().getColor(android.R.color.white));
			holder.data.setTextColor(mContext.getResources().getColor(android.R.color.white));
		} else {
			holder.background.setBackgroundColor(mContext.getResources().getColor(android.R.color.white));
			holder.herria.setBackgroundColor(color);
			holder.herria.setTextColor(mContext.getResources().getColor(android.R.color.white));
			holder.data.setTextColor(color);
			holder.izena.setTextColor(color);
		}
		
		return convertView;
	}
	static class ViewHolder {
		TextView izena;
		TextView herria;
		TextView data;
		SquaredImageView argazkia;
		LinearLayout background;
	}

}
