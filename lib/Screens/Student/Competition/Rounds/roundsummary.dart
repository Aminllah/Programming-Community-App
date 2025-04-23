import 'package:flutter/material.dart';

class Roundsummary extends StatefulWidget {
  const Roundsummary({super.key});

  @override
  State<Roundsummary> createState() => _RoundsummaryState();
}

class _RoundsummaryState extends State<Roundsummary> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amber,
        centerTitle: true,
        title: Text(
          'Round Summary',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
      ),
    );
  }
}
