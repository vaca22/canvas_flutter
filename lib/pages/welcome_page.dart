import 'package:flutter/material.dart';

class WelcomePage extends StatefulWidget {
  const WelcomePage({Key? key}) : super(key: key);

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> {
  void jump() async {
    await Future.delayed(const Duration(seconds: 1));
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/base', (Route<dynamic> route) => false);
  }

  @override
  void initState() {
    super.initState();

    jump();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: null,
      body: Image(
          height: double.infinity,
          width: double.infinity,
          fit: BoxFit.fill,
          image: AssetImage("assets/welcome.jpg")),
    );
  }
}
