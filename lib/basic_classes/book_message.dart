class BookMessage {
  final String messageId;
  final String bookId;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime sentAt;

  BookMessage({
    required this.messageId,
    required this.bookId,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.sentAt,
  });

  factory BookMessage.fromJson(Map<String, dynamic> json) {
    return BookMessage(
      messageId: json['message_id'] as String,
      bookId: json['book_id'] as String,
      senderId: json['sender_id'] as String,
      receiverId: json['receiver_id'] as String,
      message: json['message'] as String,
      sentAt: DateTime.parse(json['sent_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message_id': messageId,
      'book_id': bookId,
      'sender_id': senderId,
      'receiver_id': receiverId,
      'message': message,
      'sent_at': sentAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BookMessage(messageId: $messageId, bookId: $bookId, senderId: $senderId, sentAt: $sentAt)';
  }
}