import 'package:flutter/material.dart';

class QueueApp extends StatelessWidget {
  const QueueApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Queue App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        appBar: AppBar(title: const Text('Queue App')),
        body: const Center(child: Text('Ласкаво просимо до Queue App!')),
      ),
    );
  }
}