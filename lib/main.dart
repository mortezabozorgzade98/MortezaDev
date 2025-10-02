import 'package:flutter/material.dart';

import 'widgets/scale_gauge_widget.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Morteza Developer',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        fontFamily: 'YekanBakh',
      ),
      home: Scaffold(
        backgroundColor: Color(0xffF6F6F6),
        body: ScaleGaugeWidget(),
      ),
    );
  }
}
