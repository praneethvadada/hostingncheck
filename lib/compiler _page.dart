import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:hostingncheck/arrows_ui.dart';
import 'package:hostingncheck/display_page.dart';

class CodingQuestion {
  final String title;
  final String description;
  final String expectedInput;
  final String expectedOutput;

  CodingQuestion({
    required this.title,
    required this.description,
    required this.expectedInput,
    required this.expectedOutput,
  });
}

class SplitViewScreen extends StatefulWidget {
  @override
  _SplitViewScreenState createState() => _SplitViewScreenState();
}

class _SplitViewScreenState extends State<SplitViewScreen> {
  final TextEditingController _codeController = TextEditingController();
  double _dividerPosition = 0.5;
  List<Map<String, String>> _testResults = [];
  bool _isRunClicked = false;
  bool _isLoading = false;
  final FocusNode _focusNode = FocusNode();
  String _selectedLanguage = 'Python'; // Default language

  final CodingQuestion _codingQuestion = CodingQuestion(
    title: 'Reverse a String',
    description: '''
Write a function to reverse a string.

Consider the following example:

Input: "hello"
Output: "olleh"

You may assume the input string will not be empty. Please handle any edge cases such as special characters or numbers. 
The function should be efficient and handle long strings.
You may assume the input string will not be empty. Please handle any edge cases such as special characters or numbers. 
The function should be efficient and handle long strings.You may assume the input string will not be empty. Please handle any edge cases such as special characters or numbers. 
The function should be efficient and handle long strings.You may assume the input string will not be empty. Please handle any edge cases such as special characters or numbers. 
The function should be efficient and handle long strings.You may assume the input string will not be empty. Please handle any edge cases such as special characters or numbers. 
The function should be efficient and handle long strings.
''',
    expectedInput: 'Input: "hello"\nInput: "1234"',
    expectedOutput: 'Output: "olleh"\nOutput: "4321"',
  );

  final ValueNotifier<bool> _isTextSelected = ValueNotifier<bool>(false);
  Rect? _buttonPosition;

  @override
  void initState() {
    super.initState();
    _codeController.addListener(_autoInsertMatchingCharacter);
  }

  @override
  void dispose() {
    _codeController.removeListener(_autoInsertMatchingCharacter);
    _codeController.dispose();
    _isTextSelected.dispose();
    super.dispose();
  }

  // void _commentSelectedLines() {
  //   final selection = _codeController.selection;
  //   if (selection.isCollapsed) return; // No text selected

  //   final text = _codeController.text;
  //   final selectedText = text.substring(selection.start, selection.end);

  //   // Split the selected text into lines
  //   final lines = selectedText.split('\n');
  //   String commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

  //   // Comment each line
  //   // final commentedLines = lines.map((line) => '// $line').join('\n');
  //   final commentedLines =
  //       lines.map((line) => '$commentSyntax $line').join('\n');

  //   // Replace the selected text with the commented text
  //   final newText =
  //       text.replaceRange(selection.start, selection.end, commentedLines);

  //   _codeController.value = _codeController.value.copyWith(
  //     text: newText,
  //     selection: TextSelection(
  //       baseOffset: selection.start,
  //       extentOffset: selection.start + commentedLines.length,
  //     ),
  //   );
  // }

  void _commentSelectedLines() {
    final selection = _codeController.selection;
    final text = _codeController.text;

    // Determine the comment syntax based on the selected language
    String commentSyntax = _selectedLanguage == 'Python' ? '#' : '//';

    if (selection.isCollapsed) {
      // No text is selected, comment the current line
      int lineStart = selection.start;
      int lineEnd = selection.start;

      // Find the start of the line
      while (lineStart > 0 && text[lineStart - 1] != '\n') {
        lineStart--;
      }

      // Find the end of the line
      while (lineEnd < text.length && text[lineEnd] != '\n') {
        lineEnd++;
      }

      // Extract the current line
      final lineText = text.substring(lineStart, lineEnd);

      // Comment the line
      final commentedLine = '$commentSyntax $lineText';

      // Replace the line in the text
      final newText = text.replaceRange(lineStart, lineEnd, commentedLine);

      _codeController.value = _codeController.value.copyWith(
        text: newText,
        selection: TextSelection.collapsed(
            offset: selection.start + commentSyntax.length + 1),
      );
    } else {
      // Text is selected, comment each selected line
      final selectedText = text.substring(selection.start, selection.end);

      // Split the selected text into lines
      final lines = selectedText.split('\n');

      // Comment each line
      final commentedLines =
          lines.map((line) => '$commentSyntax $line').join('\n');

      // Replace the selected text with the commented text
      final newText =
          text.replaceRange(selection.start, selection.end, commentedLines);

      _codeController.value = _codeController.value.copyWith(
        text: newText,
        selection: TextSelection(
          baseOffset: selection.start,
          extentOffset: selection.start + commentedLines.length,
        ),
      );
    }
  }

