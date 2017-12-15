package example.mj.js2android;

import android.content.Context;
import android.os.Build;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.View;
import android.webkit.JavascriptInterface;
import android.webkit.WebView;
import android.widget.Toast;

import java.util.Locale;

public class MainActivity extends AppCompatActivity {

    private WebView webView;
    private String jsInterfaceNamespace = "AndroidInterface";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.activity_main);

        findViewById(R.id.button).setOnClickListener(MainActivity.this::onBtnClick);

        webView = findViewById(R.id.webView);
        webView.getSettings().setJavaScriptEnabled(true);

        // for js debug
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            WebView.setWebContentsDebuggingEnabled(true);
        }

        webView.loadUrl("file:///android_asset/web.html");
        webView.addJavascriptInterface(new WebViewJavaScriptInterface(this), jsInterfaceNamespace);
    }

    private void onBtnClick(View v) {
        callJsGetInteger();
    }

    private void callJsGetInteger() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            webView.evaluateJavascript("window.getInteger && window.getInteger()",
                this::jsGetIntegerCallback
            );
        }
    }

    private void jsGetIntegerCallback(String value) {
        int integer = Integer.parseInt(value);

        Toast.makeText(this, String.format("value from JS: [%d]", integer), Toast.LENGTH_SHORT).show();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();

        webView.removeJavascriptInterface(jsInterfaceNamespace);
    }

    public static class WebViewJavaScriptInterface {

        private Context context;

        public WebViewJavaScriptInterface(Context context) {
            this.context = context;
        }

        /*
         * This method can be called from Android. @JavascriptInterface
         * required after SDK version 17.
         */
        @JavascriptInterface
        public void showToast(String message, boolean lengthLong) {
            Toast.makeText(context, message, (lengthLong ? Toast.LENGTH_LONG : Toast.LENGTH_SHORT)).show();
        }

        @JavascriptInterface
        public void showLog(String message, int value) {
            Log.i("FromJS", String.format("string message: %s, int value: %d", message, value));
        }

        @JavascriptInterface
        public String getMessage() {
            return String.format(Locale.getDefault(), "message: [%d]", (int)(Math.random() * 100 + 1));
        }
    }
}
