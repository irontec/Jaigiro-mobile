package com.irontec.jaigiro;

import java.util.ArrayList;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import com.irontec.jaigiro.adapters.FestaListAdapter;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.models.Festa;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;

import de.keyboardsurfer.android.widget.crouton.Configuration;
import de.keyboardsurfer.android.widget.crouton.Crouton;
import de.keyboardsurfer.android.widget.crouton.Style;

import android.os.Bundle;
import android.content.Context;
import android.content.Intent;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.KeyEvent;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.ViewStub;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.AbsListView;
import android.widget.AbsListView.OnScrollListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.ProgressBar;
import android.widget.TextView;

public class BilatzaileaActivity extends ActionBarActivity implements OnItemClickListener {

	private static final String TAG = BilatzaileaActivity.class.getSimpleName();
	private Context mContext;
	private ActionBar mActionBar;
	private EditText mSearch;
	private ArrayList<Festa> mFestak;
	private ViewStub mStubEmptyFestak;
	private ProgressBar mProgress;
	private ListView mLista;
	private FestaListAdapter mAdapter;
	private TextView mEmptyView;
	private static final Configuration CONFIGURATION_INFINITE = new Configuration.Builder()
	.setDuration(Configuration.DURATION_INFINITE)
	.build();
	private Crouton mCrouton;
	private boolean mShouldBeCanceled = false;

	@Override
	protected void onDestroy() {
		super.onDestroy();
		Crouton.cancelAllCroutons();
	}
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_bilatzailea);

		mContext = getBaseContext();

		mActionBar = getSupportActionBar();
		mActionBar.setDisplayHomeAsUpEnabled(true);

		mProgress = (ProgressBar) findViewById(R.id.progress);
		mEmptyView = (TextView) findViewById(R.id.emptyView);

		mLista = (ListView) findViewById(R.id.lista);
		showCustomViewCrouton();
		mLista.setOnItemClickListener(this);
		mLista.setOnScrollListener(new OnScrollListener() {
			@Override
			public void onScrollStateChanged(AbsListView view, int scrollState) {
				switch (scrollState) {
				case SCROLL_STATE_TOUCH_SCROLL:
					break;
				case SCROLL_STATE_FLING:
					break;
				case SCROLL_STATE_IDLE:
					if (mShouldBeCanceled) {
						cancelCustomViewCrouton();
					}
				default:
					break;
				}			
			}
			@Override
			public void onScroll(AbsListView view, int firstVisibleItem,
					int visibleItemCount, int totalItemCount) {
				mShouldBeCanceled = true;
			}
		});

	}

	public void performSearch() {
		if (mSearch == null || mSearch.getText() == null || mSearch.getText().toString().trim().equals("")) {
			Crouton.makeText(this, "Bilaketak gutxienez hizki bakarra euki behar du.", Style.ALERT).show();
			mProgress.setVisibility(View.GONE);
			return;
		}
		RequestParams searchParams = new RequestParams();
		//Required
		searchParams.add("uuid", JaigiroAPI.getGCMRegid(mContext));
		searchParams.add("search", mSearch.getText().toString().trim());
		searchParams.add("device", "android");
		//Optionals
		searchParams.add("idFb", JaigiroAPI.getIdFacebook(mContext).toString());
		searchParams.add("idTw", JaigiroAPI.getIdTwitter(mContext).toString());

		JaigiroAPI.post(JaigiroAPI.SEARCH, searchParams, new JsonHttpResponseHandler() {
			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
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
						mAdapter = new FestaListAdapter(mContext, mFestak);
						mLista.setAdapter(mAdapter);
						mAdapter.notifyDataSetChanged();
						mProgress.setVisibility(View.GONE);
					}else {
						mProgress.setVisibility(View.GONE);
						mEmptyView.setVisibility(View.VISIBLE);
					}
				} catch (JSONException e) {
					e.printStackTrace();
					mProgress.setVisibility(View.GONE);
					mEmptyView.setVisibility(View.VISIBLE);
				}

			}
			@Override
			public void onFailure(Throwable e, JSONObject errorResponse) {
				super.onFailure(e, errorResponse);
				Log.d(TAG, errorResponse.toString());
			}
		});
	}

	private void showCustomViewCrouton() {
		Crouton.clearCroutonsForActivity(BilatzaileaActivity.this);
		View view = getLayoutInflater().inflate(R.layout.crouton_custom_search, null);
		mSearch = (EditText) view.findViewById(R.id.search);
		mSearch.setOnEditorActionListener(new TextView.OnEditorActionListener() {
			@Override
			public boolean onEditorAction(TextView view, int id, KeyEvent event) {
				if (id == EditorInfo.IME_ACTION_SEARCH) {
					InputMethodManager imm = (InputMethodManager)getSystemService(Context.INPUT_METHOD_SERVICE);
					imm.hideSoftInputFromWindow(mSearch.getWindowToken(), 0);
					mProgress.setVisibility(View.VISIBLE);
					mEmptyView.setVisibility(View.GONE);
					cancelCustomViewCrouton();
					performSearch();
					return true;
				}
				return false;
			}
		});
		mCrouton = Crouton.make(BilatzaileaActivity.this, view).setConfiguration(CONFIGURATION_INFINITE);
		mCrouton.show();
	}

	private void cancelCustomViewCrouton() {
		if (mCrouton != null) {
			mCrouton.cancel();
		}
	}

	@Override
	public void onItemClick(AdapterView<?> adapter, View view, int position, long id) {
		Festa festa = mAdapter.getItem(position);
		if (festa != null) {
			Intent intent = new Intent(mContext, FestaActivity.class);
			intent.putExtra("festa", festa);
			startActivity(intent);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.bilatzailea, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			this.finish();
			return true;
		case R.id.search:
			openSearch();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	public void openSearch() {
		showCustomViewCrouton();
	}

}
