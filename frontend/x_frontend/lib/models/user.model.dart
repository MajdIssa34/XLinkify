class User {
  final String id;
  final String username;
  final String fullName;
  final String email;
  final List<String> followers;
  final List<String> following;
  final String profileImg;
  final String coverImg;
  final String bio;
  final String link;

  User({
    required this.id,
    required this.username,
    required this.fullName,
    required this.email,
    required this.followers,
    required this.following,
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
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
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
      'followers': followers,
      'following': following,
      'profileImg': profileImg,
      'coverImg': coverImg,
      'bio': bio,
      'link': link,
    };
  }
}
