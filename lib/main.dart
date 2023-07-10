import 'package:canvas_flutter/pages/base_fragment.dart';
import 'package:canvas_flutter/pages/welcome_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void _portrait() {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: [
    SystemUiOverlay.bottom,
  ]);
  _portrait();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const WelcomePage(),
      routes: <String, WidgetBuilder>{
        '/welcome': (BuildContext context) => const WelcomePage(),
        '/base': (BuildContext context) => const BaseFragment(),
      },
    );
  }
}
