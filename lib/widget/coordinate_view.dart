import 'package:flutter/material.dart';

class CoordinateView extends StatelessWidget {
  final Size? size;
  final num widthLineCount;

  CoordinateView({
    super.key,
    this.size,
    this.widthLineCount = 19,
  }) {
    if (widthLineCount % 2 == 0) {
      throw Exception('widthLineCount不能为偶数，必须是奇数');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomPaint(
        size: size ??
            Size(
              MediaQuery.of(context).size.width,
              MediaQuery.of(context).size.height,
            ),
        painter: Coordinate(widthLineCount: widthLineCount),
      ),
    );
  }
}

class Coordinate extends CustomPainter {
  final num widthLineCount;

  const Coordinate({
    required this.widthLineCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint1 = Paint()
      ..color = const Color(0xffBCBCBC)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;
    Paint paint2 = Paint()
      ..color = Colors.blue
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..isAntiAlias = true;
    final width = size.width;
    final height = size.height;
    num itemWidth = width / widthLineCount;
    num heightCount = height / itemWidth;
    debugPrint(
        'width:$width, height:$height, itemWidth:$itemWidth, heightCount:$heightCount');
    // 绘制竖线
    for (int i = 0; i < widthLineCount; i++) {
      double x = (i + 1) * itemWidth.toDouble();
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

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}
