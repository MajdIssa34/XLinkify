class Post {
  final String id;
  final String userId;
  final String text;
  final String? img;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.userId,
    required this.text,
    this.img,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      userId: json['user'],
      text: json['text'] ?? '',
      img: json['img'],
      likes: List<String>.from(json['likes'] ?? []),
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e))
              .toList() ??
          [],
      createdAt: DateTime.parse(json['createdAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'text': text,
      'img': img,
      'likes': likes,
      'comments': comments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class Comment {
  final String text;
  final String userId;

  Comment({
    required this.text,
    required this.userId,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      text: json['text'],
      userId: json['user'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'user': userId,
    };
  }
}
