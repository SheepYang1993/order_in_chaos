import 'package:flutter/material.dart';
import 'package:order_in_chaos/widget/order_in_chaos_view.dart';

import '../widget/coordinate_view.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('混沌中的秩序'),
      ),
      body: Stack(
        children: [
          CoordinateView(),
          const OrderInChaosView(),
        ],
      ),
    );
  }
}
