import 'package:flutter/material.dart';
import 'package:irassimant/Screens/Irbody.dart';
import 'package:irassimant/Screens/TeamScree.dart';
import 'package:irassimant/main.dart';
  // استدعاء صفحة الفريق

class Irapp extends StatelessWidget {
  const Irapp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "Information Retrieval Project",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
        backgroundColor: maincolor,
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              if (value == 'team') {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const TeamPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'team',
                child: Text("Team Members"),
              ),
            ],
          )
        ],
      ),
      body: const Irbody(),
    );
  }
}
