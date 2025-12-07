import 'package:flutter/material.dart';
import 'package:irassimant/Screens/IrApp.dart';

Color maincolor = Color(0xFF31326F);

List<Color> MycolorApp = [
  const Color(0xFF31326F),
  const Color(0xFF0D1164), // كحلي غامق
  const Color(0xFF640D5F), // بنفسجي غامق مائل للوردي
  const Color(0xFFEA2264), // وردي فاقع
  const Color(0xFFF78D60), // برتقالي فاتح
  const Color(0xFF31326F),
  const Color(0xFF0D1164), // كحلي غامق
  const Color(0xFF640D5F), // بنفسجي غامق مائل للوردي
  const Color(0xFFEA2264), // وردي فاقع
  const Color(0xFFF78D60), // برتقالي فات
  const Color(0xFF31326F),
  const Color(0xFF0D1164), // كحلي غامق
  const Color(0xFF640D5F), // بنفسجي غامق مائل للوردي
  const Color(0xFFEA2264), // وردي فاقع
  const Color(0xFFF78D60), // برتقالي فات
];

void main() {
  runApp(const IrApp());
}

class IrApp extends StatelessWidget {
  const IrApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Irapp(),
    );
  }
}
