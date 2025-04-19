import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:queue_app/config/theme.dart';
import 'package:queue_app/models/queue_model.dart';
import 'package:queue_app/services/auth_service.dart';
import 'package:queue_app/services/queue_service.dart';
import 'package:queue_app/widgets/user_avatar.dart';

class QueueDetailsScreen extends StatefulWidget {
  const QueueDetailsScreen({super.key});

  @override
  State<QueueDetailsScreen> createState() => _QueueDetailsScreenState();
}

class _QueueDetailsScreenState extends State<QueueDetailsScreen> {
  bool _isLoading = true;
  QueueModel? _queue;
  String? _error;
  bool _isCreator = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadQueueDetails();
  }

  Future<void> _loadQueueDetails() async {
    final queueId = ModalRoute.of(context)?.settings.arguments as String?;

    if (queueId == null) {
      setState(() {
        _error = 'Не вдалося завантажити деталі черги: ID не вказано';
        _isLoading = false;
      });
      return;
    }

    try {
      final queueService = Provider.of<QueueService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final queue = await queueService.getQueueById(queueId);

      if (queue == null) {
        setState(() {
          _error = 'Черга не знайдена';
          _isLoading = false;
        });
        return;
      }

      // Перевіряємо, чи є користувач створювачем черги
      _isCreator = queue.creatorId == authService.user?.uid;

      setState(() {
        _queue = queue;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Помилка завантаження черги: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Деталі черги'),
        ),
        body: Center(
          child: Text(
            _error!,
            style: const TextStyle(color: Colors.red),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Деталі черги'),
        actions: [
          if (_isCreator)
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'end') {
                  _showEndQueueDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem<String>(
                  value: 'end',
                  child: ListTile(
                    leading: Icon(Icons.stop_circle, color: Colors.red),
                    title: Text('Завершити чергу'),
                  ),
                ),
              ],
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadQueueDetails,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildQueueHeader(),
              const SizedBox(height: 24),
              _buildQrCode(),
              const SizedBox(height: 24),
              _buildMembersList(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQueueHeader() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.queue,
                    color: AppTheme.primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _queue!.name,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      Text(
                        'Створено: ${_queue!.creatorName}',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _queue!.isActive
                        ? Colors.green.withOpacity(0.1)
                        : Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _queue!.isActive ? 'Активна' : 'Завершена',
                    style: TextStyle(
                      color: _queue!.isActive ? Colors.green : Colors.red,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (_queue!.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                'Опис:',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Text(_queue!.description),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildInfoItem(
                  icon: Icons.people,
                  title: 'Кількість',
                  value: '${_queue!.members.length}',
                ),
                _buildInfoItem(
                  icon: Icons.calendar_today,
                  title: 'Створено',
                  value: '${_queue!.createdAt.day}.${_queue!.createdAt.month}.${_queue!.createdAt.year}',
                ),
                _buildInfoItem(
                  icon: Icons.access_time,
                  title: 'Час',
                  value: '${_queue!.createdAt.hour}:${_queue!.createdAt.minute.toString().padLeft(2, '0')}',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.primaryColor,
          size: 20,
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: const TextStyle(
            fontSize: 12,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildQrCode() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'QR-код для приєднання',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            const Text(
              'Покажіть цей код для приєднання до черги',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: QrImageView(
                data: _queue!.qrCode,
                version: QrVersions.auto,
                size: 200,
                backgroundColor: Colors.white,
                errorStateBuilder: (context, error) {
                  return const Center(
                    child: Text(
                      'Помилка генерації QR-коду',
                      style: TextStyle(color: Colors.red),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Clipboard.setData(ClipboardData(text: _queue!.qrCode)).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('QR-код скопійовано в буфер обміну'),
                    ),
                  );
                });
              },
              icon: const Icon(Icons.copy),
              label: const Text('Копіювати код'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.secondaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMembersList() {
    final authService = Provider.of<AuthService>(context);
    final currentUserId = authService.user?.uid;
    final members = List<QueueMember>.from(_queue!.members);

    // Сортуємо за позицією
    members.sort((a, b) => a.position.compareTo(b.position));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Учасники черги',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 16),
        if (members.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text('У черзі ще немає учасників'),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: members.length,
            itemBuilder: (context, index) {
              final member = members[index];
              final isCurrentUser = member.userId == currentUserId;

              return Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.only(bottom: 8),
                color: isCurrentUser
                    ? AppTheme.primaryColor.withOpacity(0.1)
                    : null,
                child: ListTile(
                  leading: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        member.position.toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(member.name),
                      if (isCurrentUser)
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0),
                          child: Text(
                            '(Ви)',
                            style: TextStyle(
                              fontStyle: FontStyle.italic,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: Text(
                    'Приєднався: ${member.joinedAt.hour}:${member.joinedAt.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      UserAvatar(
                        photoUrl: member.photoUrl,
                        avatarType: member.avatarType,
                        size: 36,
                      ),
                      if (isCurrentUser && !_isCreator) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.exit_to_app, color: Colors.red),
                          onPressed: () => _showLeaveQueueDialog(),
                          tooltip: 'Вийти з черги',
                        ),
                      ],
                      if (_isCreator && !isCurrentUser) ...[
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.remove_circle_outline, color: Colors.red),
                          onPressed: () => _showRemoveMemberDialog(member),
                          tooltip: 'Видалити з черги',
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  void _showEndQueueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Завершити чергу'),
        content: const Text('Ви впевнені, що хочете завершити цю чергу? Ця дія не може бути скасована.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _endQueue();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Завершити'),
          ),
        ],
      ),
    );
  }

  void _showLeaveQueueDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Вийти з черги'),
        content: const Text('Ви впевнені, що хочете вийти з цієї черги?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _leaveQueue();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Вийти'),
          ),
        ],
      ),
    );
  }

  void _showRemoveMemberDialog(QueueMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Видалити учасника'),
        content: Text('Ви впевнені, що хочете видалити ${member.name} з черги?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text('Скасувати'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _removeMember(member);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
            ),
            child: const Text('Видалити'),
          ),
        ],
      ),
    );
  }

  Future<void> _endQueue() async {
    if (_queue == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final queueService = Provider.of<QueueService>(context, listen: false);
      final result = await queueService.endQueue(_queue!.id);

      if (result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Черга успішно завершена'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Не вдалося завершити чергу';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Помилка завершення черги: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _leaveQueue() async {
    if (_queue == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final queueService = Provider.of<QueueService>(context, listen: false);
      final authService = Provider.of<AuthService>(context, listen: false);

      final result = await queueService.leaveQueue(
        queueId: _queue!.id,
        userId: authService.user!.uid,
      );

      if (result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ви успішно вийшли з черги'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pop(context);
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Не вдалося вийти з черги';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Помилка виходу з черги: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _removeMember(QueueMember member) async {
    if (_queue == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final queueService = Provider.of<QueueService>(context, listen: false);

      final result = await queueService.leaveQueue(
        queueId: _queue!.id,
        userId: member.userId,
      );

      if (result) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${member.name} видалений з черги'),
              backgroundColor: Colors.green,
            ),
          );

          _loadQueueDetails();
        }
      } else {
        if (mounted) {
          setState(() {
            _error = 'Не вдалося видалити учасника';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Помилка видалення учасника: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }
}