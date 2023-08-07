import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:glassmorphism/glassmorphism.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import 'package:any_link_preview/any_link_preview.dart';
import 'package:jq_admin/screens/loading.dart';
import 'package:url_launcher/url_launcher.dart';

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
  bool isLoading = false;
  bool isTyping = false;

  Future<void> sendMessage(String message, {int? partition}) async {
    // if partition is null
    if (partition == null) {
      setState(() {
        messages.add(ChatMessage(text: message, isUserMessage: true));
      });
    }

    final url = Uri.parse('http://127.0.0.1:7999/query');
    final headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      'question': message,
      'partition': partition ?? currentPartition,
    });

    setState(() {
      isLoading = true;
      isTyping = true;
    });

    try {
      final response = await http.post(url, headers: headers, body: body);

      // Remove last message after receiving the response
      if (messages.length > 0 && partition != null) {
        messages.removeLast();
      }

      setState(() {
        isLoading = false;
        isTyping = false;
      });

      // Save the chat messages in Cloud Firestore
      final collection = FirebaseFirestore.instance.collection('chat_messages');

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var responseData = data['response'] as String;

        setState(() {
          messages.add(ChatMessage(
            text: responseData,
            isUserMessage: false,
            liked: false,
            disliked: false,
            id: collection.doc().id, // Store the document ID
          ));
        });

        var userMessageDoc = await collection.add({
          'text': message,
          'isUserMessage': true,
          'timestamp': DateTime.now().toUtc(),
        });
        var botMessageDoc = await collection.add({
          'text': responseData,
          'isUserMessage': false,
          'timestamp': DateTime.now().toUtc(),
          'liked': false,
          'disliked': false,
        });

        // Store the document ID in the ChatMessage object
        setState(() {
          messages[messages.length - 2].id = userMessageDoc.id;
          messages[messages.length - 1].id = botMessageDoc.id;
        });
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
      isTyping = false;
    }
  }

  void handleLikeDislike(int index, bool isLiked) {
    if (messages[index].id != null) {
      setState(() {
        if (isLiked) {
          messages[index].liked = true;
          messages[index].disliked = false;
        } else {
          messages[index].liked = false;
          messages[index].disliked = true;
        }
      });

      final collection = FirebaseFirestore.instance.collection('chat_messages');
      collection.doc(messages[index].id).update({
        'liked': isLiked,
        'disliked': !isLiked,
      });
    } else {
      print('Error: Document ID is null.');
    }
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
          title: GlassmorphicContainer(
            height: 100,
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
              child: Image.asset('web/assets/logo.gif'),
            ),
          ),
          toolbarHeight: 95,
        ),
        body: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('web/assets/bg2.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: messages.length + (isTyping ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (isTyping && index == messages.length) {
                      return Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: TypingIndicator(),
                      );
                    }
                    final message = messages[index];
                    bool isLastMessage = index == messages.length - 1;
                    // bool isLink =
                    //     Uri.tryParse(message.text)?.isAbsolute ?? false;
                    final imageUrlRegex =
                        RegExp(r'\((http.*?\.jpg|http.*?\.png)\)');
                    final imageUrlMatch =
                        imageUrlRegex.firstMatch(message.text);
                    final imageUrl = imageUrlMatch?.group(1) ?? '';
                    final imageUrlWithCors =
                        'https://cors-anywhere.herokuapp.com/$imageUrl';

                    final displayText =
                        message.text.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
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
                                  constraints: BoxConstraints(
                                    maxWidth:
                                        MediaQuery.of(context).size.width * 0.7,
                                  ),
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
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Linkify(
                                        onOpen: (link) async {
                                          if (await canLaunch(link.url)) {
                                            await launch(link.url);
                                          }
                                        },
                                        text: displayText,
                                        linkStyle:
                                            TextStyle(color: Colors.blue),
                                        style: TextStyle(color: Colors.white),
                                      ),
                                      if (imageUrl.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 8.0),
                                          child: Image.network(
                                            imageUrlWithCors, // <-- This is the updated line
                                            width: 150,
                                            height: 150,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Text(
                                                  'Failed to load image: $error');
                                            },
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                              ),
                              if (!message.isUserMessage && index != 0) ...[
                                IconButton(
                                  icon: Icon(Icons.thumb_up,
                                      color: message.liked
                                          ? Colors.green
                                          : Colors.grey),
                                  onPressed: () =>
                                      handleLikeDislike(index, true),
                                ),
                                IconButton(
                                  icon: Icon(Icons.thumb_down,
                                      color: message.disliked
                                          ? Colors.red
                                          : Colors.grey),
                                  onPressed: () =>
                                      handleLikeDislike(index, false),
                                ),
                              ],
                            ],
                          ),
                        ),
                        if (isLastMessage &&
                            !message.isUserMessage &&
                            index != 0)
                          isLoading
                              ? CircularProgressIndicator()
                              : ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    primary: Color(0xfff9dea6),
                                    onPrimary: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
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
                        onSubmitted: (text) {
                          if (text.isNotEmpty) {
                            currentPartition = 0;
                            sendMessage(text);
                            textController.clear();
                          }
                        },
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
                        if (message.isNotEmpty) {
                          textController.clear();
                          currentPartition = 0;
                          sendMessage(message);
                        }
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
  bool liked;
  bool disliked;
  String? id;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    this.liked = false,
    this.disliked = false,
    this.id,
  });
}
