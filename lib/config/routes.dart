import 'package:flutter/material.dart';
import 'package:queue_app/screens/auth/login_screen.dart';
import 'package:queue_app/screens/auth/profile_screen.dart';
import 'package:queue_app/screens/auth/avatar_selection.dart';
import 'package:queue_app/screens/home_screen.dart';
import 'package:queue_app/screens/queue/create_queue.dart';
import 'package:queue_app/screens/queue/join_queue.dart';
import 'package:queue_app/screens/queue/queue_details.dart';
import 'package:queue_app/screens/queue/scan_qr.dart';
import 'package:queue_app/screens/championship/create_championship.dart';
import 'package:queue_app/screens/championship/team_management.dart';
import 'package:queue_app/screens/championship/championship_details.dart';
import 'package:queue_app/screens/stats/achievements.dart';
import 'package:queue_app/screens/stats/leaderboard.dart';
import 'package:queue_app/screens/shop/skins_shop.dart';

class AppRoutes {
  // Імена маршрутів
  static const String home = '/home';
  static const String login = '/login';
  static const String profile = '/profile';
  static const String avatarSelection = '/avatar-selection';
  static const String createQueue = '/create-queue';
  static const String joinQueue = '/join-queue';
  static const String queueDetails = '/queue-details';
  static const String scanQr = '/scan-qr';
  static const String createChampionship = '/create-championship';
  static const String teamManagement = '/team-management';
  static const String championshipDetails = '/championship-details';
  static const String achievements = '/achievements';
  static const String leaderboard = '/leaderboard';
  static const String skinsShop = '/skins-shop';

  // Карта маршрутів
  static final Map<String, WidgetBuilder> routes = {
    home: (context) => const HomeScreen(),
    login: (context) => const LoginScreen(),
    profile: (context) => const ProfileScreen(),
    avatarSelection: (context) => const AvatarSelectionScreen(),
    createQueue: (context) => const CreateQueueScreen(),
    joinQueue: (context) => const JoinQueueScreen(),
    queueDetails: (context) => const QueueDetailsScreen(),
    scanQr: (context) => const ScanQrScreen(),
    createChampionship: (context) => const CreateChampionshipScreen(),
    teamManagement: (context) => const TeamManagementScreen(),
    championshipDetails: (context) => const ChampionshipDetailsScreen(),
    achievements: (context) => const AchievementsScreen(),
    leaderboard: (context) => const LeaderboardScreen(),
    skinsShop: (context) => const SkinsShopScreen(),
  };
}