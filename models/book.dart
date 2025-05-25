class Book {
  final String id;
  final String title;
  final String? author;
  final String? imageUrl;

  Book({
    required this.id,
    required this.title,
    this.author,
    this.imageUrl,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json['id'],
      title: json['volumeInfo']['title'],
      author: json['volumeInfo']['authors'] != null
          ? json['volumeInfo']['authors'].join(', ')
          : 'Unknown Author',
      imageUrl: json['volumeInfo']['imageLinks'] != null
          ? json['volumeInfo']['imageLinks']['thumbnail']
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'author': author,
      'imageUrl': imageUrl,
    };
  }

  factory Book.fromMap(Map<String, dynamic> map) {
    return Book(
      id: map['id'],
      title: map['title'],
      author: map['author'],
      imageUrl: map['imageUrl'],
    );
  }
}