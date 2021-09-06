import 'package:flutter_acrylic/flutter_acrylic.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/states/provider/searcher_app_state.dart';
import 'package:searcher_app/widgets/searcher_bar/searcher_bar.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  Acrylic.initialize();

  runApp(MyApp());

  doWhenWindowReady(() {
    final windowSize = Size(1000, 260);
    appWindow.minSize = windowSize;
    appWindow.size = windowSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();
  });
}

class MyApp extends StatefulWidget {
  // This widget is the root of your application.
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    Acrylic.setEffect(
      effect: AcrylicEffect.aero,
      gradientColor: Colors.transparent,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: ChangeNotifierProvider<SearcherAppState>(
        create: (_) => SearcherAppState(),
        child: WindowTitleBarBox(
          child: WindowBorder(
            color: Colors.black,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 26.0),
                    child: SearcherBar(),
                  ),
                  AppTitleBar()
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AppTitleBar extends StatelessWidget {
  const AppTitleBar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topLeft,
      child: Container(
        height: 20.0,
        // TODO: Make this color a settings.
        color: Colors.black45,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: MoveWindow(),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: WindowButtons(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({
    Key? key,
    this.width = 25.0,
  }) : super(key: key);

  final double width;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            height: 8.0,
            width: width,
            child: InputChip(
              label: Container(),
              backgroundColor: const Color.fromARGB(255, 255, 189, 68),
              onPressed: () {
                appWindow.minimize();
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            height: 8.0,
            width: width,
            child: InputChip(
              label: Container(),
              backgroundColor: const Color.fromARGB(255, 0, 202, 78),
              onPressed: () {
                /* FIXME: Make the window align to the center after a size
                    restore. */
                appWindow.maximizeOrRestore();
              },
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            height: 8.0,
            width: width,
            child: InputChip(
              backgroundColor: const Color.fromARGB(255, 255, 96, 92),
              label: Container(),
              onPressed: () {
                appWindow.close();
              },
            ),
          ),
        ),
      ],
    );
  }
}
