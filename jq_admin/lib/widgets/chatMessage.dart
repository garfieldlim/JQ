class ChatMessage {
  final String text;
  final bool isUserMessage;
  bool liked;
  bool disliked;
  String? id;
  String? foreignId;
  bool quoted;
  String? milvusData; // Nullable field
  String? partitionName; // Nullable field

  ChatMessage({
    required this.text,
    required this.isUserMessage,
    this.liked = false,
    this.disliked = false,
    this.id,
    this.quoted = false,
    this.milvusData,
    this.partitionName,
    this.foreignId,
  });

  Map<String, dynamic> toJson() {
    var map = <String, dynamic>{
      'text': text,
      'isUserMessage': isUserMessage,
      'id': id, // Optionally include if needed
    };

    if (!isUserMessage) {
      map['liked'] = liked;
      map['disliked'] = disliked;

      // Only add milvusData and partitionName if they are not null
      if (milvusData != null) {
        map['milvusData'] = milvusData;
      }
      if (partitionName != null) {
        map['partitionName'] = partitionName;
      }
    }

    return map;
  }
}
