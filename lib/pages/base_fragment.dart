import 'package:flutter/material.dart';

import 'duoe_view.dart';

class BaseFragment extends StatelessWidget {
  const BaseFragment({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const MyBasePage(),
    );
  }
}

class MyBasePage extends StatefulWidget {
  const MyBasePage({super.key});

  @override
  State<MyBasePage> createState() => _MyBasePageState();
}

class _MyBasePageState extends State<MyBasePage> {
  int _selectIndex = 0;
  bool fullscreen = false;

  final List<Widget> _widgetOptions = <Widget>[
    DuoEkView(),
    DuoEkView(),
  ];

  late Function listener;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _widgetOptions.elementAt(_selectIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "实时"),
          BottomNavigationBarItem(icon: Icon(Icons.settings), label: "设置"),
        ],
        currentIndex: _selectIndex,
        selectedItemColor: Colors.amber[800],
        onTap: onItemTapped,
      ),
    );
  }

  void onItemTapped(int index) {
    setState(() {
      _selectIndex = index;
    });
  }
}
