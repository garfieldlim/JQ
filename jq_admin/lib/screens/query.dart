import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<ChatMessage> messages = [
    ChatMessage(text: "How may I help you?", isUserMessage: false),
  ];
  TextEditingController textController = TextEditingController();
  int currentPartition = 0;
  bool isLoading =
      false; // Added a state variable for tracking the loading state

  Future<void> sendMessage(String message, {int? partition}) async {
    // if partition is null
    if (partition == null) {
      setState(() {
        messages.add(ChatMessage(text: message, isUserMessage: true));
      });
    }

    final url = Uri.parse('http://192.168.68.110:7999/query');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'question': message,
      'partition': partition ?? currentPartition,
    });

    setState(() {
      isLoading = true; // Set loading state to true before sending the request
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Remove last message after receiving the response
      if (messages.length > 0 && partition != null) {
        messages.removeLast();
      }

      setState(() {
        isLoading =
            false; // Set loading state to false after receiving the response
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var responseData = data['response'] as String;

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
          'liked': false, // Initialize liked status as false
          'disliked': false, // Initialize disliked status as false
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  // Function to handle liking or disliking a response
  void handleLikeDislike(int index, bool isLiked) {
    setState(() {
      if (isLiked) {
        // If liked, set liked to true and disliked to false
        messages[index].liked = true;
        messages[index].disliked = false;
      } else {
        // If disliked, set disliked to true and liked to false
        messages[index].liked = false;
        messages[index].disliked = true;
      }
    });

    // Update the Firestore database with the like/dislike status
    final collection = FirebaseFirestore.instance.collection('chat_messages');
    collection.doc(messages[index].id).update({
      'liked': isLiked,
      'disliked': !isLiked,
    });
  }

  Future<void> regenerateMessage(ChatMessage message) async {
    if (currentPartition < 2) {
      currentPartition += 1;
      sendMessage(message.text, partition: currentPartition);
    } else {
      currentPartition = 0;
      sendMessage(message.text, partition: currentPartition);
    }
  }

// Function to handle liking or disliking a response
  void handleLikeDislike(int index, bool isLiked) {
    setState(() {
      if (isLiked) {
        // If liked, set liked to true and disliked to false
        messages[index].liked = true;
        messages[index].disliked = false;
      } else {
        // If disliked, set disliked to true and liked to false
        messages[index].liked = false;
        messages[index].disliked = true;
      }
    });

    // Update the Firestore database with the like/dislike status
    final collection = FirebaseFirestore.instance.collection('chat_messages');
    collection.doc(messages[index].id).update({
      'liked': isLiked,
      'disliked': !isLiked,
    });
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
        leadingWidth: MediaQuery.of(context)
            .size
            .width, // Allow leading widget to take up all available space
        leading: Center(
          child: Image.network('assets/logo.gif'),
        ),
        toolbarHeight: 200, // Set height of AppBar
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                bool isLastMessage = index == messages.length - 1;

                return Column(
                  children: [
                    Container(
                      margin: EdgeInsets.all(20),
                      child: Row(
                        mainAxisAlignment: message.isUserMessage
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        children: [
                          Flexible(
                            // This is the modification
                            child: Container(
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
                          ),
                        ],
                      ),
                    ),
                    if (isLastMessage && !message.isUserMessage && index != 0)
                      isLoading
                          ? CircularProgressIndicator()
                          : TextButton(
                              // Show CircularProgressIndicator if loading
                              onPressed: () {
                                regenerateMessage(message);
                              },
                              child: Text('Regenerate'),
                            ),
                  ],
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
                    currentPartition =
                        0; // Reset partition when new message is sent
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
  bool liked; // New field to store like status
  bool disliked; // New field to store dislike status
  String? id;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    this.liked = false,
    this.disliked = false,
    this.id,
  });
}
