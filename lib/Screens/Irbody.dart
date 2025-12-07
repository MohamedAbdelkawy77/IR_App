import 'package:flutter/material.dart';
import 'package:irassimant/CustomWidgets/CustomBotton.dart';
import 'package:irassimant/CustomWidgets/ListofTextFeils.dart';
import 'package:irassimant/Screens/ChoosenCategoryScreen.dart';
import 'package:irassimant/Screens/ResuletScreen.dart';

class Irbody extends StatefulWidget {
  const Irbody({super.key});

  @override
  State<Irbody> createState() => _IrbodyState();
}

class _IrbodyState extends State<Irbody> {
  final GlobalKey<FormState> formkey = GlobalKey<FormState>();
  final TextEditingController numberController = TextEditingController();
  int selectNumber = 1;
  List<String> Documents = [''];
  bool isProcessing = false;

  @override
  void dispose() {
    numberController.dispose();
    super.dispose();
  }

  void _processAndNavigate() {
    if (formkey.currentState!.validate()) {
      // Show processing indicator
      setState(() {
        isProcessing = true;
      });

      // Process asynchronously
      Future.delayed(const Duration(milliseconds: 800)).then((_) {
        if (mounted) {
          setState(() {
            isProcessing = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Choosencategoryscreen(
                documents: Documents,
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Form(
          key: formkey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: NumberInputField(),
                ),
                GetTextfeilds(
                  key: ValueKey(selectNumber),
                  Numbers: selectNumber,
                  Documents: Documents,
                ),
                CustomButton(
                  onpressed: isProcessing ? () {} : _processAndNavigate,
                ),
              ],
            ),
          ),
        ),

        // Processing overlay
        if (isProcessing)
          Container(
            color: Colors.black.withOpacity(0.5),
            child: Center(
              child: Card(
                elevation: 8,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        strokeWidth: 4,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Processing Documents...',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Please wait',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget NumberInputField() {
    return TextFormField(
      controller: numberController,
      keyboardType: TextInputType.number,
      enabled: !isProcessing,
      decoration: InputDecoration(
        labelText: 'Number of Documents',
        hintText: 'Enter number of documents (1-10)',
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        prefixIcon: const Icon(Icons.numbers),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a number';
        }
        final number = int.tryParse(value);
        if (number == null) {
          return 'Please enter a valid number';
        }
        if (number < 1 || number > 10) {
          return 'Please enter a number between 1 and 10';
        }
        return null;
      },
      onChanged: (value) {
        final number = int.tryParse(value);
        if (number != null && number >= 1 && number <= 10) {
          setState(() {
            int oldNumber = selectNumber;
            selectNumber = number;

            if (selectNumber > oldNumber) {
              Documents.addAll(List.filled(selectNumber - oldNumber, ''));
            } else if (selectNumber < oldNumber) {
              Documents = Documents.sublist(0, selectNumber);
            }
          });
        }
      },
    );
  }
}
