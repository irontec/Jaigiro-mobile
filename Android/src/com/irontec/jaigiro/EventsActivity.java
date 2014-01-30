package com.irontec.jaigiro;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONObject;

import com.bugsense.trace.BugSenseHandler;
import com.irontec.jaigiro.adapters.EkintzaListAdapter;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.models.Ekintza;
import com.irontec.jaigiro.models.Festa;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;

import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewGroup.LayoutParams;
import android.widget.ListView;
import android.widget.ViewSwitcher;

public class EventsActivity extends ActionBarActivity {

	private final static int ADD_EVENTS_TO_PARTY = 10001;
	
	private ActionBar mActionBar;
	private ListView mLista;
	private ArrayList<Ekintza> mEkintzak;
	private Festa mFesta;
	private EkintzaListAdapter mAdapter;
	private ViewSwitcher mSwitcher;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		BugSenseHandler.initAndStartSession(EventsActivity.this, "4d58588c");
		setContentView(R.layout.activity_events);
		
		mActionBar = getSupportActionBar();
		mActionBar.setDisplayHomeAsUpEnabled(true);
		
		mLista = (ListView) findViewById(R.id.ekintzak);
		
		mSwitcher = (ViewSwitcher) findViewById(R.id.viewSwitcher2);
		
		Intent intent = getIntent();
		if (intent != null) {
			mFesta = intent.getParcelableExtra("festa");
		}
		
		getEkintzak();
		
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		BugSenseHandler.closeSession(EventsActivity.this);
	}

	public void getEkintzak() {
		RequestParams ekintzakParams = new RequestParams();
		ekintzakParams.put("uuid", JaigiroAPI.getGCMRegid(getBaseContext()));
		ekintzakParams.put("idJai", String.valueOf(mFesta.id));
		ekintzakParams.put("idFb", JaigiroAPI.getIdFacebook(getBaseContext()).toString());
		ekintzakParams.put("idTw", JaigiroAPI.getIdTwitter(getBaseContext()).toString());
		ekintzakParams.put("device", "android");

		JaigiroAPI.post(JaigiroAPI.GET_EVENTS_BY_PARTY, ekintzakParams, new JsonHttpResponseHandler(){

			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					int error = response.getInt("error");
					if (error == 0) {
						mEkintzak = new ArrayList<Ekintza>();
						JSONArray ekintzak = response.getJSONArray("ekintzak");
						if (ekintzak.length() > 0) {
							for (int i = 0; i < ekintzak.length(); i++) {
								Ekintza ekintza = new Ekintza(ekintzak.getJSONObject(i));
								mEkintzak.add(ekintza);
							}
							mAdapter = new EkintzaListAdapter(getBaseContext(), mEkintzak);
							mLista.setAdapter(mAdapter);
							mAdapter.notifyDataSetChanged();
						} else {
							View empty = getLayoutInflater().inflate(R.layout.view_empty_ekintzak, null, false);
							addContentView(empty, new LayoutParams(LayoutParams.MATCH_PARENT, LayoutParams.MATCH_PARENT));
							mLista.setEmptyView(empty);
						}
					}
					mSwitcher.showNext();
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
	
	public void openProposeEvent() {
		Intent intent = new Intent(getBaseContext(), EkintzaProposatuActivity.class);
		intent.putExtra("festa", mFesta);
		startActivityForResult(intent, ADD_EVENTS_TO_PARTY);
		mSwitcher.showPrevious();
	}
	
	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);
		if (requestCode == ADD_EVENTS_TO_PARTY) {
			if (resultCode == RESULT_OK) {
				Bundle res = data.getExtras();
				if (res != null) {
					mFesta = res.getParcelable("festa");
					getEkintzak();
				}
			}
		}
	}
	
	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			this.finish();
			return true;
		case R.id.add:
			openProposeEvent();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}
	
	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.events, menu);
		return true;
	}

}
