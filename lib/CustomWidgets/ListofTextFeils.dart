import 'package:flutter/material.dart';
import 'package:irassimant/main.dart';

class GetTextfeilds extends StatefulWidget {
  const GetTextfeilds({
    super.key,
    required this.Numbers,
    required this.Documents,
  });

  final int Numbers;
  final List<String> Documents;

  @override
  State<GetTextfeilds> createState() => _GetTextfeildsState();
}

class _GetTextfeildsState extends State<GetTextfeilds> {
  late List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
 
    _controllers = List.generate(
      widget.Numbers,
      (index) => TextEditingController(
        text: index < widget.Documents.length ? widget.Documents[index] : '',
      ),
    );

 
    for (int i = 0; i < _controllers.length; i++) {
      final index = i;
      _controllers[i].addListener(() {
        if (index < widget.Documents.length) {
          widget.Documents[index] = _controllers[index].text;
        }
      });
    }
  }

  @override
  void dispose() {
 
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: List.generate(widget.Numbers, (index) {
        return Padding(
          padding: const EdgeInsets.all(10.0),
          child: Listoftextfeils(
            controller: _controllers[index],
            color: MycolorApp[index],
          ),
        );
      }),
    );
  }
}

class Listoftextfeils extends StatelessWidget {
  const Listoftextfeils({
    super.key,
    required this.controller,
    required this.color,
  });

  final TextEditingController controller;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: (val) {
        if (val == null || val.trim().isEmpty) {
          return "This feild is Required";
        }
        return null;
      },
      decoration: InputDecoration(
        hintText: "Document Text",
        icon: Icon(Icons.edit_document, color: color),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: color),
          borderRadius: BorderRadius.circular(20),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.red),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
