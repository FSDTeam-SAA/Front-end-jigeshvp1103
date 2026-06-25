import 'chat_message.dart';

class ChatThreadInfo {
  final String id;
  final String tableId;
  final String createdByUserId;
  final String title;
  final String starterMessage;
  final bool assessmentMarked;
  final bool isUnanswered;
  final DateTime? lastActivityAt;

  const ChatThreadInfo({
    required this.id,
    required this.tableId,
    required this.createdByUserId,
    required this.title,
    required this.starterMessage,
    required this.assessmentMarked,
    required this.isUnanswered,
    this.lastActivityAt,
  });

  factory ChatThreadInfo.fromJson(Map<String, dynamic> json) {
    return ChatThreadInfo(
      id: (json['_id'] ?? json['threadId'] ?? '').toString(),
      tableId: (json['tableId'] ?? '').toString(),
      createdByUserId: _ownerIdFromJson(json),
      title: (json['title'] ?? '').toString(),
      starterMessage: (json['starterMessage'] ?? '').toString(),
      assessmentMarked: json['assessmentMarked'] == true,
      isUnanswered: json['isUnanswered'] == true,
      lastActivityAt: DateTime.tryParse('${json['lastActivityAt'] ?? ''}'),
    );
  }
}

String _ownerIdFromJson(Map<String, dynamic> json) {
  for (final key in const [
    'createdByUserId',
    'userId',
    'createdBy',
    'createdByUser',
    'ownerId',
  ]) {
    final value = json[key];
    if (value == null) continue;

    if (value is Map<String, dynamic>) {
      for (final idKey in const ['_id', 'userId', 'id']) {
        final nestedId = value[idKey]?.toString().trim() ?? '';
        if (nestedId.isNotEmpty) return nestedId;
      }
    }

    final id = value.toString().trim();
    if (id.isNotEmpty) return id;
  }

  return '';
}

class ChatThreadDetail {
  final ChatThreadInfo? thread;
  final List<ChatMessage> messages;
  final bool? userContributed;
  final bool canParticipate;

  const ChatThreadDetail({
    required this.thread,
    required this.messages,
    this.userContributed,
    this.canParticipate = false,
  });

  factory ChatThreadDetail.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final dataJson = data is Map<String, dynamic> ? data : json;
    final thread = dataJson['thread'];
    final messages = dataJson['messages'];

    return ChatThreadDetail(
      thread: thread is Map<String, dynamic>
          ? ChatThreadInfo.fromJson(thread)
          : null,
      messages: messages is List
          ? messages
              .whereType<Map<String, dynamic>>()
              .map(ChatMessage.fromJson)
              .toList()
          : const [],
      userContributed: dataJson['userContributed'] is bool
          ? dataJson['userContributed'] as bool
          : null,
      canParticipate: dataJson['canParticipate'] == true,
    );
  }
}
