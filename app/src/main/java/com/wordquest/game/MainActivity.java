package com.wordquest.game;
import android.app.Activity;
import android.os.Bundle;
import android.webkit.WebView;
import android.webkit.WebSettings;
import android.webkit.WebViewClient;
import android.view.KeyEvent;
public class MainActivity extends Activity {
 private WebView web;
 @Override public void onCreate(Bundle savedInstanceState){
  super.onCreate(savedInstanceState);
  web=new WebView(this);
  WebSettings s=web.getSettings();
  s.setJavaScriptEnabled(true); s.setDomStorageEnabled(true);
  s.setAllowFileAccess(true); s.setAllowContentAccess(false);
  s.setSupportZoom(false); s.setBuiltInZoomControls(false);
  web.setWebViewClient(new WebViewClient());
  web.setFocusableInTouchMode(true);
  setContentView(web);
  if(savedInstanceState!=null) web.restoreState(savedInstanceState);
  else web.loadUrl("file:///android_asset/index.html");
 }
 @Override protected void onSaveInstanceState(Bundle out){if(web!=null)web.saveState(out);super.onSaveInstanceState(out);}
 @Override public boolean onKeyDown(int keyCode,KeyEvent event){
  if(keyCode==KeyEvent.KEYCODE_BACK && web!=null){web.evaluateJavascript("if(!document.getElementById('game').classList.contains('hidden'))goHome();else if(confirm('Exit WordQuest?')){ }",null);return true;}
  return super.onKeyDown(keyCode,event);
 }
 @Override protected void onDestroy(){if(web!=null){web.stopLoading();web.destroy();}super.onDestroy();}
}