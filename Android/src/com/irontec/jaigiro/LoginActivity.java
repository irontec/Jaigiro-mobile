package com.irontec.jaigiro;


import twitter4j.Twitter;
import twitter4j.TwitterException;
import twitter4j.TwitterFactory;
import twitter4j.User;
import twitter4j.auth.AccessToken;
import twitter4j.auth.RequestToken;
import twitter4j.conf.Configuration;
import twitter4j.conf.ConfigurationBuilder;

import com.bugsense.trace.BugSenseHandler;
import com.irontec.jaigiro.api.JaigiroAPI;
import com.irontec.jaigiro.helpers.ApplicationSettings;
import com.irontec.jaigiro.helpers.FacebookHelper;
import com.irontec.jaigiro.helpers.TwitterHelper;
import com.irontec.jaigiro.mobhawk.MobHawk;
import com.sromku.simple.fb.SimpleFacebook;
import com.sromku.simple.fb.entities.Profile;
import com.sromku.simple.fb.utils.Logger;

import android.os.Bundle;
import android.os.Handler;
import android.os.Message;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.app.Dialog;
import android.content.Intent;
import android.content.SharedPreferences.Editor;
import android.content.pm.PackageManager.NameNotFoundException;
import android.support.v7.app.ActionBarActivity;
import android.util.Log;
import android.view.Menu;
import android.view.View;
import android.view.Window;
import android.view.View.OnClickListener;
import android.view.animation.Animation;
import android.view.animation.Animation.AnimationListener;
import android.view.animation.AnimationUtils;
import android.widget.Button;
import android.widget.LinearLayout;

import com.sromku.simple.fb.Properties;

public class LoginActivity extends ActionBarActivity implements OnClickListener {

	private final static String TAG = LoginActivity.class.getSimpleName();
	private static final int TWITTER_AUTH = 110;
	private Button mFacebook;
	private Button mTwitter;
	private Button mGuest;
	private SimpleFacebook mSimpleFacebook;
	private static Twitter twitter;
	private static RequestToken requestToken;
	private MobHawk mhu = MobHawk.getInstance();
	private Dialog mDialog;
	private LinearLayout mButtonsLayout;
	private Animation fadeOut;
    private Animation fadeIn;
    
