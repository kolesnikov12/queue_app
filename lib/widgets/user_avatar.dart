import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:queue_app/config/theme.dart';

class UserAvatar extends StatelessWidget {
  final String? photoUrl;
  final String avatarType;
  final double size;
  final VoidCallback? onTap;

  const UserAvatar({
    super.key,
    this.photoUrl,
    required this.avatarType,
    this.size = 48,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Якщо є URL фотографії, відображаємо її
    if (photoUrl != null && photoUrl!.isNotEmpty) {
      return GestureDetector(
        onTap: onTap,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(size / 2),
          child: CachedNetworkImage(
            imageUrl: photoUrl!,
            width: size,
            height: size,
            fit: BoxFit.cover,
            placeholder: (context, url) => _buildPlaceholder(),
            errorWidget: (context, url, error) => _buildFallbackAvatar(),
          ),
        ),
      );
    }

    // Якщо немає фото, відображаємо аватар за типом
    return GestureDetector(
      onTap: onTap,
      child: _buildAvatarByType(),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        shape: BoxShape.circle,
      ),
      child: Center(
        child: SizedBox(
          width: size / 3,
          height: size / 3,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primaryColor),
          ),
        ),
      ),
    );
  }

  Widget _buildFallbackAvatar() {
    return _buildAvatarByType();
  }

  Widget _buildAvatarByType() {
    // Колір аватара залежить від типу
    final Map<String, Color> avatarColors = {
      'default': AppTheme.primaryColor,
      'cool': Colors.blue,
      'fun': Colors.orange,
      'cute': Colors.pink,
      'serious': Colors.purple,
      'mysterious': Colors.indigo,
    };

    // Іконка аватара залежить від типу
    final Map<String, IconData> avatarIcons = {
      'default': Icons.person,
      'cool': Icons.sports_esports,
      'fun': Icons.mood,
      'cute': Icons.pets,
      'serious': Icons.work,
      'mysterious': Icons.psychology,
    };

    final color = avatarColors[avatarType] ?? AppTheme.primaryColor;
    final icon = avatarIcons[avatarType] ?? Icons.person;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        size: size / 2,
        color: Colors.white,
      ),
    );
  }
}