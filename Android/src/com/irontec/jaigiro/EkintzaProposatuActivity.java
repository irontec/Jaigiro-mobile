package com.irontec.jaigiro;

import java.text.ParseException;
import java.util.Calendar;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;
import org.json.JSONObject;

import com.bugsense.trace.BugSenseHandler;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.models.Ekintza;
import com.irontec.jaigiro.models.Festa;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.roomorama.caldroid.CaldroidFragment;
import com.roomorama.caldroid.CaldroidListener;

import android.app.Dialog;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.text.Editable;
import android.text.TextWatcher;
import android.util.Log;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnFocusChangeListener;
import android.view.Window;
import android.widget.EditText;
import android.widget.TextView;
import android.widget.Toast;

public class EkintzaProposatuActivity extends ActionBarActivity {

	private final static String TAG = EkintzaProposatuActivity.class.getSimpleName();

	private ActionBar mActionBar;

	private Dialog mDialog;

	private Festa mFesta;
	private Ekintza mEkintza = new Ekintza();

	private EditText mIzena, mDeskribapena, mData, mOrdua;
	private TextView eIzena, eDeskribapena, eOrdua, eEguna, eHilabetea;

	static final int DATE_DIALOG_ID = 0;
	private CaldroidFragment dialogCaldroidFragment;
	private DateTime selectedDate = new DateTime(new Date());

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		BugSenseHandler.initAndStartSession(EkintzaProposatuActivity.this, "4d58588c");
		setContentView(R.layout.activity_ekintza_proposatu);

		final Bundle state = savedInstanceState;

		mActionBar = getSupportActionBar();
		mActionBar.setDisplayHomeAsUpEnabled(true);

		Intent intent = getIntent();
		if (intent != null) {
			mFesta = intent.getParcelableExtra("festa");
		}


		mDialog = new Dialog(this);
		mDialog.requestWindowFeature((int) Window.FEATURE_NO_TITLE);
		mDialog.setCancelable(false);
		mDialog.setContentView(R.layout.dialog_simple_loading);

		mIzena = (EditText) findViewById(R.id.izena);
		mDeskribapena = (EditText) findViewById(R.id.deskribapena);
		mData = (EditText) findViewById(R.id.noiz);
		mOrdua = (EditText) findViewById(R.id.ordua);

		eIzena = (TextView) findViewById(R.id.eIzena);
		eDeskribapena = (TextView) findViewById(R.id.eDeskribapena);
		eOrdua = (TextView) findViewById(R.id.eOrdua);
		eEguna = (TextView) findViewById(R.id.eEguna);
		eHilabetea = (TextView) findViewById(R.id.eHilabetea);

