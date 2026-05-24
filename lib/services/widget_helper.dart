import 'package:flutter/services.dart';

class WidgetHelper {
  static const MethodChannel _channel = MethodChannel('id.awni.money/widget');

  static Future<void> triggerUpdate() async {
    try {
      await _channel.invokeMethod('updateWidget');
    } on PlatformException catch (e) {
      print("Error updating homescreen widget: ${e.message}");
    }
  }
}
