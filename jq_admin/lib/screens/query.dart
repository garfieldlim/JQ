// Dart SDK imports
import 'dart:convert';

// Third-party package imports
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jq_admin/screens/constants.dart';
import 'package:jq_admin/widgets/chatMessage.dart';
import 'package:jq_admin/widgets/chat_suggestions.dart';
import 'package:jq_admin/widgets/customfloatingbutton.dart';
import 'package:jq_admin/widgets/floatingactionbutton.dart';
import 'package:jq_admin/widgets/typing.dart';
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

  bool isTyping = false;
  List<dynamic> posts = [];
  var uuid = const Uuid();
  var userMessageId;
  var botMessageId;
  var prevMessage;

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
      currentPartition = 0;
    });
  }

  Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse(postsUrl));
    print(postsUrl);
    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  Future<void> regenerateMessage(ChatMessage message) async {
    if (currentPartition < 2) {
      currentPartition += 1;
      sendMessage(true, prevMessage, partition: currentPartition);
    } else {
      currentPartition = 0;
      sendMessage(true, prevMessage, partition: currentPartition);
    }
  }

  Future<void> sendMessage(bool isRegen, String message,
      {int? partition}) async {
    if (isRegen == false) {
      currentPartition = 0;
    }

    // Add the user message to the messages list if partition is null
    if (partition == null) {
      setState(() {
        messages.add(ChatMessage(text: message, isUserMessage: true));
      });
    }

    final url = Uri.parse(queryURL);
    final headers = {'Content-Type': 'application/json'};
    print(postsUrl);
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
      isTyping = true;
      prevMessage = fullMessage;
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

        isTyping = false; // Stop the typing indicator
        for (var msg in messages) {
          msg.quoted = false;
        }
      } else {
        print('Error: ${response.statusCode}');
        setState(() {
          isTyping = false; // Stop the typing indicator in case of error
        });
      }
    } catch (error) {
      print('Error: $error');
      setState(() {
        isTyping = false; // Ensure to stop typing indicator in case of error
      });
    }
  }

  void handleQuote(int index) {
    setState(() {
      // Check if the selected message is already quoted
      if (messages[index].quoted) {
        // If so, unquote it and do not quote anything else
        messages[index].quoted = false;
      } else {
        // Otherwise, reset all to unquoted and quote the selected message
        for (var msg in messages) {
          msg.quoted = false; // Reset other quoted messages
        }
        messages[index].quoted = true;
      }
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

      var endpoint = updateChatDislikeURL;

      if (flag == 1) {
        endpoint = saveChatURL;
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
          'userMessage': prevMessage,
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
        floatingActionButton:
            isTyping ? null : buildFloatingActionButton(resetChat: resetChat),
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
          FacebookPostsList(key: UniqueKey(), posts: posts),
          _buildMessagesList(),
          ChatSuggestions(
            textController: textController,
            onSuggestionSelected: (suggestion) {
              sendMessage(false, suggestion);
            },
          ),
          const Divider(height: 1, color: Color(0xff969d7b)),
          MessageInput(
            textController: textController,
            sendMessage: (String message) {
              sendMessage(false,
                  message); // Assuming false as the isRegen default value
            },
            isTyping: isTyping,
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
        itemBuilder: (context, index) {
          if (index == messages.length && isTyping) {
            return const TypingIndicator(); // Show typing indicator
          }
          return MessageItem(
            index: index,
            isTyping: isTyping,
            messages: messages,
            handleLikeDislike: handleLikeDislike,
            handleQuote: handleQuote,
            regenerateMessage: regenerateMessage,
          );
        },
      ),
    );
  }
}