		mIzena.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {}
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
			@Override
			public void afterTextChanged(Editable s) {
				mEkintza.izena = s.toString();
				eIzena.setText(mEkintza.izena);
			}
		});

		mDeskribapena.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {}
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
			@Override
			public void afterTextChanged(Editable s) {
				mEkintza.deskribapena = s.toString();
				eDeskribapena.setText(mEkintza.deskribapena);
			}
		});

		mData.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				if (hasFocus) {
					// Setup caldroid to use as dialog
					dialogCaldroidFragment = new CaldroidFragment();
					dialogCaldroidFragment.setCaldroidListener(listener);

					// If activity is recovered from rotation
					final String dialogTag = "CALDROID_DIALOG_FRAGMENT";
					if (state != null) {
						dialogCaldroidFragment.restoreDialogStatesFromKey(
								getSupportFragmentManager(), state,
								"DIALOG_CALDROID_SAVED_STATE", dialogTag);
						Bundle args = dialogCaldroidFragment.getArguments();
						if (args == null) {
							args = new Bundle();
							dialogCaldroidFragment.setArguments(args);
						}
						args.putString(CaldroidFragment.DIALOG_TITLE,
								"Select a date");
						args.putInt(CaldroidFragment.START_DAY_OF_WEEK,
								CaldroidFragment.MONDAY);
					} else {
						// Setup arguments
						Bundle bundle = new Bundle();
						// Setup dialogTitle
						bundle.putString(CaldroidFragment.DIALOG_TITLE,
								"Data aukeratu");
						bundle.putInt(CaldroidFragment.START_DAY_OF_WEEK,
								CaldroidFragment.MONDAY);
						dialogCaldroidFragment.setArguments(bundle);
					}
					setConfiguration();
					dialogCaldroidFragment.show(getSupportFragmentManager(),
							dialogTag);
					setConfiguration();
				}
			}
		});

		mData.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {}
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
			@Override
			public void afterTextChanged(Editable s) {
				mEkintza.noiz = s.toString();
				try {
					//eOrdua.setText(mEkintza.getOrdua());
					eEguna.setText(mEkintza.getEguna());
					eHilabetea.setText(mEkintza.getHilabetea());
				} catch (ParseException e) {
					e.printStackTrace();
				}
				mData.clearFocus();
			}
		});

		mOrdua.addTextChangedListener(new TextWatcher() {
			@Override
			public void onTextChanged(CharSequence s, int start, int before, int count) {}
			@Override
			public void beforeTextChanged(CharSequence s, int start, int count, int after) {}
			@Override
			public void afterTextChanged(Editable s) {
				String hour = "";
				String minutes = "";
				if (s.length() == 5) {
					Pattern p = Pattern.compile("([01]?[0-9]|2[0-3]):[0-5][0-9]", Pattern.CASE_INSENSITIVE);
					Matcher m = p.matcher(s.toString());
					boolean validHour = m.find();

					if (!validHour) {
						Toast.makeText(getBaseContext(), "Ordua gaizki dago", Toast.LENGTH_SHORT).show();
					} else {
						try {
							hour = s.toString().split(":")[0];
							minutes = s.toString().split(":")[1];
							Integer.valueOf(hour);
						} catch (Exception e) {
							e.printStackTrace();
						}
						mEkintza.ordua = s.toString();
						eOrdua.setText(s.toString());
					}
				}
			}
		});

	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		BugSenseHandler.closeSession(EkintzaProposatuActivity.this);
	}
	
	final CaldroidListener listener = new CaldroidListener() {

		@Override
		public void onSelectDate(Date date, View view) {
			selectedDate = new DateTime(date);
			DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd");
			mData.setText(selectedDate.toString(fmt));
			dialogCaldroidFragment.dismiss();
		}

		@Override
		public void onChangeMonth(int month, int year) {}

		@Override
		public void onLongClickDate(Date date, View view) {
			selectedDate = new DateTime(date);
			DateTimeFormatter fmt = DateTimeFormat.forPattern("yyyy-MM-dd");
			mData.setText(selectedDate.toString(fmt));
			dialogCaldroidFragment.dismiss();
		}

		@Override
		public void onCaldroidViewCreated() {}

	};

	private void setConfiguration() {
		Calendar cal = Calendar.getInstance();

		// Min date is last 7 days
		Date minDate = cal.getTime();

		// Max date is next 7 days
		cal = Calendar.getInstance();
		cal.add(Calendar.YEAR, 1);
		Date maxDate = cal.getTime();

		dialogCaldroidFragment.setMinDate(minDate);
		dialogCaldroidFragment.setMaxDate(maxDate);
		dialogCaldroidFragment.refreshView();
	}

	/**
	 * Save current states of the Caldroid here
	 */
	@Override
	protected void onSaveInstanceState(Bundle outState) {
		// TODO Auto-generated method stub
		super.onSaveInstanceState(outState);

		if (dialogCaldroidFragment != null) {
			dialogCaldroidFragment.saveStatesToKey(outState,
					"DIALOG_CALDROID_SAVED_STATE");
		}
	}

	public void proposeEvent() {
		RequestParams proposeParams = new RequestParams();
		proposeParams.put("uuid", JaigiroAPI.getGCMRegid(getBaseContext()));
		proposeParams.put("idJai", mFesta.id.toString());
		proposeParams.put("izena", mEkintza.izena);
		proposeParams.put("deskribapena", mEkintza.deskribapena);
		proposeParams.put("noiz", mEkintza.getFullDate());
		proposeParams.put("idFb", JaigiroAPI.getIdFacebook(getBaseContext()).toString());
		proposeParams.put("idTw", JaigiroAPI.getIdTwitter(getBaseContext()).toString());
		proposeParams.put("device", "android");

		JaigiroAPI.post(JaigiroAPI.PROPOSE_EVENT, proposeParams, new JsonHttpResponseHandler(){

			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					mDialog.dismiss();
					Toast.makeText(getBaseContext(), "Zure proposamena biali egin da. Eskerrik asko.",  Toast.LENGTH_LONG).show();
					finishWithResult();
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

	private void finishWithResult() {
		Intent intent = new Intent();
		Bundle conData = new Bundle();
		conData.putParcelable("festa", mFesta);
		intent.putExtras(conData);
		setResult(RESULT_OK, intent);
		finish();
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			this.finish();
			return true;
		case R.id.add:
			mDialog.show();
			proposeEvent();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.ekintza_proposatu, menu);
		return true;
	}

}
