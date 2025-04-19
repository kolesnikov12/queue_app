import 'package:queue_app/models/team_model.dart';

class ChampionshipModel {
  final String id;
  final String name;
  final String creatorId;
  final String creatorName;
  final List<TeamModel> teams;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? endedAt;
  final String description;
  final String qrCode;
  final int maxTeams;
  final ChampionshipStatus status;

  ChampionshipModel({
    required this.id,
    required this.name,
    required this.creatorId,
    required this.creatorName,
    required this.teams,
    required this.isActive,
    required this.createdAt,
    this.endedAt,
    this.description = '',
    required this.qrCode,
    this.maxTeams = 10,
    this.status = ChampionshipStatus.pending,
  });

  factory ChampionshipModel.fromMap(Map<String, dynamic> map) {
    return ChampionshipModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      creatorId: map['creatorId'] ?? '',
      creatorName: map['creatorName'] ?? '',
      teams: map['teams'] != null
          ? List<TeamModel>.from(
              (map['teams'] as List).map(
                (x) => TeamModel.fromMap(x),
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
      qrCode: map['qrCode'] ?? '',
      maxTeams: map['maxTeams'] ?? 10,
      status: ChampionshipStatus.values[map['status'] ?? 0],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'creatorId': creatorId,
      'creatorName': creatorName,
      'teams': teams.map((x) => x.toMap()).toList(),
      'isActive': isActive,
      'createdAt': createdAt,
      'endedAt': endedAt,
      'description': description,
      'qrCode': qrCode,
      'maxTeams': maxTeams,
      'status': status.index,
    };
  }

  ChampionshipModel copyWith({
    String? id,
    String? name,
    String? creatorId,
    String? creatorName,
    List<TeamModel>? teams,
    bool? isActive,
    DateTime? createdAt,
    DateTime? endedAt,
    String? description,
    String? qrCode,
    int? maxTeams,
    ChampionshipStatus? status,
  }) {
    return ChampionshipModel(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorId: creatorId ?? this.creatorId,
      creatorName: creatorName ?? this.creatorName,
      teams: teams ?? this.teams,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      endedAt: endedAt ?? this.endedAt,
      description: description ?? this.description,
      qrCode: qrCode ?? this.qrCode,
      maxTeams: maxTeams ?? this.maxTeams,
      status: status ?? this.status,
    );
  }
}

enum ChampionshipStatus {
  pending,   // Очікування на початок
  active,    // Активний
  finished,  // Завершений
  canceled   // Скасований
}