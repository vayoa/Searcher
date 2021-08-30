import 'dart:async';
import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:searcher_app/searcher_bar.dart';
import 'package:system_tray/system_tray.dart';

void main() {
  runApp(MyApp());

  doWhenWindowReady(() {
    final windowSize = Size(850, 260);
    appWindow.minSize = windowSize;
    appWindow.maxSize = windowSize;
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
  final SystemTray _systemTray = SystemTray();
  Timer? _timer;
  bool _toggleTrayIcon = true;

  @override
  void initState() {
    super.initState();
    // initSystemTray();
  }

  Future<void> initSystemTray() async {
    String path;
    if (Platform.isWindows) {
      path = p.joinAll([
        p.dirname(Platform.resolvedExecutable),
        'data/flutter_assets/assets',
        'app_icon.ico'
      ]);
    } else if (Platform.isMacOS) {
      path = p.joinAll(['AppIcon']);
    } else {
      path = p.joinAll([
        p.dirname(Platform.resolvedExecutable),
        'data/flutter_assets/assets',
        'app_icon.png'
      ]);
    }

    // We first init the systray menu and then add the menu entries
    await _systemTray.initSystemTray("system tray",
        iconPath: path, toolTip: "How to use system tray with Flutter");

    await _systemTray.setContextMenu(
      [
        MenuItem(
          label: 'Show',
          onClicked: () {
            appWindow.show();
          },
        ),
        MenuSeparator(),
        SubMenu(
          label: "SubMenu",
          children: [
            MenuItem(
              label: 'SubItem1',
              enabled: false,
              onClicked: () {
                print("click SubItem1");
              },
            ),
            MenuItem(label: 'SubItem2'),
            MenuItem(label: 'SubItem3'),
          ],
        ),
        MenuSeparator(),
        MenuItem(
          label: 'Exit',
          onClicked: () {
            appWindow.close();
          },
        ),
      ],
    );

    // flash tray icon
    _timer = Timer.periodic(
      const Duration(milliseconds: 500),
      (timer) {
        _toggleTrayIcon = !_toggleTrayIcon;
        _systemTray.setSystemTrayInfo(
          iconPath: _toggleTrayIcon ? "" : path,
        );
      },
    );

    // handle system tray event
    _systemTray.registerSystemTrayEventHandler((eventName) {
      print("eventName: $eventName");
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: WindowBorder(
        color: Colors.grey,
        child: Scaffold(
          body: Stack(
            children: [
              SearcherBar(),
              Align(
                alignment: Alignment.topLeft,
                child: WindowTitleBarBox(
                  child: Container(
                    height: 10.0,
                    child: Row(
                      children: [
                        Expanded(
                          child: MoveWindow(),
                        ),
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 14.0, right: 35.0),
                          child: WindowButtons(),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

class WindowButtons extends StatelessWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8.0),
          child: SizedBox(
            height: 8.0,
            width: 25.0,
            child: InputChip(
              label: Container(),
              backgroundColor: Colors.yellow,
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
            width: 25.0,
            child: InputChip(
              backgroundColor: Colors.red,
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