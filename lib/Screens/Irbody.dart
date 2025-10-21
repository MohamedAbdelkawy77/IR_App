import 'package:flutter/material.dart';
import 'package:irassimant/CustomWidgets/CustomBotton.dart';
import 'package:irassimant/CustomWidgets/ListofTextFeils.dart';
import 'package:irassimant/Screens/ResuletScreen.dart';

class Irbody extends StatefulWidget {
  const Irbody({super.key});

  @override
  State<Irbody> createState() => _IrbodyState();
}

class _IrbodyState extends State<Irbody> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  int selectNumber = 1;
  List<String> Documents = [''];

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formkey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: DropDownNumbersofDocuments(),
            ),
            GetTextfeilds(
              key: ValueKey(selectNumber), // Important: to rebuild the widget
              Numbers: selectNumber,
              Documents: Documents,
            ),
            CustomButton(
              onpressed: () {
                if (formkey.currentState!.validate()) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ResultScreen(documents: Documents),
                    ),
                  );
                }
              },
            ),
            //  Image.asset("Assets/original.png"),
          ],
        ),
      ),
    );
  }

  DropdownButton<int> DropDownNumbersofDocuments() {
    return DropdownButton(
      underline: const SizedBox(),
      borderRadius: BorderRadius.circular(20),
      hint: Text("Select the Number of Documents: $selectNumber"),
      value: selectNumber,
      items: List.generate(5, (index) {
        return DropdownMenuItem(
          value: index + 1,
          child: Text("Selected Number: ${index + 1}"),
        );
      }),
      onChanged: (val) {
        setState(() {
          int oldNumber = selectNumber;
          selectNumber = val!;

          if (selectNumber > oldNumber) {
            Documents.addAll(List.filled(selectNumber - oldNumber, ''));
          } else if (selectNumber < oldNumber) {
            Documents = Documents.sublist(0, selectNumber);
          }
        });
      },
    );
  }
}
