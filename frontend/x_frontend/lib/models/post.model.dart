class Post {
  final String id;
  final User user; // Instance of User
  final String text;
  final String? img;
  final List<String> likes;
  final List<Comment> comments;
  final DateTime createdAt;
  bool isHovered = false; // Added hover state


  Post({
    required this.id,
    required this.user,
    required this.text,
    this.img,
    required this.likes,
    required this.comments,
    required this.createdAt,
  });

  // Factory to parse JSON into Post
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'],
      user: User.fromJson(json['user']), // Parse User object
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

  // Method to convert Post to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toJson(), // Convert User to JSON
      'text': text,
      'img': img,
      'likes': likes,
      'comments': comments.map((e) => e.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }
}

class User {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final String profileImg;
  final String coverImg;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.profileImg,
    required this.coverImg,
  });

  // Factory to parse JSON into User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      username: json['username'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      profileImg: json['profileImg'] ?? '',
      coverImg: json['coverImg'] ?? '',
    );
  }

  // Method to convert User to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'profileImg': profileImg,
      'coverImg': coverImg,
    };
  }
}

class Comment {
  final String text;
  final User user; // Use User instead of just userId for richer data

  Comment({
    required this.text,
    required this.user,
  });

  // Factory to parse JSON into Comment
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      text: json['text'] ?? '',
      user: User.fromJson(json['user']), // Parse user details into User object
    );
  }

  // Method to convert Comment to JSON
  Map<String, dynamic> toJson() {
    return {
      'text': text,
      'user': user.toJson(), // Convert User to JSON
    };
  }
}
