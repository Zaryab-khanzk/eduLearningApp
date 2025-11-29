class BookListing {
  final String bookId;
  final String userId;
  final String title;
  final String author;
  final String bookCondition;
  final double price;
  final String status;
  final DateTime createdAt;

  BookListing({
    required this.bookId,
    required this.userId,
    required this.title,
    required this.author,
    required this.bookCondition,
    required this.price,
    required this.status,
    required this.createdAt,
  });

  factory BookListing.fromJson(Map<String, dynamic> json) {
    return BookListing(
      bookId: json['book_id'] as String,
      userId: json['user_id'] as String,
      title: json['title'] as String,
      author: json['author'] as String,
      bookCondition: json['book_condition'] as String,
      price: (json['price'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'book_id': bookId,
      'user_id': userId,
      'title': title,
      'author': author,
      'book_condition': bookCondition,
      'price': price,
      'status': status,
      'created_at': createdAt.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'BookListing(bookId: $bookId, title: $title, price: $price, status: $status)';
  }
}