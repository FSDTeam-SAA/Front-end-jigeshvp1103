class ChatMessage {
  final String id;
  final String threadId;
  final String userId;
  final String type;
  final String content;
  final String? userName;
  final DateTime? createdAt;

  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.userId,
    required this.type,
    required this.content,
    this.userName,
    this.createdAt,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    final userJson = user is Map<String, dynamic> ? user : null;

    return ChatMessage(
      id: (json['_id'] ?? json['messageId'] ?? '').toString(),
      threadId: (json['threadId'] ?? '').toString(),
      userId: (json['userId'] ?? '').toString(),
      type: (json['type'] ?? 'text').toString(),
      content: (json['content'] ?? '').toString(),
      userName: (json['preferredName'] ??
              userJson?['preferredName'] ??
              json['userName'] ??
              json['authorName'] ??
              json['name'] ??
              userJson?['userName'] ??
              userJson?['name'])
          ?.toString(),
      createdAt: DateTime.tryParse('${json['createdAt'] ?? ''}'),
    );
  }
}
