package com.irontec.jaigiro.fragments;

import java.util.ArrayList;
import java.util.Random;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import android.content.Context;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.Menu;
import android.view.MenuInflater;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
import android.view.ViewStub;
import android.widget.BaseAdapter;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.TextView;
import android.widget.ViewSwitcher;

import com.irontec.jaigiro.BilatzaileaActivity;
import com.irontec.jaigiro.FestaActivity;
import com.irontec.jaigiro.MainActivity;
import com.irontec.jaigiro.PreferencesActivity;
import com.irontec.jaigiro.ProposatuActivity;
import com.irontec.jaigiro.R;
import com.irontec.jaigiro.adapters.StaggeredAdapter;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.helpers.ApplicationSettings;
import com.irontec.jaigiro.helpers.Blur;
import com.irontec.jaigiro.helpers.ColorUtils;
import com.irontec.jaigiro.helpers.DateUtils;
import com.irontec.jaigiro.helpers.ImageLoader;
import com.irontec.jaigiro.helpers.ScaleImageView;
import com.irontec.jaigiro.models.Festa;
import com.irontec.jaigiro.widgets.StaggeredGridView;
import com.irontec.jaigiro.widgets.StaggeredGridView.OnScrollListener;
import com.irontec.jaigiro.widgets.StaggeredGridView.LayoutParams;
import com.loopj.android.http.JsonHttpResponseHandler;
import com.loopj.android.http.RequestParams;
import com.squareup.picasso.Picasso;
import com.squareup.picasso.Target;
import com.squareup.picasso.Transformation;
import com.squareup.picasso.Picasso.LoadedFrom;


public class HasieraFragment extends Fragment {

	private final static int OPEN_SETTINGS = 10001;
	private final static int OPEN_SEARCH = 10002;
	private final static String TAG = HasieraFragment.class.getSimpleName();
	private Integer PAGE = 1;
	private Integer ITEMS = 11;

	private Context mContext;

	private View mView;
	private StaggeredGridView mGridView;
	private SGVAdapter mAdapter;
	private ViewSwitcher mSwitcher;
	private ViewStub mStubEmptyFestak;
	private ViewStub mStubGridFestak;
	private Long mMaxTime;
	private Long mMaxDistance;
	private Boolean mNeedsReload = true;
	private Boolean mHasMoreToLoad = false;

	private ArrayList<Festa> mFestak;

	private int mOrriKop;
	private int mFestaKop;

