import 'package:flutter/material.dart';
import 'package:flutter_swiper_null_safety/flutter_swiper_null_safety.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: PageItemWidget(),
    );
  }
}

class PageItemWidget extends StatefulWidget {
  PageItemWidget({Key? key}) : super(key: key);

  List<Map> imgList = [
    {"url": "https://www.itying.com/images/flutter/1.png"},
    {"url": "https://www.itying.com/images/flutter/2.png"},
    {"url": "https://www.itying.com/images/flutter/3.png"},
    {"url": "https://www.itying.com/images/flutter/4.png"},
    {"url": "https://www.itying.com/images/flutter/1.png"},
    {"url": "https://www.itying.com/images/flutter/2.png"},
    {"url": "https://www.itying.com/images/flutter/3.png"},
    {"url": "https://www.itying.com/images/flutter/4.png"},
    {"url": "https://www.itying.com/images/flutter/1.png"},
    {"url": "https://www.itying.com/images/flutter/2.png"},
    {"url": "https://www.itying.com/images/flutter/3.png"},
    {"url": "https://www.itying.com/images/flutter/4.png"}
  ];

  @override
  State<PageItemWidget> createState() => _PageItemWidgetState();
}

class _PageItemWidgetState extends State<PageItemWidget>
    with SingleTickerProviderStateMixin {
  final _controller = SwiperController();
  Animation<double>? animation;
  AnimationController? animationController;
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final count = widget.imgList.length;
      animationController = AnimationController(
          duration: Duration(seconds: count * 5), vsync: this);
      animation = Tween<double>(begin: 0, end: 1).animate(animationController!)
        ..addListener(() async {
          setState(() {});
        });
      animationController!.addStatusListener((status) async {
        if (status == AnimationStatus.completed) {
          await setCurrentIndex(0);
        }
      });
      animationController!.forward();
    });
  }

  @override
  void dispose() {
    animationController?.dispose();
    super.dispose();
  }

  Future<void> setCurrentIndex(int index) async {
    if (_controller.index != index) {
      final resulr = index == widget.imgList.length ? 0 : index;
      await _controller.move(resulr, animation: resulr == 0 ? false : true);
    }
  }

  Future<void> indexChanged(int index) async {
    final progress = index / widget.imgList.length;
    animationController?.stop();
    animationController?.value =
        progress + 5 / MediaQuery.of(context).size.width;
    await animationController!.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(children: [
      Positioned.fill(
        child: Swiper(
            itemBuilder: (BuildContext context, int index) {
              return Image.network(
                widget.imgList[index]['url'],
                fit: BoxFit.fill,
              );
            },
            itemCount: widget.imgList.length,
            // index: 0,
            controller: _controller,
            loop: false,
            autoplay: false,
            scrollDirection: Axis.horizontal,
            onTap: (int index) {
              // 点击触发
              print(index);
            },
            onIndexChanged: (int index) async {
              // 当用户手动拖拽或者自动播放引起下标改变的时候调用
              print("swiper 回调 Changed - ${index}");
              await indexChanged(index);
            }),
      ),
      Positioned(
          bottom: 0.0,
          child: SafeArea(
              child: Container(
                  height: 10.0,
                  child: PagerCountView(
                    pageCount: 4,
                    strokeColor: Colors.white,
                    currentProgress: (animation?.value ?? 0) *
                        MediaQuery.of(context).size.width,
                    backgroundStrokeColor: Colors.white.withAlpha(50),
                    dashWidth: MediaQuery.of(context).size.width /
                            widget.imgList.length -
                        5,
                    dashSpace: 5,
                    callBack: (int index) async {
                      await setCurrentIndex(index - 1);
                    },
                  ))))
    ]);
  }
}

/****************************************************************/

typedef IndexCallback = void Function(int index);

class PagerCountView extends StatefulWidget {
  final int pageCount;
  final double currentProgress;
  final Color strokeColor;
  final Color backgroundStrokeColor;
  final double dashWidth;
  final double dashSpace;
  final IndexCallback callBack;

  const PagerCountView({
    Key? key,
    required this.pageCount,
    required this.strokeColor,
    required this.currentProgress,
    required this.backgroundStrokeColor,
    required this.dashWidth,
    required this.dashSpace,
    required this.callBack,
  }) : super(key: key);

