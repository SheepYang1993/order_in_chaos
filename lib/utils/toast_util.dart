import 'package:flutter/foundation.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(String msg) {
  if (!kIsWeb) {
    Fluttertoast.cancel();
  }
  Fluttertoast.showToast(
    msg: msg,
    gravity: ToastGravity.CENTER,
  );
}
