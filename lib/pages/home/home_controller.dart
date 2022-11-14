import 'dart:async';

import 'package:get/get.dart';

import 'home_state.dart';

class HomeController extends GetxController {
  HomeState state = HomeState();

  set timerTick(double timerTick) {
    state.timerTick = timerTick;
    stopChange();
    update();
  }

  set dotSize(double dotSize) {
    state.dotSize = dotSize;
    update();
  }

  set lineWidth(double lineWidth) {
    state.lineWidth = lineWidth;
    update();
  }

  /// 创建计时器，不断地计算中间值
  void startChange() {
    if (state.timer != null) {
      return;
    }
    state.timer = Timer.periodic(
        Duration(milliseconds: state.timerTick.toInt()), (Timer timer) {
      state.timer = timer;
      state.controller.changeAllPoint();
      update();
    });
    state.controller.changeAllPoint();
    update();
  }

  /// 停止计时器
  void stopChange() {
    state.timer?.cancel();
    state.timer = null;
    update();
  }

  @override
  void onClose() {
    state.timer?.cancel();
    super.onClose();
  }

  void clearPoints() {
    state.controller.clearPoints();
    stopChange();
  }
}
