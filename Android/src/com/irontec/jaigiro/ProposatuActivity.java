package com.irontec.jaigiro;

import org.json.JSONObject;

import com.bugsense.trace.BugSenseHandler;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;

import android.app.Dialog;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Toast;

public class ProposatuActivity extends ActionBarActivity {

	private Dialog mDialog;
	
	private ActionBar mActionBar;
	private EditText mIzena;
	private EditText mHerrialdea;
	private Button mProposatu;
	
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		BugSenseHandler.initAndStartSession(ProposatuActivity.this, "4d58588c");
		setContentView(R.layout.activity_proposatu);
		
		mActionBar = getSupportActionBar();
		mActionBar.setDisplayHomeAsUpEnabled(true);
		
		mDialog = new Dialog(this);
		mDialog.requestWindowFeature((int) Window.FEATURE_NO_TITLE);
		mDialog.setCancelable(false);
		mDialog.setContentView(R.layout.dialog_simple_loading);
		
		mIzena = (EditText) findViewById(R.id.izena);
		
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		BugSenseHandler.closeSession(ProposatuActivity.this);
	}
	
	public void propose() {
		RequestParams proposeParams = new RequestParams();
		proposeParams.put("uuid", JaigiroAPI.getGCMRegid(getBaseContext()));
		proposeParams.put("sugerentzia", mIzena.getText().toString());
		proposeParams.put("idFb", JaigiroAPI.getIdFacebook(getBaseContext()).toString());
		proposeParams.put("idTw", JaigiroAPI.getIdTwitter(getBaseContext()).toString());
		proposeParams.put("device", "android");

		JaigiroAPI.post(JaigiroAPI.PROPOSE, proposeParams, new JsonHttpResponseHandler(){

			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					mDialog.dismiss();
					Toast.makeText(getBaseContext(), "Zure proposamena biali egin da. Eskerrik asko.",  Toast.LENGTH_LONG).show();
					finish();
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
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			this.finish();
			return true;
		case R.id.add:
			propose();
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.proposatu, menu);
		return true;
	}
	
}
