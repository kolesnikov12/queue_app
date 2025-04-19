class TeamMember {
  final String userId;
  final String name;
  final String? photoUrl;
  final String avatarType;
  final DateTime joinedAt;
  final bool isLeader;

  TeamMember({
    required this.userId,
    required this.name,
    this.photoUrl,
    required this.avatarType,
    required this.joinedAt,
    this.isLeader = false,
  });

  factory TeamMember.fromMap(Map<String, dynamic> map) {
    return TeamMember(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      avatarType: map['avatarType'] ?? 'default',
      joinedAt: map['joinedAt'] != null
          ? (map['joinedAt'] as dynamic).toDate()
          : DateTime.now(),
      isLeader: map['isLeader'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'avatarType': avatarType,
      'joinedAt': joinedAt,
      'isLeader': isLeader,
    };
  }
}

class TeamModel {
  final String id;
  final String name;
  final String creatorId;
  final String championshipId;
  final List<TeamMember> members;
  final String qrCode;
  final int wins;
  final int losses;
  final int draws;
  final DateTime createdAt;
  final String? logoUrl;
  final String color;

  TeamModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.championshipId,
    required this.members,
    required this.qrCode,
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    required this.createdAt,
    this.logoUrl,
    required this.color,
  });

  factory TeamModel.fromMap(Map<String, dynamic> map) {
    return TeamModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      creatorId: map['creatorId'] ?? '',
      championshipId: map['championshipId'] ?? '',
      members: map['members'] != null
          ? List<TeamMember>.from(
              (map['members'] as List).map(
                (x) => TeamMember.fromMap(x),
              ),
            )
          : [],
      qrCode: map['qrCode'] ?? '',
      wins: map['wins'] ?? 0,
      losses: map['losses'] ?? 0,
      draws: map['draws'] ?? 0,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      logoUrl: map['logoUrl'],
      color: map['color'] ?? '#4D65FF',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'championshipId': championshipId,
      'members': members.map((x) => x.toMap()).toList(),
      'qrCode': qrCode,
      'wins': wins,
      'losses': losses,
      'draws': draws,
      'createdAt': createdAt,
      'logoUrl': logoUrl,
      'color': color,
    };
  }

  TeamModel copyWith({
    String? id,
    String? name,
    String? creatorId,
    String? championshipId,
    List<TeamMember>? members,
    String? qrCode,
    int? wins,
    int? losses,
    int? draws,
    DateTime? createdAt,
    String? logoUrl,
    String? color,
  }) {
    return TeamModel(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      championshipId: championshipId ?? this.championshipId,
      members: members ?? this.members,
      qrCode: qrCode ?? this.qrCode,
      wins: wins ?? this.wins,
      losses: losses ?? this.losses,
      draws: draws ?? this.draws,
      createdAt: createdAt ?? this.createdAt,
      logoUrl: logoUrl ?? this.logoUrl,
      color: color ?? this.color,
    );
  }
}