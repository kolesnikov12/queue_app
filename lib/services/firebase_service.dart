import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:queue_app/models/championship_model.dart';
import 'package:queue_app/models/queue_model.dart';
import 'package:queue_app/models/team_model.dart';
import 'package:queue_app/models/user_model.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // Методи для роботи з користувачами

  // Отримання даних користувача за ID
  Future<UserModel?> getUserById(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final userDoc = await _firestore.collection('users').doc(userId).get();

      _isLoading = false;
      notifyListeners();

      if (userDoc.exists) {
        return UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання списку користувачів
  Future<List<UserModel>> getUsersList() async {
    try {
      _isLoading = true;
      notifyListeners();

      final usersSnapshot = await _firestore.collection('users').get();

      final users = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();

      return users;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання топових користувачів за очками
  Future<List<UserModel>> getTopUsers({int limit = 10}) async {
    try {
      _isLoading = true;
      notifyListeners();

      final usersSnapshot = await _firestore
          .collection('users')
          .orderBy('points', descending: true)
          .limit(limit)
          .get();

      final users = usersSnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();

      return users;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Методи для роботи з чергами

  // Отримання списку активних черг
  Future<List<QueueModel>> getActiveQueues() async {
    try {
      _isLoading = true;
      notifyListeners();

      final queuesSnapshot = await _firestore
          .collection('queues')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final queues = queuesSnapshot.docs
          .map((doc) => QueueModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();

      return queues;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання черги за ID
  Future<QueueModel?> getQueueById(String queueId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final queueDoc = await _firestore.collection('queues').doc(queueId).get();

      _isLoading = false;
      notifyListeners();

      if (queueDoc.exists) {
        return QueueModel.fromMap(queueDoc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Методи для роботи з чемпіонатами

  // Створення нового чемпіонату
  Future<ChampionshipModel> createChampionship({
    required String name,
    required String creatorId,
    required String creatorName,
    required String qrCode,
    String description = '',
    int maxTeams = 10,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Створюємо документ в Firestore
      final championshipRef = _firestore.collection('championships').doc();

      // Створюємо модель чемпіонату
      final newChampionship = ChampionshipModel(
        id: championshipRef.id,
        name: name,
        creatorId: creatorId,
        creatorName: creatorName,
        teams: [],
        isActive: true,
        createdAt: DateTime.now(),
        description: description,
        qrCode: qrCode,
        maxTeams: maxTeams,
      );

      // Зберігаємо чемпіонат в Firestore
      await championshipRef.set(newChampionship.toMap());

      _isLoading = false;
      notifyListeners();

      return newChampionship;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання списку активних чемпіонатів
  Future<List<ChampionshipModel>> getActiveChampionships() async {
    try {
      _isLoading = true;
      notifyListeners();

      final championshipsSnapshot = await _firestore
          .collection('championships')
          .where('isActive', isEqualTo: true)
          .orderBy('createdAt', descending: true)
          .get();

      final championships = championshipsSnapshot.docs
          .map((doc) => ChampionshipModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();

      return championships;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання чемпіонату за ID
  Future<ChampionshipModel?> getChampionshipById(String championshipId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final championshipDoc = await _firestore.collection('championships').doc(championshipId).get();

      _isLoading = false;
      notifyListeners();

      if (championshipDoc.exists) {
        return ChampionshipModel.fromMap(championshipDoc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Методи для роботи з командами

  // Створення нової команди
  Future<TeamModel> createTeam({
    required String name,
    required String creatorId,
    required String championshipId,
    required String qrCode,
    required TeamMember leader,
    required String color,
    String? logoUrl,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Створюємо документ в Firestore
      final teamRef = _firestore.collection('teams').doc();

      // Створюємо модель команди
      final newTeam = TeamModel(
        id: teamRef.id,
        name: name,
        creatorId: creatorId,
        championshipId: championshipId,
        members: [leader],
        qrCode: qrCode,
        createdAt: DateTime.now(),
        logoUrl: logoUrl,
        color: color,
      );

      // Зберігаємо команду в Firestore
      await teamRef.set(newTeam.toMap());

      // Додаємо команду до чемпіонату
      await _firestore.collection('championships').doc(championshipId).update({
        'teams': FieldValue.arrayUnion([newTeam.toMap()]),
      });

      _isLoading = false;
      notifyListeners();

      return newTeam;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання команди за ID
  Future<TeamModel?> getTeamById(String teamId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final teamDoc = await _firestore.collection('teams').doc(teamId).get();

      _isLoading = false;
      notifyListeners();

      if (teamDoc.exists) {
        return TeamModel.fromMap(teamDoc.data() as Map<String, dynamic>);
      }

      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Приєднання до команди
  Future<bool> joinTeam({
    required String teamId,
    required TeamMember member,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Отримуємо дані про команду
      final teamDoc = await _firestore.collection('teams').doc(teamId).get();

      if (!teamDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final team = TeamModel.fromMap(teamDoc.data() as Map<String, dynamic>);

      // Перевіряємо, чи користувач вже в команді
      final isAlreadyMember = team.members.any((m) => m.userId == member.userId);

      if (isAlreadyMember) {
        _isLoading = false;
        notifyListeners();
        return true; // Користувач вже у команді
      }

      // Додаємо користувача до команди
      await _firestore.collection('teams').doc(teamId).update({
        'members': FieldValue.arrayUnion([member.toMap()]),
      });

      // Оновлюємо команду в чемпіонаті
      final updatedTeam = team.copyWith(
        members: [...team.members, member],
      );

      await _updateTeamInChampionship(updatedTeam);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Оновлення команди в чемпіонаті
  Future<void> _updateTeamInChampionship(TeamModel team) async {
    try {
      // Отримуємо чемпіонат
      final championshipDoc = await _firestore
          .collection('championships')
          .doc(team.championshipId)
          .get();

      if (!championshipDoc.exists) return;

      final championship = ChampionshipModel.fromMap(championshipDoc.data() as Map<String, dynamic>);

      // Знаходимо команду в списку
      final teamIndex = championship.teams.indexWhere((t) => t.id == team.id);

      if (teamIndex == -1) return;

      // Створюємо новий список команд з оновленою командою
      final updatedTeams = List<TeamModel>.from(championship.teams);
      updatedTeams[teamIndex] = team;

      // Оновлюємо чемпіонат
      await _firestore.collection('championships').doc(team.championshipId).update({
        'teams': updatedTeams.map((t) => t.toMap()).toList(),
      });
    } catch (e) {
      rethrow;
    }
  }
}