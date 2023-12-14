import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatMessage> messages = [
    ChatMessage(text: "How may I help you?", isUserMessage: false),
  ];
  TextEditingController textController = TextEditingController();

  Future<void> sendMessage(String message) async {
    setState(() {
      messages.add(ChatMessage(text: message, isUserMessage: true));
    });

    final url = Uri.parse('https://37af-49-145-103-175.ngrok-free.app/search');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({'question': message});

    try {
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final responseData = data['response'] as String;
        setState(() {
          messages.add(ChatMessage(text: responseData, isUserMessage: false));
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffFBDFA4),
      appBar: AppBar(
        backgroundColor: const Color(0xffE5AA33),
        leading: Image.network('assets/logo2.png'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return Container(
                  margin: const EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: message.isUserMessage
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: message.isUserMessage
                              ? const Color(0xffE5AA33)
                              : const Color(0xff008400),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          message.text,
                          style: const TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          const Divider(height: 1, color: Color(0xffA89E9E)),
          Container(
            color: const Color(0xffFBDFA4),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: const InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: Color(0xff8A8A8A)),
                      border: InputBorder.none,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    final message = textController.text;
                    textController.clear();
                    sendMessage(message);
                  },
                  icon: const Icon(Icons.send),
                  color: Colors.white,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUserMessage;

  ChatMessage({required this.text, required this.isUserMessage});
}
