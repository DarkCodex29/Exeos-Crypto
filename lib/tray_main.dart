import 'dart:io';
import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:provider/provider.dart';
import 'providers/app_provider.dart';
import 'screens/pin_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

  WindowOptions windowOptions = const WindowOptions(
    size: Size(1, 1),
    minimumSize: Size(1, 1),
    center: false,
    backgroundColor: Colors.transparent,
    skipTaskbar: true,
    titleBarStyle: TitleBarStyle.hidden,
    windowButtonVisibility: false,
    alwaysOnTop: false,
  );

  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.hide();
  });

  runApp(TrayApp());
}

class TrayApp extends StatelessWidget {
  const TrayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => AppProvider(),
      child: MaterialApp(
        title: 'Crypto Scanner',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: TrayWidget(),
      ),
    );
  }
}

class TrayWidget extends StatefulWidget {
  const TrayWidget({super.key});

  @override
  State<TrayWidget> createState() => _TrayWidgetState();
}

class _TrayWidgetState extends State<TrayWidget>
    with TrayListener, WindowListener {
  @override
  void initState() {
    super.initState();
    trayManager.addListener(this);
    windowManager.addListener(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initSystemTray();
    });
  }

  @override
  void dispose() {
    trayManager.removeListener(this);
    windowManager.removeListener(this);
    super.dispose();
  }

  Future<void> _initSystemTray() async {
    try {
      if (Platform.isWindows) {
        await trayManager.setIcon('windows/runner/resources/app_icon.ico');
      }

      Menu menu = Menu(
        items: [
          MenuItem(key: 'show_ui', label: 'Mostrar UI'),
          MenuItem.separator(),
          MenuItem(key: 'exit', label: 'Salir'),
        ],
      );

      await trayManager.setContextMenu(menu);
      await trayManager.setToolTip('Crypto Scanner');
    } catch (e) {
      debugPrint('Failed to initialize system tray: $e');
    }
  }

  @override
  void onTrayIconMouseDown() {
    _launchUIProcess();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case 'show_ui':
        _launchUIProcess();
        break;
      case 'exit':
        _exitApp();
        break;
    }
  }

  Future<void> _launchUIProcess() async {
    try {
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.setSize(Size(500, 700));
      await windowManager.center();
      await windowManager.setSkipTaskbar(false);
      await windowManager.setTitle('Crypto Scanner - PIN');

      await windowManager.show();
      await windowManager.focus();

      if (!mounted) return;
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => PinScreen()));
    } catch (e) {
      debugPrint('Failed to show PIN: $e');
    }
  }

  Future<void> _exitApp() async {
    await trayManager.destroy();
    exit(0);
  }

  @override
  void onWindowClose() async {
    await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
    await windowManager.setSkipTaskbar(true);
    await windowManager.setSize(Size(1, 1));
    await windowManager.hide();

    if (!mounted) return;
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (context) => Container()));
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