	@SuppressLint("HandlerLeak")
	private Handler mHandler = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			if (!mhu.isBlocked()) {
				runFadeInAnimation(LoginActivity.this, mButtonsLayout);
				JaigiroAPI.registerGCM(LoginActivity.this, mHandlerFb);
			} else {
				mDialog.dismiss();
				runFadeOutAnimation(LoginActivity.this, mButtonsLayout);
			}
			mhu.takeActions();
		}
	};

	@SuppressLint("HandlerLeak")
	private Handler mHandlerFb = new Handler() {
		@Override
		public void handleMessage(Message msg) {
			mFacebook.setOnClickListener(LoginActivity.this);
			mTwitter.setOnClickListener(LoginActivity.this);
			mGuest.setOnClickListener(LoginActivity.this);
			mDialog.dismiss();
		}
	};

	public void runFadeOutAnimation(Activity ctx, final View target) {
		fadeOut.setAnimationListener(new AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
            }

            @Override
            public void onAnimationRepeat(Animation animation) {
            }

            @Override
            public void onAnimationEnd(Animation animation) {
            	target.setVisibility(View.INVISIBLE);
            }
        });
		target.startAnimation(fadeOut);
	}
	public void runFadeInAnimation(Activity ctx, final View target) {
		fadeIn.setAnimationListener(new AnimationListener() {
            @Override
            public void onAnimationStart(Animation animation) {
            }

            @Override
            public void onAnimationRepeat(Animation animation) {
            }

            @Override
            public void onAnimationEnd(Animation animation) {
            	target.setVisibility(View.INVISIBLE);
            }
        });
		target.startAnimation(fadeIn);
		target.setVisibility(View.VISIBLE);
	}

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		BugSenseHandler.initAndStartSession(LoginActivity.this, "4d58588c");
		setContentView(R.layout.activity_login);

		Logger.DEBUG = true;

		getSupportActionBar().hide();

		fadeOut = AnimationUtils.loadAnimation(LoginActivity.this, R.anim.fade_out);
		fadeIn = AnimationUtils.loadAnimation(LoginActivity.this, R.anim.fade_in);
		
		mDialog = new Dialog(this);
		mDialog.requestWindowFeature((int) Window.FEATURE_NO_TITLE);
		mDialog.setCancelable(false);
		mDialog.setContentView(R.layout.dialog_simple_loading);


		mFacebook = (Button) findViewById(R.id.facebook);
		mTwitter = (Button) findViewById(R.id.twitter);
		mGuest = (Button) findViewById(R.id.guest);

		mButtonsLayout = (LinearLayout) findViewById(R.id.buttonsLayout);
		
		mhu.setActivity(LoginActivity.this);

		try {
			mDialog.show();
			mhu.call("jaigiro-android", MobHawk.getAppVersionCode(LoginActivity.this).toString(), mHandler);
		} catch (NameNotFoundException e) {
			e.printStackTrace();
		}

	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		BugSenseHandler.closeSession(LoginActivity.this);
	}

	@Override
	protected void onResume() {
		super.onResume();
		mSimpleFacebook = FacebookHelper.getSimpleFacebookInstance(this);
	}

	@Override
	protected void onActivityResult(int requestCode, int resultCode, Intent data) {
		mSimpleFacebook.onActivityResult(this, requestCode, resultCode, data); 
		super.onActivityResult(requestCode, resultCode, data);

		if (requestCode == TWITTER_AUTH) {
			if (resultCode == Activity.RESULT_OK) {
				final String oauthVerifier = (String) data.getExtras().get("oauth_verifier");
				if (oauthVerifier != null && oauthVerifier != "") {
					new Thread(new Runnable() {
						AccessToken accessToken = null;
						public void run() {
							try {
								accessToken = twitter.getOAuthAccessToken(requestToken, oauthVerifier);
								Editor e = TwitterHelper.getTwitterPrerefencesEditor(getBaseContext());
								User user = twitter.showUser(accessToken.getScreenName());
								JaigiroAPI.setIdTwitter(user.getId(), user.getName(), user.getProfileImageURLHttps(), getBaseContext());
								e.putString(TwitterHelper.PREF_KEY_TOKEN, accessToken.getToken()); 
								e.putString(TwitterHelper.PREF_KEY_SECRET, accessToken.getTokenSecret()); 
								e.commit();
							} catch (TwitterException e) {
								mDialog.dismiss();
								e.printStackTrace();
							}
							login(false);
						}
					}).start();
				}
			}
		}
	} 

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		getMenuInflater().inflate(R.menu.login, menu);
		return true;
	}

	@Override
	public void onClick(View view) {
		mDialog.show();
		if (view.getId() == R.id.facebook) {
			FacebookMining();
		} else if (view.getId() == R.id.twitter) {
			TwitterMining();
		} else {
			login(true);
		}
	}

	private void FacebookMining() {
		if (!mSimpleFacebook.isLogin()) {
			mSimpleFacebook.login(new SimpleFacebook.OnLoginListener() {
				@Override
				public void onFail(String reason) { mDialog.dismiss(); Log.w(TAG, reason); }
				@Override
				public void onException(Throwable throwable) { mDialog.dismiss(); Log.e(TAG, "Bad thing happened", throwable); }
				@Override
				public void onThinking() { Log.i(TAG, "In progress"); }
				@Override
				public void onLogin() {

					Properties properties = new Properties.Builder()
					.add(Properties.ID)
					.add(Properties.NAME)
					.add(Properties.PICTURE)
					.build();

					mSimpleFacebook.getProfile(properties, new SimpleFacebook.OnProfileRequestListener() {
						@Override
						public void onFail(String reason) { mDialog.dismiss(); Log.w(TAG, reason); }
						@Override
						public void onException(Throwable throwable) { mDialog.dismiss(); Log.e(TAG, "Bad thing happened", throwable); }
						@Override
						public void onThinking() { Log.i(TAG, "Thinking..."); }
						@Override
						public void onComplete(Profile profile) {
							Log.d(TAG, profile.getPicture());
							JaigiroAPI.setIdFacebook(Long.valueOf(profile.getId()), profile.getName(), profile.getPicture(), getBaseContext());
							login(false);
						}
					});
				}
				@Override
				public void onNotAcceptingPermissions() { Log.w(TAG, "User didn't accept read permissions"); }
			});
		} else {

			Properties properties = new Properties.Builder()
			.add(Properties.ID)
			.add(Properties.NAME)
			.add(Properties.PICTURE)
			.build();

			mSimpleFacebook.getProfile(properties, new SimpleFacebook.OnProfileRequestListener() {
				@Override
				public void onFail(String reason) { mDialog.dismiss(); Log.w(TAG, reason); }
				@Override
				public void onException(Throwable throwable) { mDialog.dismiss(); Log.e(TAG, "Bad thing happened", throwable); }
				@Override
				public void onThinking() { Log.i(TAG, "Thinking..."); }
				@Override
				public void onComplete(Profile profile) {
					Log.d(TAG, profile.getPicture());
					JaigiroAPI.setIdFacebook(Long.valueOf(profile.getId()), profile.getName(), profile.getPicture(), getBaseContext());
					login(false);
				}
			});
		}
	}

	private void TwitterMining() {
		if (!TwitterHelper.isConnected(getBaseContext())) {
			new Thread(new Runnable() {
				public void run() {
					ConfigurationBuilder configurationBuilder = new ConfigurationBuilder();
					configurationBuilder.setOAuthConsumerKey(TwitterHelper.CONSUMER_KEY);
					configurationBuilder.setOAuthConsumerSecret(TwitterHelper.CONSUMER_SECRET);
					Configuration configuration = configurationBuilder.build();
					twitter = new TwitterFactory(configuration).getInstance();

					try {
						requestToken = twitter.getOAuthRequestToken(TwitterHelper.CALLBACK_URL);
						Intent i = new Intent(LoginActivity.this, WebViewActivity.class);
						i.putExtra("URL", requestToken.getAuthenticationURL());
						startActivityForResult(i, TWITTER_AUTH);
					} catch (TwitterException e) {
						mDialog.dismiss();
						e.printStackTrace();
					}
				}
			}).start();
		} else {
			login(false);
		}

	}

	private void login(Boolean isGuest) {
		Intent intent = new Intent(getBaseContext(), MainActivity.class);
		ApplicationSettings.setIsGuestMode(getBaseContext(), isGuest);
		mDialog.dismiss();
		startActivity(intent);
	}

}
