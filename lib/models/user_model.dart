class UserModel {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final String avatarType;
  final int gamesWon;
  final int gamesPlayed;
  final int points;
  final List<String> achievements;
  final List<String> purchasedSkins;
  final String currentSkin;
  final DateTime createdAt;
  final DateTime lastLogin;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    required this.avatarType,
    this.gamesWon = 0,
    this.gamesPlayed = 0,
    this.points = 0,
    this.achievements = const [],
    this.purchasedSkins = const [],
    required this.currentSkin,
    required this.createdAt,
    required this.lastLogin,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      photoUrl: map['photoUrl'],
      avatarType: map['avatarType'] ?? 'default',
      gamesWon: map['gamesWon'] ?? 0,
      gamesPlayed: map['gamesPlayed'] ?? 0,
      points: map['points'] ?? 0,
      achievements: List<String>.from(map['achievements'] ?? []),
      purchasedSkins: List<String>.from(map['purchasedSkins'] ?? []),
      currentSkin: map['currentSkin'] ?? 'default',
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      lastLogin: map['lastLogin'] != null
          ? (map['lastLogin'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'avatarType': avatarType,
      'gamesWon': gamesWon,
      'gamesPlayed': gamesPlayed,
      'points': points,
      'achievements': achievements,
      'purchasedSkins': purchasedSkins,
      'currentSkin': currentSkin,
      'createdAt': createdAt,
      'lastLogin': lastLogin,
    };
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? photoUrl,
    String? avatarType,
    int? gamesWon,
    int? gamesPlayed,
    int? points,
    List<String>? achievements,
    List<String>? purchasedSkins,
    String? currentSkin,
    DateTime? createdAt,
    DateTime? lastLogin,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      avatarType: avatarType ?? this.avatarType,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesPlayed: gamesPlayed ?? this.gamesPlayed,
      points: points ?? this.points,
      achievements: achievements ?? this.achievements,
      purchasedSkins: purchasedSkins ?? this.purchasedSkins,
      currentSkin: currentSkin ?? this.currentSkin,
      createdAt: createdAt ?? this.createdAt,
      lastLogin: lastLogin ?? this.lastLogin,
    );
  }
}