import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_in_chaos/widget/order_in_chaos_view.dart';

import '../../widget/coordinate_view.dart';
import 'home_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      assignId: true,
      init: HomeController(),
      builder: (HomeController controller) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('混沌中的秩序'),
            actions: [
              IconButton(
                tooltip: '清除画板',
                icon: const Icon(Icons.refresh),
                onPressed: () {
                  controller.state.controller.clearPoints();
                },
              ),
            ],
          ),
          // drawer: const Drawer(
          //   child: Center(
          //     child: Text('菜单'),
          //   ),
          // ),
          body: Stack(
            children: [
              TextField(
                controller: TextEditingController(),
              ),
              CoordinateView(),
              OrderInChaosView(
                controller: controller.state.controller,
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: FloatingActionButton(
                          tooltip: '移除1个点',
                          onPressed: () {
                            controller.state.controller.removePoint();
                          },
                          child: const Icon(Icons.remove),
                        ),
                      ),
                      Expanded(
                        child: FloatingActionButton(
                          tooltip: '取2点中间值，开始变化',
                          onPressed: () {
                            controller.state.controller.changeAllPoint();
                          },
                          child: const Icon(Icons.play_arrow),
                        ),
                      ),
                      Expanded(
                        child: FloatingActionButton(
                          tooltip: '添加1个点',
                          onPressed: () {
                            controller.state.controller.addPoint();
                          },
                          child: const Icon(Icons.add),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
