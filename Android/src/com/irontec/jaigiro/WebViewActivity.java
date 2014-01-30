package com.irontec.jaigiro;

import com.bugsense.trace.BugSenseHandler;
import com.google.analytics.tracking.android.EasyTracker;
import com.irontec.jaigiro.helpers.TwitterHelper;

import android.net.Uri;
import android.os.Bundle;
import android.app.Activity;
import android.content.Intent;
import android.view.Menu;
import android.webkit.WebView;
import android.webkit.WebViewClient;

public class WebViewActivity extends Activity {

	@Override
	public void onStart() {
		super.onStart();
	}
	
	@Override
	public void onStop() {
		super.onStop();
	}
	
	@Override
	protected void onDestroy() {
		super.onDestroy();
		BugSenseHandler.closeSession(WebViewActivity.this);
	}
	
	private Intent mIntent;
	public void onCreate(Bundle savedInstanceState)
	{
		super.onCreate(savedInstanceState);
		BugSenseHandler.initAndStartSession(WebViewActivity.this, "4d58588c");
		setContentView(R.layout.activity_web_view);
		mIntent = getIntent();
		String url = (String)mIntent.getExtras().get("URL");
		WebView webView = (WebView) findViewById(R.id.webview);
		webView.setWebViewClient( new WebViewClient() {
			@Override
			public boolean shouldOverrideUrlLoading(WebView view, String url) {
				if( url.contains(TwitterHelper.CALLBACK_URL)) {
					Uri uri = Uri.parse( url );
					String oauthVerifier = uri.getQueryParameter( "oauth_verifier" );
					mIntent.putExtra( "oauth_verifier", oauthVerifier );
					setResult( RESULT_OK, mIntent );
					finish();
					return true;
				}
				return false;
			}
		});
		webView.loadUrl(url);
	}

}
