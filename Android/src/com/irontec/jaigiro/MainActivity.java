package com.irontec.jaigiro;

import com.bugsense.trace.BugSenseHandler;
import com.irontec.jaigiro.adapters.MenuListAdapter;
import com.irontec.jaigiro.adapters.MenuListBottomAdapter;
import com.irontec.jaigiro.fragments.AboutFragment;
import com.irontec.jaigiro.fragments.EgutegiaFragment;
import com.irontec.jaigiro.fragments.EzarpenakFragment;
import com.irontec.jaigiro.fragments.HasieraFragment;
import com.irontec.jaigiro.fragments.InguruaFragment;
import com.irontec.jaigiro.fragments.MapaFragment;
import com.irontec.jaigiro.helpers.FacebookHelper;
import com.irontec.jaigiro.helpers.TwitterHelper;
import com.irontec.jaigiro.mobhawk.MobHawk;

import android.os.Bundle;
import android.support.v4.app.ActionBarDrawerToggle;
import android.support.v4.app.FragmentTransaction;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.view.Window;
import android.widget.AbsListView;
import android.widget.AdapterView;
import android.widget.ListView;
import android.widget.RelativeLayout;
import android.content.Intent;
import android.content.res.Configuration;

public class MainActivity extends ActionBarActivity {

	// Declare Variable
	DrawerLayout mDrawerLayout;
	ListView mDrawerList;
	ListView mDrawerListBottom;
	ActionBarDrawerToggle mDrawerToggle;
	MenuListAdapter mMenuAdapter;
	MenuListBottomAdapter mMenuBottomAdapter;
	String[] title;
	String[] titleBottom;
	String[] subtitle;
	private RelativeLayout mRelativeLayout;
	int[] icon;
	int[] icon2;
	private MobHawk mhu = MobHawk.getInstance(); 

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		supportRequestWindowFeature(Window.FEATURE_INDETERMINATE_PROGRESS);
		BugSenseHandler.initAndStartSession(MainActivity.this, "4d58588c");
		setContentView(R.layout.activity_main);

		title = new String[] { "", "Hasiera", "Mapa", "Ingurua", "Egutegia" };
		titleBottom = new String[] { "Zer da Jaigiro", "Saioa amaitu" };

		// subtitle = new String[] { "Subtitle Fragment 1",
		// "Subtitle Fragment 2",
		// "Subtitle Fragment 3" };

		icon = new int[] { R.drawable.rounded17, R.drawable.rounded17, R.drawable.flag19,
				R.drawable.sphere, R.drawable.calendar31 };
		icon2 = new int[] { R.drawable.personal3, R.drawable.power15};

		mDrawerLayout = (DrawerLayout) findViewById(R.id.drawer_layout);
		mRelativeLayout = (RelativeLayout) findViewById(R.id.relative_layout);

		mDrawerList = (ListView) findViewById(R.id.left_drawer);
		mDrawerList.setChoiceMode(AbsListView.CHOICE_MODE_SINGLE);

		mDrawerListBottom = (ListView) findViewById(R.id.left_drawer_bottom);
		mDrawerListBottom.setChoiceMode(AbsListView.CHOICE_MODE_SINGLE);

		mDrawerLayout.setDrawerShadow(R.drawable.drawer_shadow,
				GravityCompat.START);

		mMenuAdapter = new MenuListAdapter(this, title, icon);
		mMenuBottomAdapter = new MenuListBottomAdapter(this, titleBottom, icon2);

		mDrawerList.setAdapter(mMenuAdapter);
		mDrawerListBottom.setAdapter(mMenuBottomAdapter);

		mDrawerList.setOnItemClickListener(new DrawerItemClickListener());
		mDrawerListBottom.setOnItemClickListener(new DrawerBottomItemClickListener());

		getSupportActionBar().setHomeButtonEnabled(true);
		getSupportActionBar().setDisplayHomeAsUpEnabled(true);
		getSupportActionBar().setDisplayShowTitleEnabled(false);

		mDrawerToggle = new ActionBarDrawerToggle(this, mDrawerLayout,
				R.drawable.ic_drawer, R.string.drawer_open,
				R.string.drawer_close) {

			public void onDrawerClosed(View view) {
				super.onDrawerClosed(view);
			}

			public void onDrawerOpened(View drawerView) {
				super.onDrawerOpened(drawerView);
			}
		};

		mDrawerLayout.setDrawerListener(mDrawerToggle);

		if (savedInstanceState == null) {
			selectItem(1);
		}
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		BugSenseHandler.closeSession(MainActivity.this);
	}

	public void activateProgressBar(boolean activate) {
		setSupportProgressBarIndeterminateVisibility(activate);
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.main, menu);
		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {

		if (item.getItemId() == android.R.id.home) {

			if (mDrawerLayout.isDrawerOpen(mRelativeLayout)) {
				mDrawerLayout.closeDrawer(mRelativeLayout);
			} else {
				mDrawerLayout.openDrawer(mRelativeLayout);
			}
		}

		return super.onOptionsItemSelected(item);
	}

	private class DrawerItemClickListener implements
	ListView.OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
			selectItem(position);
		}
	}

	private class DrawerBottomItemClickListener implements
	ListView.OnItemClickListener {
		@Override
		public void onItemClick(AdapterView<?> parent, View view, int position, long id) {
			selectItemBottom(position);
		}
	}

	private void selectItem(int position) {
		FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
		switch (position) {
		case 1:
			ft.replace(R.id.content_frame, new HasieraFragment());
			break;
		case 2:
			ft.replace(R.id.content_frame, new MapaFragment());
			break;
		case 3:
			ft.replace(R.id.content_frame, new InguruaFragment());
			break;
		case 4:
			ft.replace(R.id.content_frame, new EgutegiaFragment());
			break;
		case 5:
			ft.replace(R.id.content_frame, new EzarpenakFragment());
			break;
		}
		ft.commit();
		mDrawerList.setItemChecked(position, true);
		mDrawerLayout.closeDrawer(mRelativeLayout);
	}
	
	private void selectItemBottom(int position) {
		FragmentTransaction ft = getSupportFragmentManager().beginTransaction();
		switch (position) {
		case 0:
			ft.replace(R.id.content_frame, new AboutFragment());
			break;
		case 1:
			TwitterHelper.disconnectTwitter(getBaseContext());
			FacebookHelper.disconnectFacebook(getBaseContext());
			Intent intent = new Intent(this, LoginActivity.class);
			intent.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP | Intent.FLAG_ACTIVITY_NEW_TASK);
			startActivity(intent);
			break;
		}
		ft.commit();
		mDrawerListBottom.setItemChecked(position, true);
		mDrawerLayout.closeDrawer(mRelativeLayout);
	}

	@Override
	protected void onPostCreate(Bundle savedInstanceState) {
		super.onPostCreate(savedInstanceState);
		mDrawerToggle.syncState();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
		mDrawerToggle.onConfigurationChanged(newConfig);
	}

}