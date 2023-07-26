import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class HomePage extends StatefulWidget {
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

    final url = Uri.parse('http://192.168.68.112:7999/query');
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

        // Save the chat messages in Cloud Firestore
        final collection =
            FirebaseFirestore.instance.collection('chat_messages');
        collection.add({
          'text': message,
          'isUserMessage': true,
          'timestamp': DateTime.now().toUtc(),
        });
        collection.add({
          'text': responseData,
          'isUserMessage': false,
          'timestamp': DateTime.now().toUtc(),
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
      backgroundColor: Color(0xffFBDFA4),
      appBar: AppBar(
        backgroundColor: Color(0xffE5AA33),
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
                  margin: EdgeInsets.all(20),
                  child: Row(
                    mainAxisAlignment: message.isUserMessage
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    children: [
                      Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: message.isUserMessage
                              ? Color(0xffE5AA33)
                              : Color(0xff008400),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: Text(
                          message.text,
                          style: TextStyle(
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
          Divider(height: 1, color: Color(0xffA89E9E)),
          Container(
            color: Color(0xffFBDFA4),
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: textController,
                    decoration: InputDecoration(
                      hintText: 'Type your message...',
                      hintStyle: TextStyle(color: const Color(0xff8A8A8A)),
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
                  icon: Icon(Icons.send),
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
