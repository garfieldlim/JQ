import 'package:flutter/material.dart';
import 'package:jq_admin/screens/loading.dart'; // Ensure this exists or replace with actual loading widget
import 'package:jq_admin/widgets/chatMessage.dart'; // Ensure this exists or replace with actual message model
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:flutter_markdown/flutter_markdown.dart';

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
    final displayText = message.text;

    // Regex to identify media URLs (e.g., images or videos)
    final mediaUrlRegex = RegExp(r'\bhttps?:\/\/.*\.(png|jpg|jpeg|gif|mp4)\b',
        caseSensitive: false);
    final mediaUrlMatch = mediaUrlRegex.firstMatch(message.text);
    String? mediaURL = mediaUrlMatch?.group(0);

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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MarkdownBody(
                        data: displayText,
                        onTapLink: (text, href, title) {
                          if (href != null) {
                            launchUrl(Uri.parse(href));
                          }
                        },
                        styleSheet:
                            MarkdownStyleSheet.fromTheme(Theme.of(context))
                                .copyWith(
                          p: const TextStyle(
                              color: Colors
                                  .white), // Adjust the text color as needed
                          a: const TextStyle(
                              color: Colors.blue), // Style for links
                        ),
                      ),
                      // Check if mediaURL is not null or empty to display the image
                      if (mediaURL != null && mediaURL.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Image.network(mediaURL, fit: BoxFit.cover),
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
