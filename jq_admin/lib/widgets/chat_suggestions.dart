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

  const ChatSuggestions({
    super.key,
    required this.textController,
    required this.onSuggestionSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
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
            backgroundColor: const Color(0xff969d7b),
            side: const BorderSide(width: 1, color: Color(0xfff2c87e)),
            labelStyle: const TextStyle(color: Colors.white),
          );
        }).toList(),
      ),
    );
  }
}
