import 'package:flutter/material.dart';

class MessageInput extends StatefulWidget {
  final TextEditingController textController;
  final Function(String) sendMessage;

  const MessageInput({super.key, 
    required this.textController,
    required this.sendMessage, required currentPartition,
  });

  @override
  _MessageInputState createState() => _MessageInputState();
}

class _MessageInputState extends State<MessageInput> {
  int currentPartition = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: widget.textController,
              onSubmitted: (text) {
                if (text.isNotEmpty) {
                  setState(() {
                    currentPartition = 0;
                  });
                  widget.sendMessage(text);
                  widget.textController.clear();
                }
              },
              style: const TextStyle(color: Colors.white),
              decoration: const InputDecoration(
                hintText: 'Type your message...',
                hintStyle: TextStyle(color: Colors.white),
                border: InputBorder.none,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              final message = widget.textController.text;
              if (message.isNotEmpty) {
                setState(() {
                  currentPartition = 0;
                });
                widget.sendMessage(message);
                widget.textController.clear();
              }
            },
            icon: const Icon(Icons.send),
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
