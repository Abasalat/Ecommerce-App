class ChatMessageModel {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final List<String>? recommendedProductIds;
  final ChatMessageType type;

  ChatMessageModel({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.recommendedProductIds,
    this.type = ChatMessageType.text,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      text: json['text'] as String,
      isUser: json['isUser'] as bool,
      timestamp: DateTime.parse(json['timestamp'] as String),
      recommendedProductIds: json['recommendedProductIds'] != null
          ? List<String>.from(json['recommendedProductIds'])
          : null,
      type: ChatMessageType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => ChatMessageType.text,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'text': text,
      'isUser': isUser,
      'timestamp': timestamp.toIso8601String(),
      'recommendedProductIds': recommendedProductIds,
      'type': type.name,
    };
  }
}

enum ChatMessageType {
  text,
  productRecommendation,
  categoryFilter,
  priceFilter,
}
