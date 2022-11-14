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
    widget.controller?.addListener(() {
      setState(() {});
    });
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
      body: Transform.scale(
        scaleX: widget.controller?.scaleX ?? 0,
        scaleY: widget.controller?.scaleY ?? 0,
        child: Transform.translate(
          offset: Offset(
            // widget.controller?.translationX ?? 0,
            // widget.controller?.translationY ?? 0,
            0, 0,
          ),
          child: CustomPaint(
            size: size,
            painter: OrderInChaos(points: widget.controller?.points),
          ),
        ),
      ),
    );
  }
}

class OrderInChaos extends CustomPainter {
  List<List<Offset>>? points;

  OrderInChaos({this.points});

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawColor(Colors.transparent, BlendMode.color);
    Paint paint1 = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 2.0
      ..isAntiAlias = true;
    Paint paint2 = Paint()
      ..color = Colors.yellow
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;
    if (points?.isNotEmpty ?? false) {
      List<Offset> list = points!.last;

      Path path = Path();
      path.addPolygon(list, true);
      canvas.drawPath(path, paint2);

      canvas.drawPoints(PointMode.points, list, paint1);
    }
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint2);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class OrderInChaosController extends ChangeNotifier {
  double padding = 30;
  double paddingBottom = 60;
  double translationX = 0;
  double translationY = 0;
  double scaleX = 1;
  double scaleY = 1;
  final Random _random = Random();
  List<List<Offset>> points = [];

  Size? _size;

  set size(Size value) {
    _size = value;
    notifyListeners();
  }

  List<Offset> _getLastPointList() {
    if (points.isEmpty) {
      points.add([]);
    }
    return points.last;
  }

  List<Offset> _getFirstPointList() {
    if (points.isEmpty) {
      points.add([]);
    }
    return points.first;
  }

  void clearPoints() {
    for (int i = 0; i < points.length; i++) {
      points[i] = [];
    }
    points = [];
    scaleX = 1;
    scaleY = 1;
    translationX = 0;
    translationY = 0;
    notifyListeners();
  }

  void removePoint() {
    List<Offset> lastList = _getLastPointList();
    if (lastList.isNotEmpty) {
      _getLastPointList().removeLast();
      scaleX = 1;
      scaleY = 1;
      translationX = 0;
      translationY = 0;
      notifyListeners();
    }
  }

  void changeAllPoint() {
    List<Offset> lastList = _getLastPointList();
    if (lastList.isEmpty) {
      showToast('请添加点');
      return;
    }
    if (lastList.length < 3) {
      showToast('至少添加3个点');
      return;
    }
    double leftOld = lastList[0].dx;
    double topOld = lastList[0].dy;
    double rightOld = lastList[0].dx;
    double bottomOld = lastList[0].dy;
    List<Offset> firstList = _getFirstPointList();
    for (int i = 0; i < firstList.length; i++) {
      Offset item = firstList[i];
      if (item.dx < leftOld) {
        leftOld = item.dx;
      }
      if (item.dx > rightOld) {
        rightOld = item.dx;
      }
      if (item.dy < topOld) {
        topOld = item.dy;
      }
      if (item.dy > bottomOld) {
        bottomOld = item.dy;
      }
    }

    List<Offset> newList = [];
    double leftNew = lastList[0].dx;
    double topNew = lastList[0].dy;
    double rightNew = lastList[0].dx;
    double bottomNew = lastList[0].dy;
    for (int i = 0; i < lastList.length; i++) {
      Offset itemPre = lastList[i];
      Offset itemNext;
      if (i == lastList.length - 1) {
        itemNext = lastList[0];
      } else {
        itemNext = lastList[i + 1];
      }

      Offset newItem = Offset(
          (itemPre.dx + itemNext.dx) / 2, (itemPre.dy + itemNext.dy) / 2);

      if (newItem.dx < leftNew) {
        leftNew = newItem.dx;
      }
      if (newItem.dx > rightNew) {
        rightNew = newItem.dx;
      }
      if (newItem.dy < topNew) {
        topNew = newItem.dy;
      }
      if (newItem.dy > bottomNew) {
        bottomNew = newItem.dy;
      }
      scaleX = (rightOld - leftOld) / (rightNew - leftNew);
      scaleY = (bottomOld - topOld) / (bottomNew - topNew);
      double width = _size!.width;
      double height = _size!.height - kToolbarHeight;
      translationX =
          ((width - 2 * padding) - (rightNew - leftNew) * scaleX) / 2;
      translationY =
          ((height - padding - paddingBottom) - (bottomNew - topNew) * scaleY) /
              2;

      debugPrint(
        'scaleX:$scaleX, scaleY:$scaleY, translationX:$translationX, translationY:$translationY',
      );
      newList.add(newItem);
    }
    points.add(newList);
    notifyListeners();
  }

  void addPoint() {
    if (_size == null) {
      return;
    }
    double width = _size!.width;
    double height = _size!.height - kToolbarHeight;
    double dx =
        _random.nextInt((width - 2 * padding).toInt()).toDouble() + padding;
    double dy =
        _random.nextInt((height - padding - paddingBottom).toInt()).toDouble() +
            padding;
    _getLastPointList().add(Offset(dx, dy));
    scaleX = 1;
    scaleY = 1;
    translationX = 0;
    translationY = 0;

    notifyListeners();
  }

  @override
  void dispose() {
    for (int i = 0; i < points.length; i++) {
      points[i] = [];
    }
    points = [];
    scaleX = 1;
    scaleY = 1;
    translationX = 0;
    translationY = 0;
    super.dispose();
  }
}
