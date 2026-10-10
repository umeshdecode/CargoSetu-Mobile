class ChatConversationModel {
  final int? id;
  final int? listingId;
  final int? bookingId;
  final int? participant1CompanyId;
  final int? participant2CompanyId;
  final String? otherPartyName;
  final String? status;
  final String? lastMessageAt;

  ChatConversationModel({
    this.id,
    this.listingId,
    this.bookingId,
    this.participant1CompanyId,
    this.participant2CompanyId,
    this.otherPartyName,
    this.status,
    this.lastMessageAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: json['id'] as int?,
      listingId: json['listingId'] as int?,
      bookingId: json['bookingId'] as int?,
      participant1CompanyId: json['participant1CompanyId'] as int?,
      participant2CompanyId: json['participant2CompanyId'] as int?,
      otherPartyName: json['otherPartyName']?.toString(),
      status: json['status']?.toString(),
      lastMessageAt: json['lastMessageAt']?.toString(),
    );
  }
}

class ChatMessageModel {
  final int? id;
  final int? conversationId;
  final int? senderStaffId;
  final int? senderCompanyId;
  final String message;
  final String messageType;
  final String? attachmentRef;
  final String? sentAt;
  final String? readAt;
  final bool isMe;

  ChatMessageModel({
    this.id,
    this.conversationId,
    this.senderStaffId,
    this.senderCompanyId,
    required this.message,
    this.messageType = 'TEXT',
    this.attachmentRef,
    this.sentAt,
    this.readAt,
    this.isMe = false,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json, {int? currentStaffId}) {
    final senderStaff = json['senderStaffId'] as int?;
    return ChatMessageModel(
      id: json['id'] as int?,
      conversationId: json['conversationId'] as int?,
      senderStaffId: senderStaff,
      senderCompanyId: json['senderCompanyId'] as int?,
      message: json['message']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'TEXT',
      attachmentRef: json['attachmentRef']?.toString(),
      sentAt: json['sentAt']?.toString(),
      readAt: json['readAt']?.toString(),
      isMe: (currentStaffId != null && senderStaff == currentStaffId),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'messageType': messageType,
      if (attachmentRef != null) 'attachmentRef': attachmentRef,
    };
  }
}
