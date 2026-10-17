class ChatConversationModel {
  final int? id;
  final int? listingId;
  final int? bookingId;
  final int? participant1CompanyId;
  final int? participant1StaffId;
  final int? participant2CompanyId;
  final int? participant2StaffId;
  final String? otherPartyName;
  final String? status;
  final String? lastMessageAt;

  ChatConversationModel({
    this.id,
    this.listingId,
    this.bookingId,
    this.participant1CompanyId,
    this.participant1StaffId,
    this.participant2CompanyId,
    this.participant2StaffId,
    this.otherPartyName,
    this.status,
    this.lastMessageAt,
  });

  factory ChatConversationModel.fromJson(Map<String, dynamic> json) {
    return ChatConversationModel(
      id: (json['id'] as num?)?.toInt(),
      listingId: (json['listingId'] as num?)?.toInt(),
      bookingId: (json['bookingId'] as num?)?.toInt(),
      participant1CompanyId: (json['participant1CompanyId'] as num?)?.toInt(),
      participant1StaffId: (json['participant1StaffId'] as num?)?.toInt(),
      participant2CompanyId: (json['participant2CompanyId'] as num?)?.toInt(),
      participant2StaffId: (json['participant2StaffId'] as num?)?.toInt(),
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
  final String? senderStaffName;
  final String? senderCompanyName;
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
    this.senderStaffName,
    this.senderCompanyName,
    required this.message,
    this.messageType = 'TEXT',
    this.attachmentRef,
    this.sentAt,
    this.readAt,
    this.isMe = false,
  });

  factory ChatMessageModel.fromJson(
    Map<String, dynamic> json, {
    int? currentStaffId,
    int? currentCompanyId,
  }) {
    final senderStaff = (json['senderStaffId'] as num?)?.toInt();
    final senderComp = (json['senderCompanyId'] as num?)?.toInt();
    final staffName = (json['senderStaffName'] ?? json['senderName'])
        ?.toString();
    final compName = json['senderCompanyName']?.toString();

    final bool matchesMe =
        (currentStaffId != null &&
            currentStaffId > 0 &&
            senderStaff != null &&
            senderStaff == currentStaffId) ||
        ((currentStaffId == null || currentStaffId <= 0) &&
            currentCompanyId != null &&
            currentCompanyId > 0 &&
            senderComp != null &&
            senderComp == currentCompanyId);

    return ChatMessageModel(
      id: (json['id'] as num?)?.toInt(),
      conversationId: (json['conversationId'] as num?)?.toInt(),
      senderStaffId: senderStaff,
      senderCompanyId: senderComp,
      senderStaffName: staffName,
      senderCompanyName: compName,
      message: json['message']?.toString() ?? '',
      messageType: json['messageType']?.toString() ?? 'TEXT',
      attachmentRef: json['attachmentRef']?.toString(),
      sentAt: json['sentAt']?.toString(),
      readAt: json['readAt']?.toString(),
      isMe: matchesMe,
    );
  }

  /// Formatted sender header label for chat bubble display.
  String senderDisplayHeader({
    String? currentUserName,
    String? fallbackOtherPartyName,
  }) {
    if (isMe) {
      final name =
          (senderStaffName != null && senderStaffName!.trim().isNotEmpty)
          ? senderStaffName!.trim()
          : ((currentUserName != null && currentUserName.trim().isNotEmpty)
                ? currentUserName.trim()
                : null);
      return name != null ? 'You · $name' : 'You';
    } else {
      final comp =
          (senderCompanyName != null && senderCompanyName!.trim().isNotEmpty)
          ? senderCompanyName!.trim()
          : ((fallbackOtherPartyName != null &&
                    fallbackOtherPartyName.trim().isNotEmpty)
                ? fallbackOtherPartyName.trim()
                : null);
      final staff =
          (senderStaffName != null && senderStaffName!.trim().isNotEmpty)
          ? senderStaffName!.trim()
          : null;
      if (comp != null && staff != null) {
        return '$comp · $staff';
      }
      return comp ?? staff ?? 'Partner';
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'messageType': messageType,
      if (attachmentRef != null) 'attachmentRef': attachmentRef,
    };
  }
}
