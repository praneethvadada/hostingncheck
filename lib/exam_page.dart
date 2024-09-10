import 'package:flutter/material.dart';
import 'package:hostingncheck/compiler%20_page.dart';
import 'dart:html' as html;

import 'package:hostingncheck/main.dart';

class ExamPage extends StatefulWidget {
  @override
  _ExamPageState createState() => _ExamPageState();
}

class _ExamPageState extends State<ExamPage> {
  int visibilityChangeCount = 0;
  static bool isExamMode = false;

  @override
  void initState() {
    super.initState();
    // Request full-screen mode
    html.document.documentElement?.requestFullscreen();

    // Enable exam mode
    isExamMode = true;

    // Add listener for visibility change
    html.document.onVisibilityChange.listen((event) {
      final isHidden = html.document.hidden;

      if (isExamMode) {
        if (isHidden == true) {
          visibilityChangeCount++;
          if (visibilityChangeCount >= 4) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => TerminationPage()),
            );
          } else {
            showSnackbar(
                'You have switched tabs. Warning: ${4 - visibilityChangeCount} warnings left.');
          }
        }
      }
    });
  }

  void showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    // Disable exam mode
    isExamMode = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SplitViewScreen(),
    );
  }
}

class TerminationPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'The exam session has been terminated due to policy violations.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MyHomePage(
                            themeMode: ThemeMode.dark,
                            toggleTheme: () {},
                          )),
                  (route) => false,
                );
              },
              child: Text('Go to Home Page'),
            ),
          ],
        ),
      ),
    );
  }
}
