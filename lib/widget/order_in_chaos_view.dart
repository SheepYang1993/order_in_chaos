import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/toast_util.dart';

class OrderInChaosView extends StatefulWidget {
  final OrderInChaosController? controller;
  final Size? size;

  const OrderInChaosView({
    super.key,
    this.controller,
    this.size,
  });

  @override
  State<OrderInChaosView> createState() => _OrderInChaosViewState();
}

class _OrderInChaosViewState extends State<OrderInChaosView> {
  late Size size;

  @override
  void initState() {
    widget.controller?.addListener(() {});
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = widget.size ??
        Size(
          MediaQuery.of(context).size.width,
          MediaQuery.of(context).size.height,
        );
    widget.controller?.size = size;
    return Scaffold(
      body: CustomPaint(
        size: size,
        painter: OrderInChaos(points: widget.controller?.points),
      ),
    );
  }
}

class OrderInChaos extends CustomPainter {
  List<List<Offset>>? points;

  OrderInChaos({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    if (points?.isNotEmpty ?? false) {
      Paint paint1 = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round
        ..strokeWidth = 6.0
        ..isAntiAlias = true;
      Paint paint2 = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..isAntiAlias = true;
      List<Offset> list = points!.last;
      canvas.drawPoints(PointMode.points, list, paint1);
      Path path = Path();
      path.addPolygon(list, true);
      canvas.drawPath(path, paint2);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class OrderInChaosController extends ChangeNotifier {
  final Random _random = Random();
  List<List<Offset>> points = [];

  late Size size;

  List<Offset> _getPointList() {
    if (points.isEmpty) {
      points.add([]);
    }
    return points.last;
  }

  void clearPoints() {
    for (int i = 0; i < points.length; i++) {
      points[i] = [];
    }
    points = [];
    notifyListeners();
  }

  void removePoint() {
    List<Offset> oldList = _getPointList();
    if (oldList.isNotEmpty) {
      _getPointList().removeLast();
      notifyListeners();
    }
  }

  void changeAllPoint() {
    List<Offset> oldList = _getPointList();
    if (oldList.isEmpty) {
      showToast('请添加点');
      return;
    }
    if (oldList.length < 3) {
      showToast('至少添加3个点');
      return;
    }
    List<Offset> newList = [];
    for (int i = 0; i < oldList.length; i++) {
      Offset itemPre = oldList[i];
      Offset itemNext;
      if (i == oldList.length - 1) {
        itemNext = oldList[0];
      } else {
        itemNext = oldList[i];
      }

      Offset newItem = Offset(
          (itemPre.dx + itemNext.dx) / 2, (itemPre.dy + itemNext.dy) / 2);
      newList.add(newItem);
    }
    points.add(newList);
    notifyListeners();
  }

  void addPoint() {
    double padding = 30;
    double width = size.width;
    double height = size.height;
    double dx =
        _random.nextInt((width - 2 * padding).toInt()).toDouble() + padding;
    double dy =
        _random.nextInt((height - 2 * padding).toInt()).toDouble() + padding;
    _getPointList().add(Offset(dx, dy));
    notifyListeners();
  }

  @override
  void dispose() {
    for (int i = 0; i < points.length; i++) {
      points[i] = [];
    }
    points = [];
    super.dispose();
  }
}
