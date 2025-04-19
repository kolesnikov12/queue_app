import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:queue_app/models/queue_model.dart';
import 'package:queue_app/models/user_model.dart';
import 'package:queue_app/services/qr_service.dart';

class QueueService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final QrService _qrService = QrService();

  List<QueueModel> _userQueues = [];
  List<QueueModel> _joinedQueues = [];
  QueueModel? _activeQueue;
  bool _isLoading = false;

  List<QueueModel> get userQueues => _userQueues;
  List<QueueModel> get joinedQueues => _joinedQueues;
  QueueModel? get activeQueue => _activeQueue;
  bool get isLoading => _isLoading;

  // Створення нової черги
  Future<QueueModel> createQueue({
    required String name,
    required String creatorId,
    required String creatorName,
    String description = '',
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Створюємо документ в Firestore
      final queueRef = _firestore.collection('queues').doc();

      // Генеруємо QR-код
      final qrCode = await _qrService.generateQrCode(queueRef.id);

      // Створюємо модель черги
      final newQueue = QueueModel(
        id: queueRef.id,
        name: name,
        creatorId: creatorId,
        creatorName: creatorName,
        qrCode: qrCode,
        members: [],
        isActive: true,
        createdAt: DateTime.now(),
        description: description,
      );

      // Зберігаємо чергу в Firestore
      await queueRef.set(newQueue.toMap());

      // Оновлюємо локальний стан
      _userQueues.add(newQueue);
      _activeQueue = newQueue;

      _isLoading = false;
      notifyListeners();

      if (queueDoc.exists) {
        final queue = QueueModel.fromMap(queueDoc.data() as Map<String, dynamic>);
        return queue;
      }

      return null;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Приєднання до черги за ідентифікатором
  Future<bool> joinQueue({
    required String queueId,
    required UserModel user,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Отримуємо дані про чергу
      final queueDoc = await _firestore.collection('queues').doc(queueId).get();

      if (!queueDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final queue = QueueModel.fromMap(queueDoc.data() as Map<String, dynamic>);

      // Перевіряємо, чи користувач вже в черзі
      final isAlreadyMember = queue.members.any((member) => member.userId == user.uid);

      if (isAlreadyMember) {
        _isLoading = false;
        notifyListeners();
        return true; // Користувач вже у черзі
      }

      // Визначаємо позицію користувача
      final position = queue.members.length + 1;

      // Створюємо об'єкт учасника черги
      final newMember = QueueMember(
        userId: user.uid,
        name: user.name,
        photoUrl: user.photoUrl,
        avatarType: user.avatarType,
        joinedAt: DateTime.now(),
        position: position,
      );

      // Додаємо користувача до черги
      await _firestore.collection('queues').doc(queueId).update({
        'members': FieldValue.arrayUnion([newMember.toMap()]),
      });

      // Оновлюємо локальний стан
      _joinedQueues.add(queue.copyWith(
        members: [...queue.members, newMember],
      ));

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання всіх активних черг користувача
  Future<void> getUserQueues(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Отримуємо черги, створені користувачем
      final userQueuesSnapshot = await _firestore
          .collection('queues')
          .where('creatorId', isEqualTo: userId)
          .where('isActive', isEqualTo: true)
          .get();

      _userQueues = userQueuesSnapshot.docs
          .map((doc) => QueueModel.fromMap(doc.data()))
          .toList();

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання всіх черг, до яких приєднався користувач
  Future<void> getJoinedQueues(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Отримуємо черги, до яких приєднався користувач
      final joinedQueuesSnapshot = await _firestore
          .collection('queues')
          .where('isActive', isEqualTo: true)
          .get();

      final List<QueueModel> tempJoinedQueues = [];

      for (var doc in joinedQueuesSnapshot.docs) {
        final queue = QueueModel.fromMap(doc.data());

        // Перевіряємо, чи є користувач учасником черги
        final isMember = queue.members.any((member) => member.userId == userId);

        if (isMember) {
          tempJoinedQueues.add(queue);
        }
      }

      _joinedQueues = tempJoinedQueues;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Видалення користувача з черги
  Future<bool> leaveQueue({
    required String queueId,
    required String userId,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Отримуємо дані про чергу
      final queueDoc = await _firestore.collection('queues').doc(queueId).get();

      if (!queueDoc.exists) {
        _isLoading = false;
        notifyListeners();
        return false;
      }

      final queue = QueueModel.fromMap(queueDoc.data() as Map<String, dynamic>);

      // Знаходимо учасника у черзі
      final memberIndex = queue.members.indexWhere((member) => member.userId == userId);

      if (memberIndex == -1) {
        _isLoading = false;
        notifyListeners();
        return false; // Користувач не у черзі
      }

      // Створюємо новий список учасників без користувача
      final updatedMembers = List<QueueMember>.from(queue.members);
      updatedMembers.removeAt(memberIndex);

      // Оновлюємо позиції учасників у черзі
      for (var i = 0; i < updatedMembers.length; i++) {
        if (updatedMembers[i].position > queue.members[memberIndex].position) {
          updatedMembers[i] = QueueMember(
            userId: updatedMembers[i].userId,
            name: updatedMembers[i].name,
            photoUrl: updatedMembers[i].photoUrl,
            avatarType: updatedMembers[i].avatarType,
            joinedAt: updatedMembers[i].joinedAt,
            position: updatedMembers[i].position - 1,
            isActive: updatedMembers[i].isActive,
          );
        }
      }

      // Оновлюємо чергу в Firestore
      await _firestore.collection('queues').doc(queueId).update({
        'members': updatedMembers.map((member) => member.toMap()).toList(),
      });

      // Оновлюємо локальний стан
      _joinedQueues.removeWhere((q) => q.id == queueId);

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Завершення черги
  Future<bool> endQueue(String queueId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Оновлюємо статус черги
      await _firestore.collection('queues').doc(queueId).update({
        'isActive': false,
        'endedAt': DateTime.now(),
      });

      // Оновлюємо локальний стан
      _userQueues.removeWhere((q) => q.id == queueId);
      _joinedQueues.removeWhere((q) => q.id == queueId);

      if (_activeQueue?.id == queueId) {
        _activeQueue = null;
      }

      _isLoading = false;
      notifyListeners();

      return true;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }
}
      notifyListeners();

      return newQueue;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Отримання черги за ідентифікатором
  Future<QueueModel?> getQueueById(String queueId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final queueDoc = await _firestore.collection('queues').doc(queueId).get();

      _isLoading = false;