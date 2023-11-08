class ChatMessage {
  final String text;
  final bool isUserMessage;
  bool liked;
  bool disliked;
  String? id;
  bool quoted;

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    this.liked = false,
    this.disliked = false,
    this.id,
    this.quoted = false,
  });
}
