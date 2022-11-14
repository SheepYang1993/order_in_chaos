import 'dart:async';

import '../../widget/order_in_chaos_view.dart';

class HomeState {
  OrderInChaosController controller = OrderInChaosController();
  double timerTick = 10;
  Timer? timer;
}
