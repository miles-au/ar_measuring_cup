import 'package:flutter/material.dart';

// screens
import 'package:armeasuringcup/screens/ios_ar_screen.dart';

class HomeScreen extends StatelessWidget {
  static const routeName = 'home_screen';

  @override
  Widget build(BuildContext context) {
    return IOSARScreen();
  }
}
