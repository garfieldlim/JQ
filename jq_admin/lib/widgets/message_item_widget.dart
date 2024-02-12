import 'package:flutter/material.dart';
import 'package:jq_admin/screens/loading.dart'; // Ensure this exists or replace with actual loading widget
import 'package:jq_admin/widgets/chatMessage.dart'; // Ensure this exists or replace with actual message model
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

class MessageItem extends StatelessWidget {
  final int index;
  final bool isTyping;
  final List<ChatMessage>
      messages; // Assume ChatMessage is a model class you have
  final Function handleLikeDislike;
  final Function handleQuote;
  final Function regenerateMessage;

  const MessageItem({
    super.key,
    required this.index,
    required this.isTyping,
    required this.messages,
    required this.handleLikeDislike,
    required this.handleQuote,
    required this.regenerateMessage,
  });

  Widget buildMessageItem(BuildContext context) {
    if (isTyping && index == messages.length) {
      return const Padding(
        padding: EdgeInsets.all(20.0),
        child:
            TypingIndicator(), // Ensure this exists or replace with actual typing indicator widget
      );
    }

    final message = messages[index];
    final bool isLastMessage = index == messages.length - 1;

    final imageUrlRegex =
        RegExp(r'\bhttps?:\/\/.*\.(?:png|jpg|jpeg)\b', caseSensitive: false);
    final imageUrlMatch = imageUrlRegex.firstMatch(message.text);
    final imageUrl = imageUrlMatch?.group(0) ?? '';
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
              if (!message.isUserMessage)
                Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: CircleAvatar(
                    backgroundColor: const Color(0xff969d7b),
                    child: Image.asset(
                        'web/assets/logo2.png'), // Make sure this asset exists
                  ),
                ),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.7,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                    color: message.isUserMessage
                        ? const Color(0xfff2c87e)
                        : const Color(0xff969d7b),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 15,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Linkify(
                        onOpen: (link) async {
                          if (await canLaunchUrl(Uri.parse(link.url))) {
                            await launchUrl(Uri.parse(link.url));
                          }
                        },
                        text: displayText,
                        linkStyle: const TextStyle(color: Colors.blue),
                        style: const TextStyle(color: Colors.white),
                      ),
                      if (imageUrl.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Center(
                            child: Image.network(
                              imageUrl,
                              width: 150,
                              height: 150,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                    child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Text('Failed to load image');
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (!message.isUserMessage && index != 0) ...[
                Tooltip(
                  message: 'Like',
                  child: IconButton(
                    icon: Icon(Icons.thumb_up,
                        color: message.liked ? Colors.green : Colors.grey),
                    onPressed: () => handleLikeDislike(index, true),
                  ),
                ),
                Tooltip(
                  message: 'Dislike',
                  child: IconButton(
                    icon: Icon(Icons.thumb_down,
                        color: message.disliked ? Colors.red : Colors.grey),
                    onPressed: () => handleLikeDislike(index, false),
                  ),
                ),
                Tooltip(
                  message: 'Reply',
                  child: IconButton(
                    icon: Icon(Icons.reply,
                        color: message.quoted ? Colors.blue : Colors.grey),
                    onPressed: () => handleQuote(index),
                  ),
                ),
              ],
            ],
          ),
        ),
        if (isLastMessage && !message.isUserMessage && index != 0)
          isTyping
              ? const Padding(
                  padding: EdgeInsets.all(20.0),
                  child: TypingIndicator(),
                )
              : ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: const Color(0xfff9dea6),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () => regenerateMessage(message),
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
