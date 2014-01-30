package com.irontec.jaigiro;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ListView;
import android.widget.ViewSwitcher;

import com.irontec.jaigiro.adapters.FestaListAdapter;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.models.Festa;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;

public class FestaListActivity extends ActionBarActivity implements OnItemClickListener {

	private static final Long NULL_PLACE_ID = -666l;
	private ActionBar mActionBar;
	private Long mPlaceId;
	private String mPlaceName;
	private ArrayList<Festa> mFestak;
	private ListView mLista;
	private FestaListAdapter mAdapter;
	private ViewSwitcher mSwitcher;
	private Context mContext;
	private String mMaxSearchDate;

	@Override
	protected void onStop() {
		super.onStop();
		mSwitcher.showPrevious();
	}
	
	@Override
	protected void onResume() {
		super.onResume();
		if (mPlaceId != null && mPlaceName != null) {
			loadPlaceParties();
		} else if (mMaxSearchDate != null) {
			loadPartiestBtwDates();
		}
		
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_place);

		mContext = getBaseContext();
		
		mActionBar = getSupportActionBar();
		mActionBar.setDisplayHomeAsUpEnabled(true);

		Intent intent = getIntent();
		if (intent != null) {
			mPlaceId = intent.getLongExtra("idPlace", NULL_PLACE_ID);
			mPlaceName = intent.getStringExtra("namePlace");
			mMaxSearchDate = intent.getStringExtra("maxdate");
		}
		
		mActionBar.setTitle(mPlaceName);
		
		mSwitcher = (ViewSwitcher) findViewById(R.id.viewSwitcher1);
		mLista = (ListView) findViewById(R.id.lista);
		
	}
	
	public void loadPartiestBtwDates() {
		RequestParams festakParams = new RequestParams();
		//Required
		festakParams.add("uuid", JaigiroAPI.getGCMRegid(mContext));
		//Optionals
		festakParams.add("idFb", JaigiroAPI.getIdFacebook(mContext).toString());
		festakParams.add("idTw", JaigiroAPI.getIdTwitter(mContext).toString());
		festakParams.add("dateLimit", mMaxSearchDate);
		festakParams.put("device", "android");

		JaigiroAPI.post(JaigiroAPI.GET_JAIAK, festakParams, new JsonHttpResponseHandler(){

			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					int error = response.getInt("error");
					if (error == 0) {
						mFestak = new ArrayList<Festa>();
						JSONArray festak = response.getJSONArray("jaiak");
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
						mAdapter = new FestaListAdapter(getBaseContext(), mFestak);
						mLista.setAdapter(mAdapter);
						mLista.setOnItemClickListener(FestaListActivity.this);
						mSwitcher.showNext();
					}
				} catch (Exception e) {
				}
			}

			@Override
			public void onFailure(Throwable e, JSONObject errorResponse) {
				super.onFailure(e, errorResponse);
			}

		});
	}

	public void loadPlaceParties() {
		RequestParams placeParams = new RequestParams();
		placeParams.put("uuid", JaigiroAPI.getGCMRegid(getBaseContext()));
		placeParams.put("idHerri", mPlaceId.toString());
		placeParams.put("device", "android");

		JaigiroAPI.post(JaigiroAPI.GET_PARTIES_FROM_PLACE, placeParams, new JsonHttpResponseHandler(){

			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					int error = response.getInt("error");
					if (error == 0) {
						mFestak = new ArrayList<Festa>();
						JSONArray festak = response.getJSONArray("jaiak");
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
						mAdapter = new FestaListAdapter(getBaseContext(), mFestak);
						mLista.setAdapter(mAdapter);
						mLista.setOnItemClickListener(FestaListActivity.this);
						mSwitcher.showNext();
					}
				} catch (Exception e) {
				}
			}

			@Override
			public void onFailure(Throwable e, JSONObject errorResponse) {
				super.onFailure(e, errorResponse);
			}

		});
	}

	@Override
	public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
		Festa festa = mAdapter.getItem(position);
		Intent intent = new Intent(getBaseContext(), FestaActivity.class);
		intent.putExtra("festa", festa);
		startActivity(intent);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			this.finish();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.place, menu);
		return true;
	}

}
