import 'package:cloud_firestore/cloud_firestore.dart';

class QueueMember {
  final String userId;
  final String name;
  final String? photoUrl;
  final String avatarType;
  final DateTime joinedAt;
  final int position;
  final bool isActive;

  QueueMember({
    required this.userId,
    required this.name,
    this.photoUrl,
    required this.avatarType,
    required this.joinedAt,
    required this.position,
    this.isActive = true,
  });

  factory QueueMember.fromMap(Map<String, dynamic> map) {
    return QueueMember(
      userId: map['userId'] ?? '',
      name: map['name'] ?? '',
      photoUrl: map['photoUrl'],
      avatarType: map['avatarType'] ?? 'default',
      joinedAt: map['joinedAt'] != null
          ? (map['joinedAt'] as dynamic).toDate()
          : DateTime.now(),
      position: map['position'] ?? 0,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'name': name,
      'photoUrl': photoUrl,
      'avatarType': avatarType,
      'joinedAt': joinedAt,
      'position': position,
      'isActive': isActive,
    };
  }
}

class QueueModel {
  final String id;
  final String name;
  final String creatorId;
  final String creatorName;
  final String qrCode;
  final List<QueueMember> members;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? endedAt;
  final String description;

  QueueModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.creatorName,
    required this.qrCode,
    required this.members,
    required this.isActive,
    required this.createdAt,
    this.endedAt,
    this.description = '',
  });

  factory QueueModel.fromMap(Map<String, dynamic> map) {
    return QueueModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      qrCode: map['qrCode'] ?? '',
      members: map['members'] != null
          ? List<QueueMember>.from(
              (map['members'] as List).map(
                (x) => QueueMember.fromMap(x),
              ),
            )
          : [],
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null
          ? (map['createdAt'] as dynamic).toDate()
          : DateTime.now(),
      endedAt: map['endedAt'] != null
          ? (map['endedAt'] as dynamic).toDate()
          : null,
      description: map['description'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'qrCode': qrCode,
      'members': members.map((x) => x.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt,
      'endedAt': endedAt,
      'description': description,
    };
  }

  QueueModel copyWith({
    String? id,
    String? name,
    String? creatorId,
    String? creatorName,
    String? qrCode,
    List<QueueMember>? members,
    bool? isActive,
    DateTime? createdAt,
    DateTime? endedAt,
    String? description,
  }) {
    return QueueModel(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      qrCode: qrCode ?? this.qrCode,
      members: members ?? this.members,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      description: description ?? this.description,
    );
  }
}