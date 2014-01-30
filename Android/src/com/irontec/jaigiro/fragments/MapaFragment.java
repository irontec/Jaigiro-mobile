package com.irontec.jaigiro.fragments;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.Iterator;
import java.util.Map;
import java.util.Random;
import java.util.Map.Entry;

import org.json.JSONArray;
import org.json.JSONObject;

import com.google.android.gms.common.ConnectionResult;
import com.google.android.gms.common.GooglePlayServicesClient;
import com.google.android.gms.common.GooglePlayServicesUtil;
import com.google.android.gms.location.LocationClient;
import com.google.android.gms.location.LocationListener;
import com.google.android.gms.location.LocationRequest;
import com.google.android.gms.maps.CameraUpdateFactory;
import com.google.android.gms.maps.GoogleMap;
import com.google.android.gms.maps.GoogleMap.OnInfoWindowClickListener;
import com.google.android.gms.maps.GoogleMap.OnMyLocationChangeListener;
import com.google.android.gms.maps.GoogleMapOptions;
import com.google.android.gms.maps.SupportMapFragment;
import com.google.android.gms.maps.model.BitmapDescriptorFactory;
import com.google.android.gms.maps.model.CameraPosition;
import com.google.android.gms.maps.model.LatLng;
import com.google.android.gms.maps.model.Marker;
import com.google.android.gms.maps.model.MarkerOptions;
import com.irontec.jaigiro.BilatzaileaActivity;
import com.irontec.jaigiro.FestaActivity;
import com.irontec.jaigiro.PreferencesActivity;
import com.irontec.jaigiro.FestaListActivity;
import com.irontec.jaigiro.R;
import com.irontec.jaigiro.adapters.FestaListAdapter;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.helpers.ApplicationSettings;
import com.irontec.jaigiro.helpers.DateUtils;
import com.irontec.jaigiro.models.Festa;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.sothree.slidinguppanel.SlidingUpPanelLayout;
import com.sothree.slidinguppanel.SlidingUpPanelLayout.PanelSlideListener;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.location.Location;
//import android.location.LocationListener;
import android.location.LocationManager;
import android.os.Bundle;
import android.support.v4.app.ActivityCompat;
import android.support.v4.app.Fragment;
import android.support.v4.app.FragmentManager;
import android.support.v4.app.FragmentTransaction;
import android.support.v7.app.ActionBar;
import android.text.method.LinkMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewStub;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ImageButton;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;
import android.widget.ViewSwitcher;

