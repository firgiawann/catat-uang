package id.awni.money

import android.content.Intent
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "id.awni.money/widget"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "updateWidget") {
                val intent = Intent("id.awni.money.UPDATE_WIDGET")
                intent.setPackage(packageName)
                sendBroadcast(intent)
                result.success(true)
            } else {
                result.notImplemented()
            }
        }
    }
}