  bool _isCtrlSlashPressed(Set<LogicalKeyboardKey> keysPressed) {
    return (keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
            keysPressed.contains(LogicalKeyboardKey.controlRight)) &&
        keysPressed.contains(LogicalKeyboardKey.slash);
  }

  // void _commentSelectedLines() {
  //   final selection = _codeController.selection;
  //   if (selection.isCollapsed) return; // No text selected

  //   final text = _codeController.text;
  //   final selectedText = text.substring(selection.start, selection.end);

  //   // Split the selected text into lines
  //   final lines = selectedText.split('\n');

  //   // Comment each line
  //   final commentedLines = lines.map((line) => '// $line').join('\n');

  //   // Replace the selected text with the commented text
  //   final newText =
  //       text.replaceRange(selection.start, selection.end, commentedLines);

  //   _codeController.value = _codeController.value.copyWith(
  //     text: newText,
  //     selection: TextSelection(
  //       baseOffset: selection.start,
  //       extentOffset: selection.start + commentedLines.length,
  //     ),
  //   );
  // }

  // bool _isCtrlSlashPressed(Set<LogicalKeyboardKey> keysPressed) {
  //   return keysPressed.contains(LogicalKeyboardKey.controlLeft) ||
  //       keysPressed.contains(LogicalKeyboardKey.controlRight) &&
  //           keysPressed.contains(LogicalKeyboardKey.slash);
  // }

  void _updateEditorContent() {
    switch (_selectedLanguage) {
      case 'Python':
        _codeController.text = '# Start your code here\n';
        break;
      case 'C':
        _codeController.text =
            '#include <stdio.h>\nint main() {\n    // Start your code here\n    return 0;\n}';
        break;
      case 'C++':
        _codeController.text =
            '#include <iostream>\nint main() {\n    // Start your code here\n    return 0;\n}';
        break;
      case 'Java':
        _codeController.text =
            'class Main{\n    public static void main(String[] args){\n        // Start your code here\n    }\n}';
        break;
      default:
        _codeController.text = '';
    }
  }

