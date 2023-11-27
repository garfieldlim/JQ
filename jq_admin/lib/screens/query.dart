// Dart SDK imports
import 'dart:convert';

// Third-party package imports
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jq_admin/widgets/chatMessage.dart';
import 'package:jq_admin/widgets/chat_suggestions.dart';
import 'package:jq_admin/widgets/customfloatingbutton.dart';
import 'package:jq_admin/widgets/floatingactionbutton.dart';
import 'package:uuid/uuid.dart';
import '../widgets/chat_input.dart';
import '../widgets/headlines.dart';
import '../widgets/message_item_widget.dart';

//-------------------------------------
// HomePage Stateful Widget
//-------------------------------------
class HomePage extends StatefulWidget {
  const HomePage({super.key});

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
  int flag = 0;
  bool isLoading = false;
  bool isTyping = false;
  List<dynamic> posts = [];
  var uuid = Uuid();
  var userMessageId;
  var botMessageId;

  @override
  void initState() {
    super.initState();
    initPosts();
  }

  Future<void> initPosts() async {
    try {
      var fetchedPosts = await fetchPosts();

      setState(() {
        posts = fetchedPosts;
      });
    } catch (e) {
      print('Failed to fetch posts: $e');
    }
  }

  void resetChat() {
    setState(() {
      messages = [
        ChatMessage(text: "How may I help you?", isUserMessage: false),
      ];
    });

    // Optionally: Remove chat messages from Cloud Firestore.
  }

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse('http://127.0.0.1:7999/posts'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> sendMessage(String message, {int? partition}) async {
    // Add the user message to the messages list if partition is null
    if (partition == null) {
      setState(() {
        messages.add(ChatMessage(text: message, isUserMessage: true));
      });
    }

    final url = Uri.parse('http://127.0.0.1:7999/query');
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
      if (messages.isNotEmpty && partition != null) {
        messages.removeLast();
      }

      setState(() {
        isLoading = false;
        isTyping = false;
      });

      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
        var responseData = data['response'] as String;
        var milvusData =
            jsonEncode(data['milvusData']); // Extract from response
        var partitionName =
            data['partitionName'] as String; // Extract from response

        setState(() {
          messages.add(ChatMessage(
            text: responseData,
            isUserMessage: false,
            liked: false,
            disliked: false,
            milvusData: milvusData, // Set here
            partitionName: partitionName, // Set here
          ));
        });
        flag = 1;
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
    if (index > 0 && index < messages.length) {
      var userMessage = messages[index - 1];
      var botMessage = messages[index];

      setState(() {
        botMessage.liked = isLiked;
        botMessage.disliked = !isLiked;
      });

      var endpoint = 'http://127.0.0.1:7999/update_chat_message_like_dislike';

      if (flag == 1) {
        endpoint = 'http://127.0.0.1:7999/save_chat_message';
        userMessageId = "Chat${uuid.v4()}";
        botMessageId = "Chat${uuid.v4()}";
        flag = 0;
      }

      http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'userMessageId': userMessageId,
          'botMessageId': botMessageId,
          'userMessage': userMessage.toJson(),
          'botMessage': botMessage.toJson(),
          'liked': isLiked,
          'disliked': !isLiked,
          'milvusData': botMessage.milvusData,
          'partitionName': botMessage.partitionName ?? '',
        }),
      );
    } else {
      print('Error: Index out of bounds or Document ID is null.');
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
        backgroundColor: const Color(0xfffff1e4),
        floatingActionButton: buildFloatingActionButton(resetChat: resetChat),
        floatingActionButtonLocation: CustomFloatingActionButtonLocation(80, 0),
        extendBodyBehindAppBar: true,
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return Center(
      child: Column(
        children: [
          FacebookPostsList(posts: posts),
          _buildMessagesList(),
          ChatSuggestions(
            textController: textController,
            onSuggestionSelected: (suggestion) {
              sendMessage(suggestion);
            },
          ),
          const Divider(height: 1, color: Color(0xff969d7b)),
          MessageInput(
            textController: textController,
            sendMessage: sendMessage,
            currentPartition: currentPartition,
          ),
        ],
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
          isTyping: isTyping,
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
