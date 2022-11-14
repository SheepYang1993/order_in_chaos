---
theme: cyanosis
---

# 前言

在某音上看到一条视频，说在纸上随便画一堆乱七八糟的点，把它们连成一个多边形，然后找到每条边的中点，把中点再连成多边形。以此类推，不断衍变。

不管你的点多么的混乱，最后你都会得到一个椭圆形，混沌中诞生了秩序！

画面中的小圆点好似被无形之中的一双手指挥着，排着队，操起正步走成了一个椭圆形。

视频中的动画是采用Mathlab绘制出来的。整个变换过程十分优美，让人感受到了数学之美。随想到了通过Flutter技术，将这一变化记录下来的想法。

# 具体实现

说干就干，采用的flutter版本是3.3.7，下面是整个开发过程。

## 一、选择CustomPaint来绘制自定义View

新建`OrderInChaos`类，继承自`CustomPainter`，实现`paint`和`shouldRepaint`两个方法

```dart
class OrderInChaos extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {

  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}
```

在`paint`方法中绘制网格线和圆点、连线

```dart
  @override
void paint(Canvas canvas, Size size) {
  // 绘制背景网格线
  drawBackgroundLine(canvas, size);
  // 绘制圆点、连线
  drawBackgroundLine(canvas, size);
}
```

## 二、绘制背景网格线

```dart
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
```

## 三、创建controller控制View

创建`OrderInChaosController`类来控制界面中圆点的变化，对外开放4个方法进行操作，分别是：重置圆点`clearPoints`、添加圆点`addPoint`
、计算所有圆点中间数值`changeAllPoint`、移除圆点`removePoint`

```dart
class OrderInChaosController extends ChangeNotifier {
  /// 重置圆点
  void clearPoints() {}

  /// 添加圆点
  void addPoint({Offset? point}) {}

  /// 计算所有圆点中间数值
  void changeAllPoint() {}

  /// 移除圆点
  void removePoint() {}
}
```

## 四、添加/减少/重置圆点

下面是具体的方法实现

```dart
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
```

最后记得在dispose的时候重置掉数据

```dart
  @override
void dispose() {
  for (int i = 0; i < points.length; i++) {
    points[i] = [];
  }
  points = [];
  super.dispose();
}
```

## 五、计算圆点的中点数值

至少需要3个点，才能围成1个图形

```dart
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
```

## 六、绘制圆点及连线

```dart
/// 绘制圆点及连线
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

    // 绘制连线
    Path path = Path();
    path.addPolygon(list, true);
    canvas.drawPath(path, paint2);

    // 绘制圆点
    canvas.drawPoints(PointMode.points, list, paint1);
  }
}
```

## 八、重复前三步，不断循环绘制

```dart
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
```

# 额外：

## 一、支持缩放平移视图

最外层嵌套一个`InteractiveViewer`即可实现缩放平移拖拽

## 二、支持点击位置添加圆点

嵌套一个`GestureDetector`，记录点几下的位置，通过`addPoint`方法添加圆点

## 三、支持个性化配置
```dart
Drawer(
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
)
```

# 总结

生活之中到处都存在着数学的美，一种逻辑严谨的美。以此献给我逝去的青春岁月，希望未来能多沉淀自己，留心生活，热爱生活，享受生活，拒绝秃头！

# 仓库地址

> 仓库地址：[https://github.com/SheepYang1993/order_in_chaos](https://github.com/SheepYang1993/order_in_chaos)</br></br>感谢大家的阅读，喜欢的话点个赞~</br></br>

# 分享：Flutter2.0 绘制旋转太空人+蛛网效果

> 仓库地址：[https://github.com/SheepYang1993/flutter_spaceman](https://github.com/SheepYang1993/flutter_spaceman)</br></br>感谢大家的阅读，喜欢的话点个赞~</br></br>