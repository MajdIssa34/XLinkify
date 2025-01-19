class User {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final List<String> watchlist;
  final String profileImg;
  final String coverImg;
  final String bio;
  final String link;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.watchlist,
    required this.profileImg,
    required this.coverImg,
    required this.bio,
    required this.link,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'],
      username: json['username'],
      fullName: json['fullName'],
      email: json['email'],
      watchlist: List<String>.from(json['watchlist'] ?? []),
      profileImg: json['profileImg'] ?? '',
      coverImg: json['coverImg'] ?? '',
      bio: json['bio'] ?? '',
      link: json['link'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'username': username,
      'fullName': fullName,
      'email': email,
      'watchlist' : watchlist,
      'profileImg': profileImg,
      'coverImg': coverImg,
      'bio': bio,
      'link': link,
    };
  }
}