public class MapaFragment extends Fragment implements
OnItemClickListener, LocationListener, OnMyLocationChangeListener, OnScrollListener,
GooglePlayServicesClient.ConnectionCallbacks, GooglePlayServicesClient.OnConnectionFailedListener,
OnInfoWindowClickListener {

	private final static String TAG = MapaFragment.class.getSimpleName();
	private final static int OPEN_SETTINGS = 20001;
	private final static int OPEN_SEARCH = 20002;
	protected GoogleMap mMap;
	private Context mContext;
	private SupportMapFragment mMapFragment;
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
	private ViewSwitcher mSwitcherMain;
	private TextView mEmptyFestakMapa;
	private ArrayList<Festa> mFestak;
	private FestaListAdapter mAdapter;
	private HashMap<Marker, Long> mMarkers = new HashMap<Marker, Long>();
	private Long mMaxTime;
	private Long mMaxDistance;
	private Boolean mNeedsReload = true;

	public MapaFragment() {}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		//getActivity().overridePendingTransition(R.anim.fadein, R.anim.fadeout);

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
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {

		mView = inflater.inflate(R.layout.fragment_mapa, container, false);

		mSwitcher = (ViewSwitcher) mView.findViewById(R.id.viewSwitcher1);
		mSwitcherMain = (ViewSwitcher) mView.findViewById(R.id.viewSwitcher2);
		mEmptyFestakMapa = (TextView) mView.findViewById(R.id.emptyFestakMapa);

		SlidingUpPanelLayout layout = (SlidingUpPanelLayout) mView.findViewById(R.id.sliding_layout);
		layout.setShadowDrawable(getResources().getDrawable(R.drawable.above_shadow));
		layout.setAnchorPoint(0.3f);
		layout.setPanelSlideListener(new PanelSlideListener() {
			@Override
			public void onPanelSlide(View panel, float slideOffset) {}
			@Override
			public void onPanelExpanded(View panel) {}
			@Override
			public void onPanelCollapsed(View panel) {}
			@Override
			public void onPanelAnchored(View panel) {}
		});
		TextView txtTitl = (TextView) mView.findViewById(R.id.slidingTitle);
		mLista = (ListView) mView.findViewById(R.id.listaFestakMapa);
		mLista.setOnItemClickListener(MapaFragment.this);
		txtTitl.setTextColor(mContext.getResources().getColor(android.R.color.white));
		txtTitl.setMovementMethod(LinkMovementMethod.getInstance());
		layout.setDragView(txtTitl);

		TextView txtSub = (TextView) mView.findViewById(R.id.slidingSubTitle);
		txtSub.setTextColor(mContext.getResources().getColor(android.R.color.white));

		GoogleMapOptions options = new GoogleMapOptions();
		options.mapType(GoogleMap.MAP_TYPE_NORMAL).zoomControlsEnabled(false);

		mMapFragment = SupportMapFragment.newInstance(options);
		FragmentManager fragmentManager = getChildFragmentManager();
		FragmentTransaction fragmentTransaction = fragmentManager
				.beginTransaction();
		fragmentTransaction.add(R.id.map_fragment, mMapFragment);
		fragmentTransaction.commit();
		setHasOptionsMenu(true);
		return mView;
	}

	@Override
	public void onResume() {
		super.onResume();
		int status = GooglePlayServicesUtil.isGooglePlayServicesAvailable(getActivity());
		if(status == ConnectionResult.SUCCESS) {
			setupMap();
			if (mUserLocation != null && mNeedsReload) {
				loadFestak();
			}
		}
	}

	@Override
	public void onPause() {
		super.onPause();
	}

	@Override
	public void onStart() {
		super.onStart();
		mLocationClient.connect();
		mMaxTime = ApplicationSettings.getMaxSearchDate(mContext);
		mMaxDistance = ApplicationSettings.getMaxSearchDistance(mContext);
	}

	@Override
	public void onStop() {
		if (mLocationClient.isConnected()) {
			mLocationClient.removeLocationUpdates(this);
		}
		mLocationClient.disconnect();
		super.onStop();
		mSwitcher.showPrevious();
		mSwitcherMain.showPrevious();
	}

	public void loadFestak() {
		RequestParams festakParams = new RequestParams();
		festakParams.put("uuid", JaigiroAPI.getGCMRegid(mContext));
		festakParams.put("lat", String.valueOf(mUserLocation.getLatitude()));
		festakParams.put("lng", String.valueOf(mUserLocation.getLongitude()));
		festakParams.add("device", "android");
		if (mMaxDistance != null) {
			festakParams.put("maxDistance", String.valueOf(mMaxDistance));
		}
		if (mMaxTime != null) {
			festakParams.put("dateLimit", DateUtils.preformatDate(mMaxTime));
		}

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
							mEmptyFestakMapa.setVisibility(View.GONE);
							mLista.setVisibility(View.VISIBLE);
							mAdapter = new FestaListAdapter(mContext, mFestak);
							mLista.setAdapter(mAdapter);
						} else {
							mEmptyFestakMapa.setVisibility(View.VISIBLE);
							mLista.setVisibility(View.GONE);
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

	public void loadPlaces() {
		RequestParams placesParams = new RequestParams();
		placesParams.put("uuid", JaigiroAPI.getGCMRegid(mContext));
		placesParams.put("lat", String.valueOf(mUserLocation.getLatitude()));
		placesParams.put("lng", String.valueOf(mUserLocation.getLongitude()));
		placesParams.add("device", "android");

		JaigiroAPI.post(JaigiroAPI.GET_PLACES_WITH_PARTIES, placesParams, new JsonHttpResponseHandler(){
			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					int error = response.getInt("error");
					if (error == 0) {
						JSONArray herriak = response.getJSONArray("herriak");
						if (herriak.length() > 0 ) {
							for (int i = 0; i < herriak.length(); i++) {
								JSONObject herria = herriak.getJSONObject(i);
								Long id = herria.getLong("id");
								String izena = herria.getString("izena");
								Double lat = herria.getDouble("lat");
								Double lng = herria.getDouble("lng");
								mMarkers.put(
										mMap.addMarker(
												new MarkerOptions()
												.position(new LatLng(lat, lng))
												.title(izena)
												.icon(BitmapDescriptorFactory.fromResource(getRandomMarkerIcon())))
												, id);
							}
						}else {

						}
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

	public int getRandomMarkerIcon() {
		Random rand = new Random(); 
		switch (rand.nextInt(3)) {
		case 0:
			return R.drawable.dot_green;
		case 1:
			return R.drawable.dot_blue;
		case 2:
			return R.drawable.dot_pink;
		default:
			return R.drawable.dot_green;
		}
	}

	private void setupMap() {
		mMap = mMapFragment.getMap();
		mMap.clear();
		mMap.setMapType(GoogleMap.MAP_TYPE_NORMAL);

		mMap.setMyLocationEnabled(true);
		mMap.getUiSettings().setZoomControlsEnabled(false);
		mMap.getUiSettings().setCompassEnabled(false);
		mMap.getUiSettings().setMyLocationButtonEnabled(false);
		mMap.getUiSettings().setRotateGesturesEnabled(true);
		mMap.getUiSettings().setScrollGesturesEnabled(true);
		mMap.getUiSettings().setTiltGesturesEnabled(true);
		mMap.getUiSettings().setZoomGesturesEnabled(true);
		mMap.setTrafficEnabled(false);
		mMap.setOnInfoWindowClickListener(this);
	}

	public void center() {
		mMap.animateCamera(CameraUpdateFactory.newLatLngZoom(new LatLng(mUserLocation.getLatitude(), mUserLocation.getLongitude()), 10));
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
	public void onMyLocationChange(Location location) {
		mUserLocation = location;
	}

	public GoogleMap getMap() {
		return mMap;
	}

	@Override
	public void onScroll(AbsListView arg0, int arg1, int arg2, int arg3) {}

	@Override
	public void onScrollStateChanged(AbsListView view, int scrollState) {}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		inflater.inflate(R.menu.mapa, menu);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case R.id.settings:
			openSettings();
			return true;
		case R.id.center:
			if (mUserLocation != null) {
				center();
			}
			return true;
		case R.id.search:
			openSearch();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public void onLocationChanged(Location location) {
		mUserLocation = location;
		mLocationClient.removeLocationUpdates(this);
		if (mUserLocation != null) {
			loadPlaces();
			loadFestak();
		}
		center();
	}

	@Override
	public void onConnectionFailed(ConnectionResult result) {
	}

	@Override
	public void onConnected(Bundle connectionHint) {
		mSwitcherMain.showNext();
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
	public void onInfoWindowClick(Marker marker) {
		Iterator<Entry<Marker, Long>> it = mMarkers.entrySet().iterator();
		while (it.hasNext()) {
			Map.Entry<Marker, Long> pairs = (Entry<Marker, Long>)it.next();
			Marker tmp = (Marker) pairs.getKey();
			if (tmp.getId().equals(marker.getId())) {
				Intent intent = new Intent(mContext, FestaListActivity.class);
				intent.putExtra("idPlace", pairs.getValue());
				intent.putExtra("namePlace", marker.getTitle());
				startActivity(intent);
			}
		}
	}

}
