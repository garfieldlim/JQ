// Dart SDK imports
import 'dart:convert';

// Third-party package imports
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jq_admin/widgets/chatMessage.dart';
import 'package:jq_admin/widgets/chat_suggestions.dart';
import 'package:jq_admin/widgets/customfloatingbutton.dart';
import 'package:jq_admin/widgets/floatingactionbutton.dart';
import 'package:jq_admin/widgets/glassmorphic.dart';
import '../widgets/chat_input.dart';
import '../widgets/message_item_widget.dart';

//-------------------------------------
// HomePage Stateful Widget
//-------------------------------------
class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Variables
  List<ChatMessage> messages = [
    ChatMessage(text: "How may I help you?", isUserMessage: false),
  ];
  TextEditingController textController = TextEditingController();
  int currentPartition = 0;
  bool isLoading = false;
  bool isTyping = false;

  void resetChat() {
    setState(() {
      messages = [
        ChatMessage(text: "How may I help you?", isUserMessage: false),
      ];
    });

    // Optionally: Remove chat messages from Cloud Firestore.
  }

  Future<void> sendMessage(String message, {int? partition}) async {
    // Add the user message to the messages list if partition is null
    if (partition == null) {
      setState(() {
        messages.add(ChatMessage(text: message, isUserMessage: true));
      });
    }

    final url = Uri.parse('http://127.0.0.1:7999 /query');
    final headers = {'Content-Type': 'application/json'};

    // Getting the previous answer from the bot
    String? previousAnswer;
    for (var item in messages.reversed) {
      if (!item.isUserMessage) {
        previousAnswer = item.text;
        break;
      }
    }

    String fullMessage = message;

    for (var msg in messages) {
      if (msg.quoted) {
        fullMessage = "\"${msg.text}\" - Quoted\n\n$fullMessage";
        break;
      }
    }

    final body = jsonEncode({
      'question': fullMessage,
      'partition': partition ?? currentPartition,
      'prev': previousAnswer,
    });

    setState(() {
      isLoading = true;
      isTyping = true;
    });

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: body,
      );

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
        // var partitionName =
        //     data['partitionName'] as String; // Get the partition name
        // var milvusData = data['milvusData'] as String; // Get the Milvus data

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
          // 'partitionName': partitionName, // Store the partition name
          // 'milvusData': milvusData, // Store the Milvus data
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

  void handleQuote(int index) {
    setState(() {
      for (var msg in messages) {
        msg.quoted = false; // Reset other quoted messages
      }
      messages[index].quoted = true;
    });
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
        floatingActionButton: buildFloatingActionButton(resetChat: resetChat),
        floatingActionButtonLocation:
            CustomFloatingActionButtonLocation(100.0, 70),
        extendBodyBehindAppBar: true,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: GlassmorphicContainerWidget(
        widthPercentage: 0.9,
        heightPercentage: 0.9,
        color1: Color(0xffafbc8f),
        color2: Color(0xffafbc8f),
        child: Column(
          children: [
            _buildMessagesList(),
            ChatSuggestions(
              textController: textController,
              onSuggestionSelected: (suggestion) {
                sendMessage(suggestion);
              },
            ),
            Divider(height: 1, color: Colors.white),
            MessageInput(
              textController: textController,
              sendMessage: sendMessage,
              currentPartition: currentPartition,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessagesList() {
    return Expanded(
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: messages.length + (isTyping ? 1 : 0),
        itemBuilder: (context, index) => MessageItem(
          index: index,
          isTyping: isTyping, // Depending on your logic
          messages: messages,
          handleLikeDislike: handleLikeDislike,
          handleQuote: handleQuote,
          regenerateMessage: regenerateMessage,
          isLoading: isLoading,
        ),
      ),
    );
  }
}
