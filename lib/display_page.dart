import 'package:flutter/material.dart';

class DisplayPage extends StatelessWidget {
  final String code;

  DisplayPage({required this.code});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Code'),
      ),
      body: Container(
        color: Colors.black,
        padding: EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Text(
            code,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'RobotoMono',
              fontSize: 16.0,
            ),
          ),
        ),
      ),
    );
  }
}