  @override
  _PagerCountViewState createState() => _PagerCountViewState();
}

class _PagerCountViewState extends State<PagerCountView> {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: CustomPaint(
        size: MediaQuery.of(context).size,
        painter: PagerCountViewPainterBg(
            widget.backgroundStrokeColor, widget.dashWidth, widget.dashSpace,
            pageCount: widget.pageCount),
        foregroundPainter: PagerCountViewPainter(
            widget.dashWidth, widget.dashSpace, widget.callBack,
            pageCount: widget.pageCount,
            currentProgress: widget.currentProgress,
            strokeColor: widget.strokeColor),
      ),
    );
  }
}

class PagerCountViewPainterBg extends CustomPainter {
  final int pageCount;
  final Color backgroundStrokeColor;
  final double dashWidth;
  final double dashSpace;

  late Paint _paint;

  PagerCountViewPainterBg(
      this.backgroundStrokeColor, this.dashWidth, this.dashSpace,
      {required this.pageCount}) {
    _paint = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _paint.shader = LinearGradient(
      colors: [backgroundStrokeColor, backgroundStrokeColor],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.zero);
  }

  @override
  void paint(Canvas canvas, Size size) {
    final maxWidth = size.width;
    double startX = 0;
    List array = [];
    while (startX < maxWidth) {
      canvas.drawLine(Offset(startX, 0), Offset(startX + dashWidth, 0), _paint);
      startX += dashWidth + dashSpace;
      array.add([startX - dashSpace, startX]);
    }
  }

  @override
  bool shouldRepaint(PagerCountViewPainterBg oldDelegate) => true;
}

class PagerCountViewPainter extends CustomPainter {
  final int pageCount;
  final IndexCallback callBack;
  final double currentProgress;
  final Color strokeColor;

  final double dashWidth;
  final double dashSpace;

  late Paint _paintYellow;

  PagerCountViewPainter(this.dashWidth, this.dashSpace, this.callBack,
      {required this.pageCount,
      required this.currentProgress,
      required this.strokeColor}) {
    _paintYellow = Paint()
      ..strokeWidth = 2.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    _paintYellow.color = strokeColor;

    _paintYellow.shader = LinearGradient(
      colors: [strokeColor, strokeColor.withOpacity(0.5)],
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
    ).createShader(Rect.zero);
  }

  @override
  void paint(Canvas canvas, Size size) {
    List coordinates = calculateDottedLine(currentProgress);

    for (final coordinate in coordinates) {
      canvas.drawLine(
          Offset(coordinate[0], 0), Offset(coordinate[1], 0), _paintYellow);
    }
    callBack(coordinates.length);
  }

  List calculateDottedLine(double lineLength) {
    // double lineHeight = 105; // 实线长度
    // double spaceWidth = 45; // 实线间距
    double totalWidth = dashWidth + dashSpace; // 实线总宽度

    List<List<double>> paths = [];

    // 计算需要的实线数
    int count = (lineLength ~/ totalWidth) + 1;

    // 如果需要的实线数为1，则单独处理
    if (count == 1) {
      if (lineLength > dashWidth && lineLength < totalWidth) {
        paths.add([0.0, dashWidth]);
      } else {
        paths.add([0.0, lineLength]);
      }
    } else {
      // 生成路径数据
      double startPoint = 0.0;
      double endPoint = 0.0;
      for (int i = 0; i < count; i++) {
        endPoint = startPoint + dashWidth;
        paths.add([startPoint, endPoint]);
        startPoint = endPoint + dashSpace;
      }
      if (lineLength > paths.last[0] && lineLength < paths.last[1]) {
        paths.removeLast();
      }
      final lastPath = paths.last[1] + dashSpace;
      final isPattern = lineLength < lastPath && lineLength > paths.last[1];
      if (!isPattern && lineLength > lastPath) {
        paths.add([lastPath, lineLength]);
      }
    }
    return paths;
  }

  @override
  bool shouldRepaint(PagerCountViewPainter oldDelegate) =>
      oldDelegate.pageCount != pageCount ||
      oldDelegate.currentProgress != currentProgress;
}
