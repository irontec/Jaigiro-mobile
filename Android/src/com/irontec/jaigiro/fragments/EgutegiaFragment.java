package com.irontec.jaigiro.fragments;

import java.util.Calendar;
import java.util.Date;
import org.json.JSONException;
import org.json.JSONObject;

import com.irontec.jaigiro.BilatzaileaActivity;
import com.irontec.jaigiro.FestaListActivity;
import com.irontec.jaigiro.R;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.helpers.DateUtils;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.squareup.timessquare.CalendarPickerView;
import com.squareup.timessquare.CalendarPickerView.OnDateSelectedListener;

import de.keyboardsurfer.android.widget.crouton.Configuration;
import de.keyboardsurfer.android.widget.crouton.Crouton;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.widget.LinearLayout;
import android.widget.TextView;

public class EgutegiaFragment extends Fragment implements OnDateSelectedListener, View.OnClickListener {

	private static final String TAG = EgutegiaFragment.class.getSimpleName();
	private View mView;
	private static final Configuration CONFIGURATION_INFINITE = new Configuration.Builder()
	.setDuration(Configuration.DURATION_INFINITE)
	.build();
	private Crouton mCrouton;
	private CalendarPickerView mCalendar;
	private Context mContext;

	public EgutegiaFragment() {}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}
	
	@Override
	public void onDestroy() {
		super.onDestroy();
		Crouton.cancelAllCroutons();
	}
	
	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		
		mContext = getActivity().getBaseContext();

		mView = inflater.inflate(R.layout.fragment_egutegia, container, false);
		Calendar nextYear = Calendar.getInstance();
		nextYear.add(Calendar.YEAR, 1);

		mCalendar = (CalendarPickerView) mView.findViewById(R.id.calendar_view);
		Date today = new Date();

		mCalendar.init(today, nextYear.getTime())
		.withSelectedDate(today);
		mCalendar.setOnDateSelectedListener(this);
		setHasOptionsMenu(true);
		return mView;
	}
	
	public void countNumberOfFestak(String maxdate) {
		RequestParams festakParams = new RequestParams();
		//Required
		festakParams.add("uuid", JaigiroAPI.getGCMRegid(mContext));
		//Optionals
		festakParams.add("idFb", JaigiroAPI.getIdFacebook(mContext).toString());
		festakParams.add("idTw", JaigiroAPI.getIdTwitter(mContext).toString());
		festakParams.add("dateLimit", maxdate);
		festakParams.add("onlyNumber", "1");
		festakParams.add("device", "android");

		JaigiroAPI.post(JaigiroAPI.GET_JAIAK, festakParams, new JsonHttpResponseHandler() {
			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					Integer howManyFesta = response.getInt("jaiKop");
					showCustomViewCrouton(howManyFesta);
				} catch (JSONException e) {
					e.printStackTrace();
				}
			}
			@Override
			public void onFailure(Throwable e, JSONObject errorResponse) {
				super.onFailure(e, errorResponse);
			}
		});
	}

	@Override
	public void onDateSelected(Date date) {
		String maxdate = DateUtils.preformatDate(date);
		countNumberOfFestak(maxdate);
	}

	private void showCustomViewCrouton(Integer howManyFesta) {
		Crouton.clearCroutonsForActivity(getActivity());
		View view = getLayoutInflater(null).inflate(R.layout.crouton_custom_view, null);
		TextView zenbat = (TextView) view.findViewById(R.id.zenbat);
		LinearLayout parentCroutonLayout = (LinearLayout) view.findViewById(R.id.parentCroutonLayout);
		parentCroutonLayout.setOnClickListener(this);
		zenbat.setText(howManyFesta.toString());
		mCrouton = Crouton.make(getActivity(), view);
		mCrouton.setConfiguration(CONFIGURATION_INFINITE).show();
	}

	@Override
	public void onClick(View v) {
		if (mCrouton != null && mCalendar != null) {
			Crouton.cancelAllCroutons();
			mCrouton = null;
			String maxdate = DateUtils.preformatDate(mCalendar.getSelectedDate());
			Intent intent = new Intent(mContext, FestaListActivity.class);
			intent.putExtra("maxdate", maxdate);
			startActivity(intent);
		}
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
	}

	@Override
	public void onStart() {
		super.onStart();
		Crouton.cancelAllCroutons();
	}

	@Override
	public void onResume() {
		super.onResume();
	}

	@Override
	public void onPause() {
		super.onPause();
	}

	@Override
	public void onStop() {
		super.onStop();
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		inflater.inflate(R.menu.egutegia, menu);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.search:
			openSearch();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	public void openSearch() {
		Intent intent = new Intent(mContext, BilatzaileaActivity.class);
		startActivity(intent);
	}

}