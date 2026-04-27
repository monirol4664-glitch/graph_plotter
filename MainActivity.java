package com.attendance.digital;

import android.app.Activity;
import android.content.Intent;
import android.net.Uri;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.provider.Settings;
import android.util.Base64;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.widget.Toast;
import android.media.MediaScannerConnection;
import java.io.File;
import java.io.FileOutputStream;

public class MainActivity extends Activity {
    private FileSaverBridge fileSaver;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        WebView webView = new WebView(this);
        webView.getSettings().setJavaScriptEnabled(true);
        webView.getSettings().setDomStorageEnabled(true);
        webView.getSettings().setAllowFileAccess(true);
        webView.setWebViewClient(new WebViewClient());

        fileSaver = new FileSaverBridge();
        webView.addJavascriptInterface(fileSaver, "AndroidFileSaver");

        webView.loadUrl("file:///android_asset/index.html");
        setContentView(webView);

        // Request storage permission on first launch
        checkAndRequestStoragePermission();
    }

    @Override
    protected void onResume() {
        super.onResume();
        checkAndRequestStoragePermission();
    }

    private void checkAndRequestStoragePermission() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            if (!Environment.isExternalStorageManager()) {
                Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                intent.setData(Uri.parse("package:" + getPackageName()));
                startActivity(intent);
                Toast.makeText(this, "⚠️ Please enable 'Allow access to manage all files'", Toast.LENGTH_LONG).show();
            }
        }
    }

    private class FileSaverBridge {
        @JavascriptInterface
        public void saveFile(String fileName, String base64Data, String mimeType) {
            // Block if permission not granted on Android 11+
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R && !Environment.isExternalStorageManager()) {
                runOnUiThread(() -> Toast.makeText(MainActivity.this, "❌ Storage permission denied. Enable in Settings.", Toast.LENGTH_LONG).show());
                return;
            }

            try {
                byte[] data = Base64.decode(base64Data, Base64.NO_WRAP);

                // Save to PUBLIC Downloads folder (visible to all file managers)
                File dir = new File(Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_DOWNLOADS), "AttendanceApp");
                if (!dir.exists()) dir.mkdirs();

                File file = new File(dir, fileName);
                FileOutputStream fos = new FileOutputStream(file);
                fos.write(data);
                fos.close();

                // Notify system so file appears immediately without reboot
                MediaScannerConnection.scanFile(MainActivity.this,
                        new String[]{file.getAbsolutePath()}, null, null);

                runOnUiThread(() ->
                        Toast.makeText(MainActivity.this, "✅ Saved to Downloads/AttendanceApp/" + fileName, Toast.LENGTH_LONG).show());
            } catch (Exception e) {
                runOnUiThread(() ->
                        Toast.makeText(MainActivity.this, "❌ Save failed: " + e.getMessage(), Toast.LENGTH_LONG).show());
            }
        }
    }
}