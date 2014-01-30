package com.irontec.jaigiro;

import java.util.Calendar;
import java.util.Date;
import org.joda.time.DateTime;
import org.joda.time.format.DateTimeFormat;
import org.joda.time.format.DateTimeFormatter;

import com.bugsense.trace.BugSenseHandler;
import com.irontec.jaigiro.helpers.ApplicationSettings;
import com.roomorama.caldroid.CaldroidFragment;
import com.roomorama.caldroid.CaldroidListener;

import android.os.Bundle;
import android.support.v7.app.ActionBar;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.ImageView;
import android.widget.SeekBar;
import android.widget.SeekBar.OnSeekBarChangeListener;
import android.widget.TextView;

public class PreferencesActivity extends ActionBarActivity implements OnSeekBarChangeListener {

	private static final String TAG = PreferencesActivity.class.getSimpleName();
	private static final Integer SEEKBAR_MIN_VALUE = 50;
	private ActionBar mActionBar;
	private SeekBar mSeekBar;
	private TextView mData;
	private TextView mDistance;
	private ImageView mCalendar;
	static final int DATE_DIALOG_ID = 0;
	private CaldroidFragment dialogCaldroidFragment;
	private DateTime selectedDate = new DateTime(new Date());

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		BugSenseHandler.initAndStartSession(PreferencesActivity.this, "4d58588c");
		setContentView(R.layout.activity_map_preferences);

		final Bundle state = savedInstanceState;

		mActionBar = getSupportActionBar();
		mActionBar.setDisplayHomeAsUpEnabled(true);

		mSeekBar = (SeekBar) findViewById(R.id.seekBar1);
		mData = (TextView) findViewById(R.id.data);
		mCalendar = (ImageView) findViewById(R.id.imageview2);
		mDistance = (TextView) findViewById(R.id.textView3);

		// Setup listener
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

		mCalendar.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
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

		});

		mSeekBar.setOnSeekBarChangeListener(this);
	}

	@Override
	protected void onDestroy() {
		super.onDestroy();
		BugSenseHandler.closeSession(PreferencesActivity.this);
	}
	
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

	@Override
	public void onProgressChanged(SeekBar seekBar, int progress,
			boolean fromUser) {
		if (progress<SEEKBAR_MIN_VALUE) {
			progress = SEEKBAR_MIN_VALUE;
			seekBar.setProgress(SEEKBAR_MIN_VALUE);
		}
		mDistance.setText(progress +"km");
	}

	@Override
	public void onStartTrackingTouch(SeekBar seekBar) {}

	@Override
	public void onStopTrackingTouch(SeekBar seekBar) {}

	public void saveValues() {
		ApplicationSettings.setMaxSearchDate(getBaseContext(), selectedDate.getMillis());
		ApplicationSettings.setMaxSearchDistance(getBaseContext(), Long.valueOf(mSeekBar.getProgress()));
	}

	@Override
	public void onBackPressed() {
		super.onBackPressed();
		saveValues();
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.map_preferences, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		switch (item.getItemId()) {
		case android.R.id.home:
			saveValues();
			this.finish();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

}
