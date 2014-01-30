package com.irontec.jaigiro.fragments;

import java.util.ArrayList;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesClient;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.location.LocationClient;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.maps.GoogleMap.OnMyLocationChangeListener;
import com.irontec.jaigiro.BilatzaileaActivity;
import com.irontec.jaigiro.FestaActivity;
import com.irontec.jaigiro.MainActivity;
import com.irontec.jaigiro.PreferencesActivity;
import com.irontec.jaigiro.R;
import com.irontec.jaigiro.adapters.FestaListAdapter;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.helpers.ApplicationSettings;
import com.irontec.jaigiro.helpers.DateUtils;
import com.irontec.jaigiro.models.Festa;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.location.Criteria;
import android.location.Location;
import android.location.LocationManager;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.app.ListFragment;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewStub;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.Toast;
import android.widget.ViewSwitcher;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView.OnItemClickListener;


public class InguruaFragment  extends ListFragment implements
OnItemClickListener, LocationListener, OnMyLocationChangeListener, OnScrollListener,
GooglePlayServicesClient.ConnectionCallbacks, GooglePlayServicesClient.OnConnectionFailedListener {

	private static final String TAG = InguruaFragment.class.getSimpleName();
	private final static int OPEN_SETTINGS = 30001;
	private final static int OPEN_SEARCH = 30002;
	private Context mContext;
	private Location mUserLocation;
	private View mView;
	private static final int MILLISECONDS_PER_SECOND = 1000;
	public static final int UPDATE_INTERVAL_IN_SECONDS = 5;
	private static final long UPDATE_INTERVAL =
			MILLISECONDS_PER_SECOND * UPDATE_INTERVAL_IN_SECONDS;
	private static final int FASTEST_INTERVAL_IN_SECONDS = 1;
	private static final long FASTEST_INTERVAL =
			MILLISECONDS_PER_SECOND * FASTEST_INTERVAL_IN_SECONDS;
	LocationRequest mLocationRequest;
	LocationClient mLocationClient;
	boolean mUpdatesRequested;
	private ListView mLista;
	private ViewSwitcher mSwitcher;
	//private ViewStub mStub;
	private ArrayList<Festa> mFestak;
	private FestaListAdapter mAdapter;
	private Long mMaxTime;
	private Long mMaxDistance;
	private Boolean mNeedsReload = true;

	public InguruaFragment() {}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		mContext = getActivity().getBaseContext();

		mLocationRequest = LocationRequest.create();
		mLocationRequest.setPriority(
				LocationRequest.PRIORITY_BALANCED_POWER_ACCURACY);
		mLocationRequest.setInterval(UPDATE_INTERVAL);
		mLocationRequest.setFastestInterval(FASTEST_INTERVAL);
		mLocationClient = new LocationClient(getActivity().getBaseContext(), this, this);
		mUpdatesRequested = true;
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {

		setHasOptionsMenu(true);

		mView = inflater.inflate(R.layout.fragment_ingurua, container, false);

		mSwitcher = (ViewSwitcher) mView.findViewById(R.id.viewSwitcher1);
		//mStub = (ViewStub) mView.findViewById(R.id.stub);
		setHasOptionsMenu(true);
		return mView;
	}

	public void loadFestak() {
		RequestParams festakParams = new RequestParams();
		festakParams.put("uuid", JaigiroAPI.getGCMRegid(mContext));
		festakParams.put("lat", String.valueOf(mUserLocation.getLatitude()));
		festakParams.put("lng", String.valueOf(mUserLocation.getLongitude()));
		festakParams.add("device", "android");
		if (mMaxDistance != null)
			festakParams.put("maxDistance", String.valueOf(mMaxDistance));
		if (mMaxTime != null) 
			festakParams.put("dateLimit", String.valueOf(DateUtils.preformatDate(mMaxTime)));

		JaigiroAPI.post(JaigiroAPI.GET_JAIAK_COORDS, festakParams, new JsonHttpResponseHandler(){
			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					int error = response.getInt("error");
					if (error == 0) {
						mFestak = new ArrayList<Festa>();
						JSONArray festak = response.getJSONArray("jaiak");
						if (festak.length() > 0 ) {
							//							if (mStub != null) {
							//								mStub.setLayoutResource(R.layout.view_festak_list);
							//								mStub.inflate();
							//								mStub = null;
							//							}
							mLista = getListView();
							int color = 0;
							for (int i = 0; i < festak.length(); i++) {
								Festa festa = new Festa(festak.getJSONObject(i));
								if (color == 3) {
									color = 0;
								}
								festa.color = color;
								color++;
								mFestak.add(festa);
							}
							mAdapter = new FestaListAdapter(mContext, mFestak);
							mLista.setAdapter(mAdapter);
							mLista.setOnItemClickListener(InguruaFragment.this);
						}else {
							//							if (mStub != null) {
							//								mStub.setLayoutResource(R.layout.view_empty_festak);
							//								mStub.inflate();
							//								mStub = null;
							//							}
						}
						mSwitcher.showNext();
					}
				} catch (Exception e) {
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
	public void onResume() {
		super.onResume();
		int status = GooglePlayServicesUtil.isGooglePlayServicesAvailable(getActivity());
		if(status == ConnectionResult.SUCCESS) {
		}
	}

	@Override
	public void onStart() {
		super.onStart();
		mLocationClient.connect();
	}

	@Override
	public void onStop() {
		if (mLocationClient.isConnected()) {
			mLocationClient.removeLocationUpdates(this);
		}
		mLocationClient.disconnect();
		super.onStop();
		mSwitcher.showPrevious();
	}

	@Override
	public void onMyLocationChange(Location arg0) {
	}

	@Override
	public void onLocationChanged(Location location) {
		mUserLocation = location;
		mLocationClient.removeLocationUpdates(this);
		loadFestak();
	}

	@Override
	public void onConnectionFailed(ConnectionResult result) {
	}

	@Override
	public void onConnected(Bundle connectionHint) {
		if (mUpdatesRequested) {
			mLocationClient.requestLocationUpdates(mLocationRequest, this);
		}
	}

	@Override
	public void onDisconnected() {
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
		Festa festa = mAdapter.getItem(position);
		Intent intent = new Intent(mContext, FestaActivity.class);
		intent.putExtra("festa", festa);
		startActivity(intent);
	}

	@Override
	public void onScroll(AbsListView view, int firstVisibleItem,
			int visibleItemCount, int totalItemCount) {
	}

	@Override
	public void onScrollStateChanged(AbsListView view, int scrollState) {
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == OPEN_SETTINGS) {
			mMaxTime = ApplicationSettings.getMaxSearchDate(mContext);
			mMaxDistance = ApplicationSettings.getMaxSearchDistance(mContext);
			mNeedsReload = false;
		}
	}
	
	public void openSettings() {
		Intent intent = new Intent(mContext, PreferencesActivity.class);
		startActivityForResult(intent, OPEN_SETTINGS);
	}
	public void openSearch() {
		Intent intent = new Intent(mContext, BilatzaileaActivity.class);
		startActivityForResult(intent, OPEN_SEARCH);
	}
	
	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		inflater.inflate(R.menu.ingurua, menu);
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.settings:
			openSettings();
			return true;
		case R.id.search:
			openSearch();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

}
