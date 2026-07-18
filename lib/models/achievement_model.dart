import 'package:flutter/material.dart';

class Achievement {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final Color color;
  bool unlocked;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
    this.unlocked = false,
  });

  static List<Achievement> get all => [
        Achievement(
          id: 'first_topic',
          title: 'Pemula',
          description: 'Selesaikan 1 topik pertama',
          icon: Icons.play_circle_rounded,
          color: Color(0xFF4FC3F7),
        ),
        Achievement(
          id: 'ten_topics',
          title: 'Rajin',
          description: 'Selesaikan 10 topik',
          icon: Icons.trending_up_rounded,
          color: Color(0xFF81C784),
        ),
        Achievement(
          id: 'collector',
          title: 'Kolektor',
          description: 'Selesaikan semua topik dalam 1 kelas',
          icon: Icons.collections_bookmark_rounded,
          color: Color(0xFFFFB74D),
        ),
        Achievement(
          id: 'perfect_five',
          title: 'Sempurna',
          description: 'Dapat nilai 100 di 5 topik',
          icon: Icons.auto_awesome_rounded,
          color: Color(0xFFE57373),
        ),
        Achievement(
          id: 'all_stars',
          title: 'Juara',
          description: 'Dapat 3 bintang di semua topik 1 kelas',
          icon: Icons.emoji_events_rounded,
          color: Color(0xFFFFD700),
        ),
        Achievement(
          id: 'fifty_stars',
          title: 'Bintang',
          description: 'Kumpulkan total 50 bintang',
          icon: Icons.stars_rounded,
          color: Color(0xFFBA68C8),
        ),
        Achievement(
          id: 'explorer',
          title: 'Petualang',
          description: 'Buka semua kelas (1-6)',
          icon: Icons.explore_rounded,
          color: Color(0xFF4DD0E1),
        ),
        Achievement(
          id: 'twenty_five',
          title: 'Fast Learner',
          description: 'Selesaikan 25 topik',
          icon: Icons.rocket_launch_rounded,
          color: Color(0xFFFF6584),
        ),
      ];
}
