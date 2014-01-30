package com.irontec.jaigiro;


import java.text.ParseException;

import org.json.JSONObject;

import com.bugsense.trace.BugSenseHandler;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.helpers.ColorUtils;
import com.irontec.jaigiro.helpers.DateUtils;
import com.irontec.jaigiro.models.Festa;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.sothree.slidinguppanel.SlidingUpPanelLayout;
import com.sothree.slidinguppanel.SlidingUpPanelLayout.PanelSlideListener;
import com.squareup.picasso.Picasso;

import android.os.Bundle;
import android.content.Intent;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.text.method.LinkMovementMethod;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewTreeObserver;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

public class FestaActivity extends ActionBarActivity implements
OnClickListener {

	private ActionBar mActionBar;
	private Festa mFesta;
	private ImageView mShare;
	private LinearLayout mBanator;
	private LinearLayout mCoverLayout;
	private TextView mHerria;
	private TextView mIzena;
	private TextView mBanatorText;
	private RelativeLayout mRoot;
	private int mColor;
	private SlidingUpPanelLayout layout;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		BugSenseHandler.initAndStartSession(FestaActivity.this, "4d58588c");
		setContentView(R.layout.activity_festa);

		mActionBar = getSupportActionBar();
		mActionBar.setDisplayHomeAsUpEnabled(true);

		Intent intent = getIntent();
		if (intent != null) {
			mFesta = intent.getParcelableExtra("festa");
		}
		
		layout = (SlidingUpPanelLayout) findViewById(R.id.sliding_layout);
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
		mHerria = (TextView) findViewById(R.id.slidingTitle);
		mHerria.setTextColor(getResources().getColor(android.R.color.white));
		mHerria.setMovementMethod(LinkMovementMethod.getInstance());
		layout.setDragView(mHerria);

		ViewTreeObserver vto = layout.getViewTreeObserver();
		vto.addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
		    @Override
		    public void onGlobalLayout() {
		        layout.expandPane(0.6f);
		    }
		});
		
		TextView data = (TextView) findViewById(R.id.slidingSubTitle);
		data.setTextColor(getResources().getColor(android.R.color.white));
		
		mIzena = (TextView) findViewById(R.id.izena);
		
		mShare = (ImageView) findViewById(R.id.banatu);
		mBanator = (LinearLayout) findViewById(R.id.banator);
		ImageView argazkia = (ImageView) findViewById(R.id.argazkia);
		
		TextView deskribapena = (TextView) findViewById(R.id.deskribapena);
		mBanatorText = (TextView) findViewById(R.id.banatorText);

		mColor = ColorUtils.getCustomColor(mFesta.color, getBaseContext());
		
		mRoot = (RelativeLayout) findViewById(R.id.root);
		mRoot.setBackgroundColor(mColor);
		
		if (mFesta != null) {
			
			mActionBar.setTitle(mFesta.izena);
			
			Picasso.with(getBaseContext())
			.load(mFesta.kartela)
			.placeholder(R.drawable.placeholder_jaia)
			.error(R.drawable.placeholder_jaia)
			.fit().centerCrop()
			.into(argazkia);

			mHerria.setText(mFesta.herria.toUpperCase());
			try {
				data.setText(DateUtils.prettify(mFesta.hasiera, mFesta.bukaera));
			} catch (ParseException e) {
				e.printStackTrace();
			}
			mIzena.setText(mFesta.izena);
			deskribapena.setText(mFesta.deskribapena);
			mHerria.setBackgroundColor(mColor);
			data.setTextColor(mColor);
			mIzena.setTextColor(mColor);
			mBanatorText.setTextColor(mColor);
		}

		if (mFesta.banator) {
			mBanatorText.setTextColor(getResources().getColor(android.R.color.white));
			mBanator.setBackgroundColor(getResources().getColor(R.color.green));
		}

		mShare.setOnClickListener(this);
		mBanator.setOnClickListener(this);
		
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		BugSenseHandler.closeSession(FestaActivity.this);
	}
	
	public void setBanator() {
		RequestParams banatorParams = new RequestParams();
		banatorParams.put("uuid", JaigiroAPI.getGCMRegid(getBaseContext()));
		banatorParams.put("idJai", String.valueOf(mFesta.id));
		banatorParams.put("idFb", JaigiroAPI.getIdFacebook(getBaseContext()).toString());
		banatorParams.put("idTw", JaigiroAPI.getIdTwitter(getBaseContext()).toString());
		banatorParams.put("device", "android");

		JaigiroAPI.post(JaigiroAPI.IM_GOING, banatorParams, new JsonHttpResponseHandler(){

			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					int error = response.getInt("error");
					if (error == 0) {
						Boolean banator = response.getBoolean("banator");
						if (banator) {
							mBanatorText.setTextColor(getResources().getColor(android.R.color.white));
							mBanator.setBackgroundColor(getResources().getColor(R.color.green));
						} else {
							mBanatorText.setTextColor(mColor);
							mBanator.setBackgroundColor(getResources().getColor(android.R.color.white));
						}
						
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
	public void onClick(View view) {
		if (view.getId() == R.id.banator) {
			setBanator();
		} else {
			String message = mFesta.izena + "! Bazatoz? Jaitsi #jaigiro aplikazioa dohainik http://play.google.com/store/apps/details?id=com.irontec.jaigiro"; // http://play.google.com/store/apps/details?id=com.irontec.jaigiro";
			Intent sendIntent = new Intent();
			sendIntent.setAction(Intent.ACTION_SEND);
			sendIntent.putExtra(Intent.EXTRA_TEXT, message);
			sendIntent.setType("text/plain");
			startActivity(Intent.createChooser(sendIntent, getResources().getText(R.string.send_to)));
		}
	}
	
	public void openEkintzak() {
		Intent intent = new Intent(this, EventsActivity.class);
		intent.putExtra("festa", mFesta);
		startActivity(intent);
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			this.finish();
			return true;
		case R.id.ekintzak:
			openEkintzak();
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.festa, menu);
		return true;
	}

}
