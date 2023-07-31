import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
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

    final url = Uri.parse('http://192.168.68.103:7999/query');
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

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          titleSpacing: 0.0,
          backgroundColor: Colors.transparent,
          // leadingWidth: MediaQuery.of(context).size.width,
          title: GlassmorphicContainer(
            height: 100, // match AppBar height
            width: 3500,
            borderRadius: 1,
            blur: 15,
            alignment: Alignment.center,
            border: 1.5,
            linearGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.2),
                Colors.white.withOpacity(0.1),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderGradient: LinearGradient(
              colors: [
                Colors.white.withOpacity(0.5),
                Colors.white.withOpacity(0.5),
              ],
            ),
            child: Center(
              child: Image.network('assets/logo.gif'),
            ),
          ),

          toolbarHeight: 95, // Set height of AppBar
        ),
        body: Container(
          width: 1500,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "assets/bg2.png"), // Replace with your image file
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[index];
                    bool isLastMessage = index == messages.length - 1;
                    //bool isLink = Uri.parse(message.text).isAbsolute;

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
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(25),
                                    color: message.isUserMessage
                                        ? Color.fromARGB(255, 237, 237, 237)
                                            .withOpacity(0.5)
                                        : Color.fromARGB(255, 255, 255, 255)
                                            .withOpacity(0.5),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.1),
                                        spreadRadius: 1,
                                        blurRadius: 15,
                                      ),
                                    ],
                                  ),
                                  child: //isLink
                                      //     ? Linkify(
                                      //         onOpen: (link) async {
                                      //           if (await canLaunchUrl(
                                      //               Uri.parse(link.url))) {
                                      //             await launchUrl(Uri.parse(link.url));
                                      //           } else {
                                      //             throw 'Could not launch $link';
                                      //           }
                                      //         },
                                      //         text: message.text,
                                      //         style: TextStyle(
                                      //           color: Colors.white,
                                      //         ),
                                      //         linkStyle: TextStyle(
                                      //           color: Colors.blue,
                                      //         ),
                                      //       )
                                      Text(
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
                        if (isLastMessage &&
                            !message.isUserMessage &&
                            index != 0)
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
              Divider(height: 1, color: Colors.white),
              Container(
                color: Colors.transparent,
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: textController,
                        style: TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          hintText: 'Type your message...',
                          hintStyle: TextStyle(color: Colors.white),
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
        ),
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
