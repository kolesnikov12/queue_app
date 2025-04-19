import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:queue_app/config/routes.dart';
import 'package:queue_app/config/theme.dart';
import 'package:queue_app/services/auth_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context);
    final user = authService.userModel;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Queue App'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, AppRoutes.profile);
            },
          ),
        ],
      ),
      body: _buildBody(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Головна',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.queue),
            label: 'Черги',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.emoji_events),
            label: 'Чемпіонати',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.leaderboard),
            label: 'Рейтинг',
          ),
        ],
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildBody() {
    switch (_currentIndex) {
      case 0:
        return _buildHomeTab();
      case 1:
        return _buildQueuesTab();
      case 2:
        return _buildChampionshipsTab();
      case 3:
        return _buildLeaderboardTab();
      default:
        return _buildHomeTab();
    }
  }

  Widget _buildHomeTab() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Вітаємо у Queue App!',
            style: Theme.of(context).textTheme.displayMedium,
          ),
          const SizedBox(height: 16),
          Text(
            'Створюйте черги та чемпіонати або приєднуйтесь до існуючих за допомогою QR-кодів.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          _buildActionCard(
            title: 'Створити чергу',
            icon: Icons.add_circle,
            color: AppTheme.primaryColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.createQueue);
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: 'Приєднатися до черги',
            icon: Icons.qr_code_scanner,
            color: AppTheme.secondaryColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.scanQr);
            },
          ),
          const SizedBox(height: 16),
          _buildActionCard(
            title: 'Створити чемпіонат',
            icon: Icons.emoji_events_outlined,
            color: AppTheme.accentColor,
            onTap: () {
              Navigator.pushNamed(context, AppRoutes.createChampionship);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildQueuesTab() {
    return const Center(
      child: Text('Список черг'),
    );
  }

  Widget _buildChampionshipsTab() {
    return const Center(
      child: Text('Список чемпіонатів'),
    );
  }

  Widget _buildLeaderboardTab() {
    return const Center(
      child: Text('Рейтинг користувачів'),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const Spacer(),
              Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey[400],
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_currentIndex) {
      case 1:
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createQueue);
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
        );
      case 2:
        return FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.createChampionship);
          },
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
        );
      default:
        return null;
    }
  }
}