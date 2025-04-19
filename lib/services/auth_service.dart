import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _user;
  UserModel? _userModel;
  bool _isLoading = false;

  AuthService() {
    // Прослуховування змін стану авторизації
    _auth.authStateChanges().listen((User? user) {
      _user = user;
      // Якщо користувач авторизований, отримуємо його дані з Firestore
      if (user != null) {
        _fetchUserData();
      } else {
        _userModel = null;
      }
      notifyListeners();
    });
  }

  User? get user => _user;
  UserModel? get userModel => _userModel;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  // Авторизація через Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      _isLoading = true;
      notifyListeners();

      // Починаємо процес авторизації Google
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return null;
      }

      // Отримуємо дані авторизації
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Створюємо обліковий запис Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Авторизуємося в Firebase
      final userCredential = await _auth.signInWithCredential(credential);

      // Перевіряємо, чи користувач вже існує в Firestore
      await _checkUserExists(userCredential.user!);

      _isLoading = false;
      notifyListeners();

      return userCredential;
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Вихід з облікового запису
  Future<void> signOut() async {
    try {
      _isLoading = true;
      notifyListeners();

      await _googleSignIn.signOut();
      await _auth.signOut();

      _userModel = null;
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Перевіряємо, чи користувач вже існує в Firestore
  Future<void> _checkUserExists(User user) async {
    try {
      // Перевіряємо, чи існує документ користувача
      final userDoc = await _firestore.collection('users').doc(user.uid).get();

      if (!userDoc.exists) {
        // Якщо користувача не існує, створюємо новий запис
        final newUser = UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          photoUrl: user.photoURL,
          avatarType: 'default',
          currentSkin: 'default',
          createdAt: DateTime.now(),
          lastLogin: DateTime.now(),
        );

        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
        _userModel = newUser;
      } else {
        // Оновлюємо дату останнього входу
        await _firestore.collection('users').doc(user.uid).update({
          'lastLogin': DateTime.now(),
        });

        // Отримуємо дані користувача
        await _fetchUserData();
      }
    } catch (e) {
      rethrow;
    }
  }

  // Отримуємо дані користувача з Firestore
  Future<void> _fetchUserData() async {
    try {
      if (_user != null) {
        final userDoc = await _firestore.collection('users').doc(_user!.uid).get();

        if (userDoc.exists) {
          _userModel = UserModel.fromMap(userDoc.data() as Map<String, dynamic>);
          notifyListeners();
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  // Оновлення даних користувача
  Future<void> updateUserData({
    String? name,
    String? avatarType,
    String? currentSkin,
  }) async {
    try {
      if (_user == null || _userModel == null) return;

      _isLoading = true;
      notifyListeners();

      final Map<String, dynamic> updateData = {};

      if (name != null) updateData['name'] = name;
      if (avatarType != null) updateData['avatarType'] = avatarType;
      if (currentSkin != null) updateData['currentSkin'] = currentSkin;

      await _firestore.collection('users').doc(_user!.uid).update(updateData);

      // Оновлюємо локальну модель користувача
      _userModel = _userModel!.copyWith(
        name: name ?? _userModel!.name,
        avatarType: avatarType ?? _userModel!.avatarType,
        currentSkin: currentSkin ?? _userModel!.currentSkin,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      rethrow;
    }
  }

  // Оновлення статистики користувача
  Future<void> updateUserStats({
    bool won = false,
  }) async {
    try {
      if (_user == null || _userModel == null) return;

      final Map<String, dynamic> updateData = {
        'gamesPlayed': FieldValue.increment(1),
      };

      if (won) {
        updateData['gamesWon'] = FieldValue.increment(1);
        updateData['points'] = FieldValue.increment(10); // Додаємо очки за перемогу
      }

      await _firestore.collection('users').doc(_user!.uid).update(updateData);

      // Оновлюємо локальну модель користувача
      _userModel = _userModel!.copyWith(
        gamesPlayed: _userModel!.gamesPlayed + 1,
        gamesWon: won ? _userModel!.gamesWon + 1 : _userModel!.gamesWon,
        points: won ? _userModel!.points + 10 : _userModel!.points,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Додавання досягнення
  Future<void> addAchievement(String achievement) async {
    try {
      if (_user == null || _userModel == null) return;

      // Перевіряємо, чи досягнення вже є у користувача
      if (_userModel!.achievements.contains(achievement)) return;

      await _firestore.collection('users').doc(_user!.uid).update({
        'achievements': FieldValue.arrayUnion([achievement]),
        'points': FieldValue.increment(5), // Додаємо очки за досягнення
      });

      // Оновлюємо локальну модель користувача
      final updatedAchievements = List<String>.from(_userModel!.achievements)..add(achievement);

      _userModel = _userModel!.copyWith(
        achievements: updatedAchievements,
        points: _userModel!.points + 5,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Купівля скіну
  Future<void> purchaseSkin(String skinId) async {
    try {
      if (_user == null || _userModel == null) return;

      // Перевіряємо, чи скін вже є у користувача
      if (_userModel!.purchasedSkins.contains(skinId)) return;

      await _firestore.collection('users').doc(_user!.uid).update({
        'purchasedSkins': FieldValue.arrayUnion([skinId]),
      });

      // Оновлюємо локальну модель користувача
      final updatedSkins = List<String>.from(_userModel!.purchasedSkins)..add(skinId);

      _userModel = _userModel!.copyWith(
        purchasedSkins: updatedSkins,
      );

      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}