	public HasieraFragment() {}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container,
			Bundle savedInstanceState) {
		mContext = getActivity().getBaseContext();
		mView = inflater.inflate(R.layout.fragment_hasiera, container, false);
		mSwitcher = (ViewSwitcher) mView.findViewById(R.id.viewSwitcher1);
		mStubEmptyFestak = (ViewStub) mView.findViewById(R.id.stubEmptyFestak);
		mStubGridFestak = (ViewStub) mView.findViewById(R.id.stubGridFestak);
		setHasOptionsMenu(true);

		return mView;
	}

	@Override
	public void onResume() {
		super.onResume();
		PAGE = 1;
		loadFestak();
	}

	@Override
	public void onStop() {
		super.onStop();
		mNeedsReload = true;
		mSwitcher.showPrevious();
	}

	public void loadFestak() {
		((MainActivity) getActivity()).activateProgressBar(Boolean.TRUE);
		RequestParams festakParams = new RequestParams();
		//Required
		festakParams.add("uuid", JaigiroAPI.getGCMRegid(mContext));
		//Optionals
		festakParams.add("idFb", JaigiroAPI.getIdFacebook(mContext).toString());
		festakParams.add("idTw", JaigiroAPI.getIdTwitter(mContext).toString());
		festakParams.add("page", PAGE.toString());
		festakParams.add("items", ITEMS.toString());
		festakParams.add("device", "android");
		if(mMaxTime != null)
			festakParams.add("dateLimit", DateUtils.preformatDate(mMaxTime));

		Log.d(TAG, festakParams.toString());

		JaigiroAPI.post(JaigiroAPI.GET_JAIAK, festakParams, new JsonHttpResponseHandler() {
			@Override
			public void onSuccess(int statusCode, JSONObject response) {
				super.onSuccess(statusCode, response);
				try {
					mFestak = new ArrayList<Festa>();
					JSONArray festak = response.getJSONArray("jaiak");
					mOrriKop = response.getInt("orriKop");
					mFestaKop = response.getInt("jaiKop");
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
						loadGrid();
					}
					((MainActivity) getActivity()).activateProgressBar(Boolean.FALSE);
				} catch (JSONException e) {
					((MainActivity) getActivity()).activateProgressBar(Boolean.FALSE);
					e.printStackTrace();
				}

			}
			@Override
			public void onFailure(Throwable e, JSONObject errorResponse) {
				super.onFailure(e, errorResponse);
				((MainActivity) getActivity()).activateProgressBar(Boolean.FALSE);
				e.printStackTrace();
			}
		});
	}

	public void loadGrid() {
		if (mStubGridFestak != null) {
			mStubGridFestak.inflate();
			mStubGridFestak = null;
		}
		mGridView = (StaggeredGridView) mView.findViewById(R.id.staggeredGridView1);
		mGridView.setColumnCount(4);
		mGridView.setOnScrollListener(mScrollListener);
		if (PAGE > 1) {
			mAdapter.addAll(mFestak);
		} else {
			mAdapter = new SGVAdapter(mContext, mFestak);
			mGridView.setAdapter(mAdapter);
		}
		mAdapter.notifyDataSetChanged();
		if (mNeedsReload) {
			mSwitcher.showNext();
			mNeedsReload = false;
		}
		((MainActivity) getActivity()).activateProgressBar(Boolean.FALSE);
	}

	private OnScrollListener mScrollListener = new OnScrollListener() {

		private int mFirstVisibleItem;

		@Override
		public void onScrollStateChanged(ViewGroup view, int scrollState) {
			switch (scrollState) {
			case SCROLL_STATE_IDLE:
				if (mFirstVisibleItem >= mGridView.getItemCount() - 8) {
					PAGE++;
					loadFestak();
				}
				break;
			default:
				break;
			}
		}

		@Override
		public void onScroll(ViewGroup view, int firstVisibleItem, int visibleItemCount, int totalItemCount) {
			mFirstVisibleItem = firstVisibleItem;
		}
	};

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		if (requestCode == OPEN_SETTINGS) {
			mNeedsReload = true;
			mMaxTime = ApplicationSettings.getMaxSearchDate(mContext);
			mMaxDistance = ApplicationSettings.getMaxSearchDistance(mContext);
		}
	}

	public void openSettings() {
		Intent intent = new Intent(mContext, PreferencesActivity.class);
		startActivityForResult(intent, OPEN_SETTINGS);
	}
	public void openSearch() {
		Intent intent = new Intent(mContext, BilatzaileaActivity.class);
		startActivity(intent);
	}
	public void openAdd() {
		Intent intent = new Intent(mContext, ProposatuActivity.class);
		startActivity(intent);
	}

	@Override
	public void onCreateOptionsMenu(Menu menu, MenuInflater inflater) {
		inflater.inflate(R.menu.hasiera, menu);
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
		case R.id.add:
			openAdd();
			return true;
		default:
			return super.onOptionsItemSelected(item);
		}
	}

	private final class SGVAdapter extends BaseAdapter {

		private LayoutInflater mInflater;
		private ArrayList<Festa> festak;

		public SGVAdapter(Context ctx, ArrayList<Festa> _festak) {
			mInflater = LayoutInflater.from(ctx);
			this.festak=_festak;
		}

		@Override
		public int getCount() {
			return this.festak.size();
		}

		@Override
		public Object getItem(int position) {
			return this.festak.get(position);
		}

		@Override
		public long getItemId(int position) {
			return this.festak.get(position).id;
		}

		public void addAll(ArrayList<Festa> newFestak) {
			festak.addAll(newFestak);
		}

		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			LayoutParams lp;
			int span = 2;

			if (position == 0) {
				convertView = mInflater.inflate(R.layout.element_item_large, parent, false);
				span = mGridView.getColumnCount();
			} else {
				convertView = mInflater.inflate(R.layout.element_item, parent, false);
			}

			lp = new LayoutParams(convertView.getLayoutParams());
			lp.span = span;
			convertView.setLayoutParams(lp);

			//			ScaleImageView imageView = (ScaleImageView) convertView .findViewById(R.id.imageView1);
			ImageView imageView = (ImageView) convertView .findViewById(R.id.imageView1);
			ImageView imageHeader = (ImageView) convertView.findViewById(R.id.imageHeader);
			TextView herria = (TextView) convertView.findViewById(R.id.textView1);
			ImageView banator = (ImageView) convertView.findViewById(R.id.mark);

			herria.setText(festak.get(position).izena.toUpperCase());
			imageHeader.setBackgroundColor(ColorUtils.getCustomColorWithoutAlpha(festak.get(position).color, mContext));

			if (festak.get(position).banator) 
				banator.setVisibility(View.VISIBLE);

			if (position == 0) {
				Picasso.with(mContext)
				.load(festak.get(position).thumb)
				.placeholder(R.drawable.placeholder_jaia)
				.error(R.drawable.placeholder_jaia)
				//				.resize(400, 200)
				.fit().centerCrop()
				.into(imageView);
			} else {
				Picasso.with(mContext)
				.load(festak.get(position).thumb)
				.placeholder(R.drawable.placeholder_jaia)
				.error(R.drawable.placeholder_jaia)
				//				.resize(200, 200)
				.fit().centerCrop()
				.into(imageView);
			}

			imageHeader.setTag(position);
			imageHeader.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					int position = (Integer) v.getTag();
					Festa festa = (Festa) mAdapter.getItem(position);
					Intent intent = new Intent(mContext, FestaActivity.class);
					intent.putExtra("festa", festa);
					startActivity(intent);
				}
			});
			imageView.setTag(position);
			imageView.setOnClickListener(new OnClickListener() {
				@Override
				public void onClick(View v) {
					int position = (Integer) v.getTag();
					Festa festa = (Festa) mAdapter.getItem(position);
					Intent intent = new Intent(mContext, FestaActivity.class);
					intent.putExtra("festa", festa);
					startActivity(intent);
				}
			});

			return convertView;
		}
	}

}
