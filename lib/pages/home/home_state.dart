import 'dart:async';

import '../../widget/order_in_chaos_view.dart';

class HomeState {
  OrderInChaosController controller = OrderInChaosController();
  double timerTick = 50;
  double dotSize = 5;
  double lineWidth = 2;
  Timer? timer;
}
