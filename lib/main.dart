import 'package:flutter/material.dart';
import 'package:hostingncheck/exam_page.dart';
import 'package:hostingncheck/practice_page.dart';
import 'package:hostingncheck/testing_compiler_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Compiler Testing',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.dark,
      ),
      themeMode: _themeMode,
      initialRoute: '/',
      routes: {
        '/': (context) => MyHomePage(
              themeMode: _themeMode,
              toggleTheme: _toggleTheme,
            ),
        '/practice': (context) => PracticePage(),
        '/exam': (context) => ExamPage(),
        '/test': (context) => SmallTesting5(),
      },
    );
  }
}

class MyHomePage extends StatelessWidget {
  final ThemeMode themeMode;
  final VoidCallback toggleTheme;

  MyHomePage({required this.themeMode, required this.toggleTheme});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Practice & Examm'),
        actions: [
          IconButton(
            icon: Icon(
              themeMode == ThemeMode.dark ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: toggleTheme,
          ),
        ],
      ),
      body: const Column(
        children: [
          Center(
            child: NavigationButton(
              label: 'Practice',
              routeName: '/practice',
            ),
          ),
          Center(
            child: NavigationButton(
              label: 'Exam',
              routeName: '/exam',
            ),
          ),
          Center(
            child: NavigationButton(
              label: 'Testing',
              routeName: '/test',
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable NavigationButton widget
class NavigationButton extends StatelessWidget {
  final String label;
  final String routeName;

  const NavigationButton({
    super.key,
    required this.label,
    required this.routeName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pushNamed(context, routeName);
        },
        child: Text(label),
      ),
    );
  }
}
