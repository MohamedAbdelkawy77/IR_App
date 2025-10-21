import 'package:flutter/material.dart';
import 'package:irassimant/Screens/Irbody.dart';
import 'package:irassimant/main.dart';

class Irapp extends StatelessWidget {
  const Irapp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          "Information Retrival",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: maincolor,
      ),
      body: Irbody(),
    );
  }
}
