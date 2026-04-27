package com.attendance.digital;

import android.app.Activity;
import android.os.Bundle;
import android.os.Environment;
import android.util.Base64;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import java.io.File;
import java.io.FileOutputStream;

public class MainActivity extends Activity {
    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WebView webView = new WebView(this);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        webView.getSettings().setAllowFileAccess(true);
        webView.setWebViewClient(new WebViewClient());
        
        // JS ↔ Native Storage Bridge
        webView.addJavascriptInterface(new FileSaverBridge(), "AndroidFileSaver");
        
        webView.loadUrl("file:///android_asset/index.html");
        setContentView(webView);
    }

    private class FileSaverBridge {
        @JavascriptInterface
        public void saveFile(String fileName, String base64Data, String mimeType) {
            try {
                byte[] data = Base64.decode(base64Data, Base64.NO_WRAP);
                File dir = new File(getExternalFilesDir(Environment.DIRECTORY_DOWNLOADS), "AttendanceApp");
                if (!dir.exists()) dir.mkdirs();
                
                File file = new File(dir, fileName);
                FileOutputStream fos = new FileOutputStream(file);
                fos.write(data);
                fos.close();
                
                runOnUiThread(() -> 
                    Toast.makeText(MainActivity.this, "✅ Saved to Downloads/AttendanceApp/" + fileName, Toast.LENGTH_LONG).show()
                );
            } catch (Exception e) {
                runOnUiThread(() -> 
                    Toast.makeText(MainActivity.this, "❌ Save failed: " + e.getMessage(), Toast.LENGTH_LONG).show()
                );
            }
        }
    }
}