  void _runTestCases(int numberOfCases) {
    setState(() {
      _isRunClicked = true;
      _isLoading = true;

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _testResults = List.generate(numberOfCases, (index) {
            return {
              'case': 'Test Case ${index + 1}',
              'input': 'Input ${index + 1}',
              'output': index % 2 == 0 ? 'Passed' : 'Failed'
            };
          });
          _isLoading = false;
        });
      });
    });
  }

  void _runCode() {
    setState(() {
      _isRunClicked = true;
      _isLoading = true;

      Future.delayed(Duration(seconds: 2), () {
        setState(() {
          _testResults = List.generate(15, (index) {
            return {
              'case': 'Test Case ${index + 1}',
              'input': 'Input ${index + 1}',
              'output': index % 2 == 0 ? 'Passed' : 'Failed'
            };
          });
          _isLoading = false;
        });
      });
    });
  }

  void _autoInsertMatchingCharacter() {
    final String text = _codeController.text;
    final int cursorPosition = _codeController.selection.baseOffset;

    if (cursorPosition <= 0 || cursorPosition > text.length) return;

    final String typedCharacter = text[cursorPosition - 1];
    String? matchingCharacter;

    // Determine matching character
    if (typedCharacter == '(') matchingCharacter = ')';
    if (typedCharacter == '{') matchingCharacter = '}';
    if (typedCharacter == '[') matchingCharacter = ']';
    if (typedCharacter == '"') matchingCharacter = '"';
    if (typedCharacter == "'") matchingCharacter = "'";

    // Logic for quotes
    if (typedCharacter == '"' || typedCharacter == "'") {
      // Check if we are inside a string
      bool isInsideString = false;
      int quoteCount = 0;
      for (int i = 0; i < cursorPosition - 1; i++) {
        if (text[i] == typedCharacter) {
          quoteCount++;
        }
      }
      isInsideString = quoteCount % 2 != 0;

      if (isInsideString) {
        // If inside a string, do not auto-insert another closing quote
        return;
      }

      // Insert the closing quote if at the end of text or next character is space/newline or inside brackets
      if (cursorPosition == text.length ||
          text[cursorPosition] == ' ' ||
          text[cursorPosition] == '\n' ||
          text[cursorPosition] == ')' ||
          text[cursorPosition] == '}' ||
          text[cursorPosition] == ']') {
        final newText = text.replaceRange(
            cursorPosition, cursorPosition, matchingCharacter!);
        _codeController.value = _codeController.value.copyWith(
          text: newText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: cursorPosition),
          ),
        );
        return;
      }
    }

    // Logic for other characters like (, {, [
    if (matchingCharacter != null) {
      int openCount = 0;
      int closeCount = 0;
      bool inString = false;
      String? currentStringQuote;

      for (int i = 0; i < text.length; i++) {
        if (text[i] == '"' || text[i] == "'") {
          if (!inString) {
            inString = true;
            currentStringQuote = text[i];
          } else if (currentStringQuote == text[i]) {
            inString = false;
            currentStringQuote = null;
          }
        }

        if (text[i] == typedCharacter && !inString) {
          openCount++;
        }
        if (text[i] == matchingCharacter && !inString) {
          closeCount++;
        }
      }

      if (openCount > closeCount) {
        if (cursorPosition < text.length &&
            text[cursorPosition] == matchingCharacter) {
          return;
        }

        final newText = text.replaceRange(
            cursorPosition, cursorPosition, matchingCharacter);
        _codeController.value = _codeController.value.copyWith(
          text: newText,
          selection: TextSelection.fromPosition(
            TextPosition(offset: cursorPosition),
          ),
        );
      }
    }

    // Handle Enter key press for formatting
    if (typedCharacter == '\n' &&
        cursorPosition > 1 &&
        (text[cursorPosition - 2] == '{' ||
            text[cursorPosition - 2] == '(' ||
            text[cursorPosition - 2] == '[')) {
      final beforeCursor = text.substring(0, cursorPosition - 1);
      final afterCursor = text.substring(cursorPosition);

      final formattedCode = beforeCursor +
          '\n       \n' + // 7 spaces for indentation
          afterCursor;

      _codeController.value = _codeController.value.copyWith(
        text: formattedCode,
        selection: TextSelection.fromPosition(
          TextPosition(offset: beforeCursor.length + 8),
        ),
      );
    }
  }

  // void _autoInsertMatchingCharacter() {
  //   final String text = _codeController.text;
  //   final int cursorPosition = _codeController.selection.baseOffset;

  //   if (cursorPosition <= 0 || cursorPosition > text.length) return;

  //   final String typedCharacter = text[cursorPosition - 1];
  //   String? matchingCharacter;

  //   // Determine matching character
  //   if (typedCharacter == '(') matchingCharacter = ')';
  //   if (typedCharacter == '{') matchingCharacter = '}';
  //   if (typedCharacter == '[') matchingCharacter = ']';
  //   if (typedCharacter == '"') matchingCharacter = '"';
  //   if (typedCharacter == "'") matchingCharacter = "'";

  //   // Logic for quotes
  //   if (typedCharacter == '"' || typedCharacter == "'") {
  //     bool isInsideString = false;
  //     int quoteCount = 0;
  //     for (int i = 0; i < cursorPosition - 1; i++) {
  //       if (text[i] == typedCharacter) {
  //         quoteCount++;
  //       }
  //     }
  //     isInsideString = quoteCount % 2 != 0;

  //     if (isInsideString) {
  //       // We're inside a string, so do not auto-insert another closing quote.
  //       return;
  //     }

  //     // If we're at the end of the text or next character is a space/newline,
  //     // auto-insert the matching quote.
  //     if (cursorPosition == text.length ||
  //         text[cursorPosition] == ' ' ||
  //         text[cursorPosition] == '\n') {
  //       final newText = text.replaceRange(
  //           cursorPosition, cursorPosition, matchingCharacter!);
  //       _codeController.value = _codeController.value.copyWith(
  //         text: newText,
  //         selection: TextSelection.fromPosition(
  //           TextPosition(offset: cursorPosition),
  //         ),
  //       );
  //       return;
  //     }
  //   }

  //   // Logic for other characters like (, {, [
  //   if (matchingCharacter != null) {
  //     int openCount = 0;
  //     int closeCount = 0;
  //     bool inString = false;
  //     String? currentStringQuote;

  //     for (int i = 0; i < text.length; i++) {
  //       if (text[i] == '"' || text[i] == "'") {
  //         if (!inString) {
  //           inString = true;
  //           currentStringQuote = text[i];
  //         } else if (currentStringQuote == text[i]) {
  //           inString = false;
  //           currentStringQuote = null;
  //         }
  //       }

  //       if (text[i] == typedCharacter && !inString) {
  //         openCount++;
  //       }
  //       if (text[i] == matchingCharacter && !inString) {
  //         closeCount++;
  //       }
  //     }

  //     if (openCount > closeCount) {
  //       if (cursorPosition < text.length &&
  //           text[cursorPosition] == matchingCharacter) {
  //         return;
  //       }

  //       final newText = text.replaceRange(
  //           cursorPosition, cursorPosition, matchingCharacter);
  //       _codeController.value = _codeController.value.copyWith(
  //         text: newText,
  //         selection: TextSelection.fromPosition(
  //           TextPosition(offset: cursorPosition),
  //         ),
  //       );
  //     }
  //   }

  //   // Handle Enter key press for formatting
  //   if (typedCharacter == '\n' &&
  //       cursorPosition > 1 &&
  //       (text[cursorPosition - 2] == '{' ||
  //           text[cursorPosition - 2] == '(' ||
  //           text[cursorPosition - 2] == '[')) {
  //     final beforeCursor = text.substring(0, cursorPosition - 1);
  //     final afterCursor = text.substring(cursorPosition);

  //     final formattedCode = beforeCursor +
  //         '\n       \n' + // 7 spaces for indentation
  //         afterCursor;

  //     _codeController.value = _codeController.value.copyWith(
  //       text: formattedCode,
  //       selection: TextSelection.fromPosition(
  //         TextPosition(offset: beforeCursor.length + 8),
  //       ),
  //     );
  //   }
  // }

  // void _autoInsertMatchingCharacter() {
  //   final String text = _codeController.text;
  //   final int cursorPosition = _codeController.selection.baseOffset;

  //   if (cursorPosition <= 0 || cursorPosition > text.length) return;

  //   final String typedCharacter = text[cursorPosition - 1];
  //   String? matchingCharacter;

  //   // Determine matching character
  //   if (typedCharacter == '(') matchingCharacter = ')';
  //   if (typedCharacter == '{') matchingCharacter = '}';
  //   if (typedCharacter == '[') matchingCharacter = ']';
  //   if (typedCharacter == '"') matchingCharacter = '"';
  //   if (typedCharacter == "'") matchingCharacter = "'";

  //   if (matchingCharacter != null) {
  //     // Ensure matching character is inserted
  //     int openCount = 0;
  //     int closeCount = 0;
  //     bool inString = false;
  //     String? currentStringQuote;

  //     for (int i = 0; i < text.length; i++) {
  //       if (text[i] == '"' || text[i] == "'") {
  //         if (!inString) {
  //           inString = true;
  //           currentStringQuote = text[i];
  //         } else if (currentStringQuote == text[i]) {
  //           inString = false;
  //           currentStringQuote = null;
  //         }
  //       }

  //       if (text[i] == typedCharacter && !inString) {
  //         openCount++;
  //       }
  //       if (text[i] == matchingCharacter && !inString) {
  //         closeCount++;
  //       }
  //     }

  //     if (openCount > closeCount) {
  //       if (cursorPosition < text.length &&
  //           text[cursorPosition] == matchingCharacter) {
  //         return;
  //       }

  //       final newText = text.replaceRange(
  //           cursorPosition, cursorPosition, matchingCharacter);
  //       _codeController.value = _codeController.value.copyWith(
  //         text: newText,
  //         selection: TextSelection.fromPosition(
  //           TextPosition(offset: cursorPosition),
  //         ),
  //       );
  //     }
  //   }

  //   // Handle Enter key press for formatting
  //   if (typedCharacter == '\n' &&
  //       cursorPosition > 1 &&
  //       (text[cursorPosition - 2] == '{' ||
  //           text[cursorPosition - 2] == '(' ||
  //           text[cursorPosition - 2] == '[')) {
  //     // Remove the Enter key character
  //     final beforeCursor = text.substring(0, cursorPosition - 1);
  //     final afterCursor = text.substring(cursorPosition);

  //     // Format the code into three lines
  //     final formattedCode = beforeCursor +
  //         '\n       \n' + // 7 spaces for indentation
  //         afterCursor;

  //     // Update the TextController with the formatted code
  //     _codeController.value = _codeController.value.copyWith(
  //       text: formattedCode,
  //       selection: TextSelection.fromPosition(
  //         TextPosition(
  //             offset: beforeCursor.length + 8), // Position after the 7 spaces
  //       ),
  //     );
  //     print('Typed Character: $typedCharacter');
  //     print('Text: $text');
  //     print('Before Cursor: $beforeCursor');
  //     print('After Cursor: $afterCursor');
  //   }
  // }

  // void _autoInsertMatchingCharacter() {
  //   final String text = _codeController.text;
  //   final int cursorPosition = _codeController.selection.baseOffset;

  //   if (cursorPosition <= 0 || cursorPosition > text.length) return;

  //   final String typedCharacter = text[cursorPosition - 1];

  //   String? matchingCharacter;
  //   if (typedCharacter == '(') matchingCharacter = ')';
  //   if (typedCharacter == '{') matchingCharacter = '}';
  //   if (typedCharacter == '[') matchingCharacter = ']';
  //   if (typedCharacter == '"') matchingCharacter = '"';
  //   if (typedCharacter == "'") matchingCharacter = "'";

  //   if (matchingCharacter != null) {
  //     int openCount = 0;
  //     int closeCount = 0;
  //     bool inString = false;
  //     String? currentStringQuote;

  //     for (int i = 0; i < text.length; i++) {
  //       if (text[i] == '"' || text[i] == "'") {
  //         if (!inString) {
  //           inString = true;
  //           currentStringQuote = text[i];
  //         } else if (currentStringQuote == text[i]) {
  //           inString = false;
  //           currentStringQuote = null;
  //         }
  //       }

  //       if (text[i] == typedCharacter && !inString) {
  //         openCount++;
  //       }
  //       if (text[i] == matchingCharacter && !inString) {
  //         closeCount++;
  //       }
  //     }

  //     if (openCount > closeCount) {
  //       if (cursorPosition < text.length &&
  //           text[cursorPosition] == matchingCharacter) {
  //         return;
  //       }

  //       final newText = text.replaceRange(
  //           cursorPosition, cursorPosition, matchingCharacter);
  //       _codeController.value = _codeController.value.copyWith(
  //         text: newText,
  //         selection: TextSelection.fromPosition(
  //           TextPosition(offset: cursorPosition),
  //         ),
  //       );
  //     }
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final dividerWidth = 8.0;
          final leftWidth = _dividerPosition * screenWidth - dividerWidth / 2;
          final rightWidth = screenWidth - leftWidth - dividerWidth;

          return Stack(
            children: [
              // Left pane (Coding question and test cases)
              Positioned(
                left: 0,
                width: leftWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  child: Stack(
                    children: [
                      SingleChildScrollView(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_codingQuestion.title,
                                  style: TextStyle(
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              SizedBox(height: 16),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: EdgeInsets.all(8),
                                child: Stack(
                                  children: [
                                    SelectableText(
                                      _codingQuestion.description,
                                      onSelectionChanged: (selection, cause) {
                                        if (selection.isCollapsed) {
                                          _isTextSelected.value = false;
                                          setState(() {
                                            _buttonPosition = null;
                                          });
                                        } else {
                                          _isTextSelected.value = true;
                                          final start = selection.baseOffset;
                                          final end = selection.extentOffset;
                                          _buttonPosition =
                                              _calculateButtonPosition(
                                                  context, start, end);
                                        }
                                      },
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    ValueListenableBuilder<bool>(
                                      valueListenable: _isTextSelected,
                                      builder: (context, isSelected, child) {
                                        if (isSelected &&
                                            _buttonPosition != null) {
                                          return Positioned(
                                            left: _buttonPosition!.left,
                                            top: _buttonPosition!.top,
                                            child: ElevatedButton(
                                                onPressed: () {},
                                                child: Text("Copy Question")),
                                            // child: GestureDetector(
                                            //   onTap: () {},
                                            //   child: Card(
                                            //     elevation: 10,
                                            //     child: Container(
                                            //         decoration: BoxDecoration(
                                            //           color: Colors.white,
                                            //           borderRadius:
                                            //               BorderRadius.circular(
                                            //                   10),
                                            //         ),
                                            //         height: 30,
                                            //         width: 120,
                                            //         child: const Align(
                                            //           alignment:
                                            //               Alignment.center,
                                            //           child: Text(
                                            //             "Copy Question",
                                            //             style: TextStyle(
                                            //                 color:
                                            //                     Colors.black),
                                            //           ),
                                            //         )),
                                            //   ),
                                            // ),
                                          );
                                        }
                                        return SizedBox.shrink();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 16),
                              Text('Sample Inputs:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: EdgeInsets.all(8),
                                child: SelectableText(
                                  _codingQuestion.expectedInput,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 16),
                              Text('Expected Outputs:',
                                  style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 8),
                              Container(
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                padding: EdgeInsets.all(8),
                                child: SelectableText(
                                  _codingQuestion.expectedOutput,
                                  style: TextStyle(fontSize: 16),
                                ),
                              ),
                              SizedBox(height: 16),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Right pane (Code editor with black theme and results)
              Positioned(
                right: 0,
                width: rightWidth,
                top: 0,
                bottom: 0,
                child: Container(
                  // color: Colors.white,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // Dropdown for language selection
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: DropdownButton<String>(
                            value: _selectedLanguage,
                            items: <String>['Python', 'C', 'C++', 'Java']
                                .map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedLanguage = newValue!;
                                _updateEditorContent();
                              });
                            },
                          ),
                        ),
                        Focus(
                          focusNode: _focusNode,
                          onKeyEvent: (FocusNode node, KeyEvent keyEvent) {
                            if (keyEvent is KeyDownEvent) {
                              final keysPressed =
                                  HardwareKeyboard.instance.logicalKeysPressed;
                              if (_isCtrlSlashPressed(keysPressed)) {
                                _commentSelectedLines();
                                return KeyEventResult.handled;
                              }

                              // Check for 'Tab' key for inserting spaces
                              if (keyEvent.logicalKey ==
                                  LogicalKeyboardKey.tab) {
                                final selection = _codeController.selection;
                                const tabSpaces = '        '; // 8 spaces

                                final newText = _codeController.text
                                    .replaceRange(selection.start,
                                        selection.end, tabSpaces);

                                _codeController.value =
                                    _codeController.value.copyWith(
                                  text: newText,
                                  selection: TextSelection.collapsed(
                                    offset: selection.start + tabSpaces.length,
                                  ),
                                );
                                return KeyEventResult
                                    .handled; // Prevent default behavior
                              }
                            }
                            return KeyEventResult.ignored;
                          },
                          child: Column(
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(
                                    left: 25.0, right: 10, top: 10),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    border: Border.all(color: Colors.grey),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: SizedBox(
                                    height: 370,
                                    child: Padding(
                                      padding: EdgeInsets.all(20),
                                      child: Theme(
                                        data: ThemeData(
                                          textSelectionTheme:
                                              TextSelectionThemeData(
                                            // selectionColor: Colors.grey[700], // Color of the selected text
                                            // selectionColor: const Color.fromARGB(255, 122, 115, 139),
                                            selectionColor:
                                                const Color.fromARGB(
                                                    255, 112, 105, 130),
                                            // selectionColor: const Color.fromARGB(
                                            //     255, 106, 100, 123),
                                          ),
                                        ),
                                        child: TextField(
                                          cursorColor: Colors.white,
                                          key: Key('code-editor'),
                                          controller: _codeController,
                                          maxLines: null,
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            contentPadding: EdgeInsets.all(8),
                                            border: InputBorder.none,
                                          ),
                                          style: TextStyle(
                                            fontFamily: 'RobotoMono',
                                            fontSize: 16,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  String userInput = _codeController.text;
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => DisplayPage(
                                        code: '${userInput}',
                                      ),
                                    ),
                                  );
                                },
                                child: Text('Next Page'),
                              ),
                              SizedBox(height: 16),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      _runTestCases(3); // Run 3 test cases
                                    },
                                    child: Text('Run'),
                                  ),
                                  SizedBox(width: 16),
                                  ElevatedButton(
                                    onPressed: () {
                                      _runTestCases(20); // Run 20 test cases
                                    },
                                    child: Text('Submit'),
                                  ),
                                ],
                              ),
                              SizedBox(height: 16),
                              _isRunClicked
                                  ? _isLoading
                                      ? CircularProgressIndicator()
                                      : SingleChildScrollView(
                                          scrollDirection: Axis.horizontal,
                                          child: DataTable(
                                            columns: [
                                              DataColumn(
                                                  label: Text('Test Case')),
                                              DataColumn(label: Text('Input')),
                                              DataColumn(label: Text('Output')),
                                            ],
                                            rows: _testResults
                                                .map(
                                                  (result) => DataRow(
                                                    cells: [
                                                      DataCell(Text(
                                                          result['case']!)),
                                                      DataCell(Text(
                                                          result['input']!)),
                                                      DataCell(Text(
                                                          result['output']!)),
                                                    ],
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        )
                                  : SizedBox.shrink(),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Divider between left and right panes
              // Divider between left and right panes
              Positioned(
                left: leftWidth,
                width: 22, // Adjusted width to accommodate custom design
                top: 0,
                bottom: 0,
                child: GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      _dividerPosition +=
                          (details.primaryDelta ?? 0) / screenWidth;
                      if (_dividerPosition < 0.35) _dividerPosition = 0.35;
                      if (_dividerPosition > 0.60) _dividerPosition = 0.60;
                    });
                  },
                  child: MouseRegion(
                    cursor: SystemMouseCursors.resizeColumn,
                    child: Container(
                      color: Colors.transparent,
                      width: 22, // Ensure this matches the width set above
                      child: Center(
                        child: Row(
                          children: [
                            Container(
                              height: 5,
                              width: 10,
                              color: Colors.transparent,
                              child: CustomPaint(
                                painter: LeftArrowPainter(
                                  strokeColor: Colors.grey,
                                  strokeWidth: 0,
                                  paintingStyle: PaintingStyle.fill,
                                ),
                                child: const SizedBox(
                                  height: 5,
                                  width: 10,
                                ),
                              ),
                            ),
                            Container(
                              height: double.infinity,
                              width: 2,
                              decoration: BoxDecoration(
                                color: Colors.grey,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            ),
                            Container(
                              height: 5,
                              width: 10,
                              color: Colors.transparent,
                              child: CustomPaint(
                                painter: RightArrowPainter(
                                  strokeColor: Colors.grey,
                                  strokeWidth: 0,
                                  paintingStyle: PaintingStyle.fill,
                                ),
                                child: const SizedBox(
                                  height: 5,
                                  width: 10,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              // Positioned(
              //   left: leftWidth,
              //   width: dividerWidth,
              //   top: 0,
              //   bottom: 0,
              //   child: GestureDetector(
              //     onPanUpdate: (details) {
              //       setState(() {
              //         _dividerPosition += details.delta.dx / screenWidth;
              //         _dividerPosition = _dividerPosition.clamp(0.35, 0.6);
              //       });
              //     },
              //     child: MouseRegion(
              //       cursor: SystemMouseCursors.resizeColumn,
              //       child: Container(
              //         color: Colors.grey,
              //         width: dividerWidth,
              //       ),
              //     ),
              //   ),
              // ),
            ],
          );
        },
      ),
    );
  }

  // Function to calculate the button position based on the selected text
  Rect _calculateButtonPosition(BuildContext context, int start, int end) {
    final RenderBox renderBox = context.findRenderObject() as RenderBox;
    final textStyle = DefaultTextStyle.of(context).style;
    final TextSpan span = TextSpan(
      style: textStyle,
      text: _codingQuestion.description.substring(0, end),
    );

    final TextPainter textPainter = TextPainter(
      text: span,
      textDirection: ui.TextDirection.ltr,
      textAlign: TextAlign.left,
    );
    textPainter.layout(minWidth: 0, maxWidth: renderBox.size.width);

    final Offset startOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: start),
      Rect.zero,
    );

    final Offset endOffset = textPainter.getOffsetForCaret(
      TextPosition(offset: end),
      Rect.zero,
    );

    final Offset localPosition = Offset(endOffset.dx, endOffset.dy);
    final Offset globalPosition = renderBox.localToGlobal(localPosition);

    return Rect.fromLTWH(
      globalPosition.dx,
      globalPosition.dy - 40, // Adjust the vertical position as needed
      50, // Width of the button
      50, // Height of the button
    );
  }
}
