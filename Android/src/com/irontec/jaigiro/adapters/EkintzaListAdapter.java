package com.irontec.jaigiro.adapters;

import java.text.ParseException;
import java.util.ArrayList;
import java.util.Random;

import com.irontec.jaigiro.R;
import com.irontec.jaigiro.helpers.ColorUtils;
import com.irontec.jaigiro.helpers.DateUtils;
import com.irontec.jaigiro.helpers.SquaredImageView;
import com.irontec.jaigiro.models.Ekintza;
import com.irontec.jaigiro.models.Festa;
import com.squareup.picasso.Picasso;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.BaseAdapter;
import android.widget.LinearLayout;
import android.widget.TextView;

public class EkintzaListAdapter extends BaseAdapter {

	private ArrayList<Ekintza> mData = new ArrayList<Ekintza>();
	private LayoutInflater mInflater;
	private Context mContext;

	public EkintzaListAdapter(Context context, ArrayList<Ekintza> list) {
		this.mContext = context;
		this.mInflater = (LayoutInflater)mContext.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
		this.mData = list; 
	}

	public void addItem(final Ekintza item) {
		mData.add(item);
		notifyDataSetChanged();
	}

	@Override
	public int getCount() {
		return mData.size();
	}

	@Override
	public Ekintza getItem(int position) {
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
			convertView = mInflater.inflate(R.layout.row_ekintza, null);
			holder = new ViewHolder();
			holder.izena = (TextView) convertView.findViewById(R.id.izena);
			holder.deskribapena = (TextView) convertView.findViewById(R.id.deskribapena);
			holder.eguna = (TextView) convertView.findViewById(R.id.eguna);
			holder.ordua = (TextView) convertView.findViewById(R.id.ordua);
			holder.hilabetea = (TextView) convertView.findViewById(R.id.hilabetea);
			convertView.setTag(holder);
		} else {
			holder = (ViewHolder) convertView.getTag();
		}
		
		Ekintza ekintza = mData.get(position);
		
		holder.izena.setText(ekintza.izena);
		holder.deskribapena.setText(ekintza.deskribapena);
		try {
			holder.hilabetea.setText(ekintza.getHilabetea());
			holder.eguna.setText(ekintza.getEguna());
			holder.ordua.setText(ekintza.getOrdua());
		} catch (ParseException e) {
			e.printStackTrace();
		}
		return convertView;
	}
	static class ViewHolder {
		TextView izena;
		TextView deskribapena;
		TextView ordua;
		TextView eguna;
		TextView hilabetea;
	}

}
