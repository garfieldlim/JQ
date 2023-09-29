import 'package:flutter/material.dart';

class ChatSuggestions extends StatelessWidget {
  final TextEditingController textController;
  final Function(String) onSuggestionSelected;
  static const List<String> chatSuggestions = [
    "Who is the VP of Finance?",
    "Yermum",
    "Lets go",
    // ... add more suggestions as needed
  ];

  ChatSuggestions({
    required this.textController,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8.0),
      child: Wrap(
        spacing: 8.0, // space between chips
        runSpacing: 4.0, // space between lines
        children: chatSuggestions.map((suggestion) {
          return ActionChip(
            label: Text(suggestion),
            onPressed: () {
              textController.text = suggestion;
              onSuggestionSelected(suggestion); 
            },
            backgroundColor: Color(0xffe7d192),
            side: BorderSide(width: 0, color: Colors.transparent),
          );
        }).toList(),
      ),
    );
  }
}
