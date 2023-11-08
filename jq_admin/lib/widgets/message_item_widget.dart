import 'package:flutter/material.dart';
import 'package:jq_admin/screens/loading.dart';
import 'package:jq_admin/widgets/chatMessage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class MessageItem extends StatelessWidget {
  final int index;
  final bool isTyping;
  final List<ChatMessage> messages; // Use ChatMessage here
  final Function handleLikeDislike;
  final Function handleQuote;
  final Function regenerateMessage;
  final bool isLoading;

  const MessageItem({super.key, 
    required this.index,
    required this.isTyping,
    required this.messages,
    required this.handleLikeDislike,
    required this.handleQuote,
    required this.regenerateMessage,
    required this.isLoading,
  });

  Widget buildMessageItem(BuildContext context) {
    if (isTyping && index == messages.length) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child: TypingIndicator(),
      );
    }

    final message = messages[index];
    bool isLastMessage = index == messages.length - 1;

    final imageUrlRegex = RegExp(r'\((http.*?\.jpg|http.*?\.png)\)');
    final imageUrlMatch = imageUrlRegex.firstMatch(message.text);
    final imageUrl = imageUrlMatch?.group(1) ?? '';
    final imageUrlWithCors = 'https://cors-anywhere.herokuapp.com/$imageUrl';
    final displayText = message.text.replaceAll(RegExp(r'\[.*?\]\(.*?\)'), '');
    return Column(
      children: [
        Container(
          margin: const EdgeInsets.all(20),
          child: Row(
            mainAxisAlignment: message.isUserMessage
                ? MainAxisAlignment.end
                : MainAxisAlignment.start,
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: message.isUserMessage
                        ? const Color(0xffdcd8b0)
                        : const Color(0xffbec59a),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Linkify(
                        onOpen: (link) async {
                          if (await canLaunch(link.url)) {
                            await launch(link.url);
                          }
                        },
                        text: displayText,
                        linkStyle: const TextStyle(color: Colors.blue),
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (imageUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(
                            imageUrlWithCors,
                            width: 150,
                            height: 150,
                            errorBuilder: (context, error, stackTrace) {
                              return Text('Failed to load image: $error');
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
                      color: message.liked ? Colors.green : Colors.grey),
                  onPressed: () => handleLikeDislike(index, true),
                ),
                IconButton(
                  icon: Icon(Icons.thumb_down,
                      color: message.disliked ? Colors.red : Colors.grey),
                  onPressed: () => handleLikeDislike(index, false),
                ),
                IconButton(
                  icon: Icon(Icons.format_quote,
                      color: message.quoted ? Colors.blue : Colors.grey),
                  onPressed: () => handleQuote(index),
                ),
              ],
            ],
          ),
        ),
        if (isLastMessage && !message.isUserMessage && index != 0)
          isLoading
              ? const CircularProgressIndicator()
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white, backgroundColor: const Color(0xfff9dea6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    regenerateMessage(message);
                  },
                  child: const Text('Regenerate'),
                ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return buildMessageItem(context);
  }
}
