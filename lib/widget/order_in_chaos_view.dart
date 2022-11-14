import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../utils/toast_util.dart';

class OrderInChaosView extends StatefulWidget {
  final OrderInChaosController? controller;
  final Size? size;
  final double? dotSize;
  final double? lineWidth;

  const OrderInChaosView({
    super.key,
    this.controller,
    this.size,
    this.dotSize,
    this.lineWidth,
  });

  @override
  State<OrderInChaosView> createState() => _OrderInChaosViewState();
}

class _OrderInChaosViewState extends State<OrderInChaosView> {
  late Size size;
  TapDownDetails? _details;

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
      body: GestureDetector(
        onTapDown: (TapDownDetails details) {
          _details = details;
        },
        onTap: () {
          if (_details != null) {
            widget.controller?.addPoint(point: _details!.localPosition);
          }
        },
        child: InteractiveViewer(
          maxScale: 20,
          transformationController: widget.controller?.transformationController,
          child: CustomPaint(
            size: size,
            painter: OrderInChaos(
              points: widget.controller?.points,
              dotSize: widget.dotSize,
              lineWidth: widget.lineWidth,
            ),
          ),
        ),
      ),
    );
  }
}

class OrderInChaos extends CustomPainter {
  List<List<Offset>>? points;
  final double? dotSize;
  final double? lineWidth;

  OrderInChaos({
    this.points,
    this.dotSize,
    this.lineWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 绘制背景网格线
    drawBackgroundLine(canvas, size);
    // 绘制圆点、连线
    drawPointLine(canvas, size);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }

  /// 绘制背景网格线
  void drawBackgroundLine(Canvas canvas, Size size) {
    // 绘制网格画笔
    Paint paint1 = Paint()
      ..color = const Color(0xffBCBCBC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    // 绘制中轴线画笔
    Paint paint2 = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;

    final width = size.width;
    final height = size.height;

    // 横向网格数量
    int widthLineCount = 19;
    num itemWidth = width / widthLineCount;
    // 纵向网格数量，网格是正方形，所以宽高相等
    num heightCount = height / itemWidth;
    // 绘制竖线
    for (int i = 0; i < widthLineCount; i++) {
      double x = (i + 1) * itemWidth.toDouble();
      // 判断是否中轴线
      bool isMiddle = i + 1 == (widthLineCount + 1) / 2;
      canvas.drawLine(
        Offset(
          x,
          0,
        ),
        Offset(
          x,
          height,
        ),
        isMiddle ? paint2 : paint1,
      );
    }

    // 绘制横线
    for (int i = 0; i < heightCount; i++) {
      double y = (i + 1) * itemWidth.toDouble();
      // 判断是否中轴线
      bool isMiddle = false;
      if (heightCount.toInt() % 2 == 0) {
        isMiddle = i + 1 == heightCount.toInt() / 2;
      } else {
        isMiddle = i + 1 == (heightCount.toInt() + 1) / 2;
      }
      canvas.drawLine(
        Offset(
          0,
          y,
        ),
        Offset(
          width,
          y,
        ),
        isMiddle ? paint2 : paint1,
      );
    }
  }

  void drawPointLine(Canvas canvas, Size size) {
    if (points?.isNotEmpty ?? false) {
      Paint paint1 = Paint()
        ..color = Colors.black
        ..style = PaintingStyle.fill
        ..strokeCap = StrokeCap.round
        ..strokeWidth = dotSize ?? 5.0
        ..isAntiAlias = true;
      Paint paint2 = Paint()
        ..color = Colors.yellow
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeWidth = lineWidth ?? 2.0
        ..isAntiAlias = true;

      List<Offset> list = points!.last;

      Path path = Path();
      path.addPolygon(list, true);
      canvas.drawPath(path, paint2);

      canvas.drawPoints(PointMode.points, list, paint1);
    }
  }
}

class OrderInChaosController extends ChangeNotifier {
  TransformationController transformationController =
      TransformationController();
  double padding = 30;
  double paddingBottom = 60;
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

  /// 重置圆点
  void clearPoints() {
    for (int i = 0; i < points.length; i++) {
      points[i] = [];
    }
    points = [];
    transformationController.value = Matrix4.identity();
    notifyListeners();
  }

  /// 移除圆点
  void removePoint() {
    List<Offset> lastList = _getLastPointList();
    if (lastList.isNotEmpty) {
      _getLastPointList().removeLast();
      notifyListeners();
    }
  }

  /// 计算所有圆点中间数值
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

    List<Offset> newList = [];
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

      newList.add(newItem);
    }
    points.add(newList);
    points.removeAt(0);
    notifyListeners();
  }

  /// 添加圆点
  void addPoint({Offset? point}) {
    if (point == null) {
      if (_size == null) {
        return;
      }
      double width = _size!.width;
      double height = _size!.height - kToolbarHeight;
      double dx =
          _random.nextInt((width - 2 * padding).toInt()).toDouble() + padding;
      double dy = _random
              .nextInt((height - padding - paddingBottom).toInt())
              .toDouble() +
          padding;
      point = Offset(dx, dy);
    }
    _getLastPointList().add(point);

    notifyListeners();
  }

  @override
  void dispose() {
    for (int i = 0; i < points.length; i++) {
      points[i] = [];
    }
    points = [];
    transformationController.value = Matrix4.identity();
    super.dispose();
  }
}
