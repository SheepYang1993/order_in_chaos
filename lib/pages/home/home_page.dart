import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:order_in_chaos/widget/order_in_chaos_view.dart';

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
                  controller.clearPoints();
                },
              ),
            ],
          ),
          drawer: Drawer(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: kToolbarHeight),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text('刷新间隔(${controller.state.timerTick.toInt()}毫秒)'),
                ),
                Slider(
                  label: '刷新间隔(${controller.state.timerTick.toInt()}毫秒)',
                  max: 990,
                  min: 0,
                  divisions: 991,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue[100],
                  value: controller.state.timerTick - 10,
                  onChanged: (double value) {
                    controller.timerTick = 10 + value;
                  },
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text('圆点大小(${controller.state.dotSize.toInt()})'),
                ),
                Slider(
                  label: '圆点大小(${controller.state.dotSize.toInt()})',
                  max: 50,
                  min: 1,
                  divisions: 51,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue[100],
                  value: controller.state.dotSize,
                  onChanged: (double value) {
                    controller.dotSize = value;
                  },
                ),
                const SizedBox(height: 30),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 15),
                  child: Text('连线粗细(${controller.state.lineWidth.toInt()})'),
                ),
                Slider(
                  label: '连线粗细(${controller.state.lineWidth.toInt()})',
                  max: 50,
                  min: 1,
                  divisions: 51,
                  activeColor: Colors.blue,
                  inactiveColor: Colors.blue[100],
                  value: controller.state.lineWidth,
                  onChanged: (double value) {
                    controller.lineWidth = value;
                  },
                ),
              ],
            ),
          ),
          body: Stack(
            children: [
              OrderInChaosView(
                controller: controller.state.controller,
                dotSize: controller.state.dotSize,
                lineWidth: controller.state.lineWidth,
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
                            if (controller.state.timer == null) {
                              controller.startChange();
                            } else {
                              controller.stopChange();
                            }
                          },
                          child: (controller.state.timer == null)
                              ? const Icon(Icons.play_arrow)
                              : const Icon(Icons.pause),
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
