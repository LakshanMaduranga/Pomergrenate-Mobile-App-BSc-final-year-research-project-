import 'package:flutter/material.dart';
import 'package:pomergreneate_mobile_app/Ml%20Model.dart';

void main() {
  runApp(const MLAPP());
}

class MLAPP extends StatelessWidget {
  const MLAPP({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, home: MlModel());
  }
}
