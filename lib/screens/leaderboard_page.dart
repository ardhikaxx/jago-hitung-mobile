import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/user_progress_model.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';

class LeaderboardPage extends StatefulWidget {
  final UserProgress? currentProgress;

  const LeaderboardPage({super.key, required this.currentProgress});

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  List<UserProgress> _leaderboard = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchLeaderboard();
  }

  Future<void> _fetchLeaderboard() async {
    setState(() => _isLoading = true);
    final users = await FirestoreService.instance.getLeaderboard();

    if (mounted) {
      setState(() {
        _leaderboard = users;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 600),
        child: CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
            child: Column(
              children: [
                Stack(
                  children: [
                    Text(
                      'PERINGKAT',
                      style: GoogleFonts.fredoka(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        foreground: Paint()
                          ..style = PaintingStyle.stroke
                          ..strokeWidth = 10
                          ..color = const Color(0xFFFFB300), // Yellow
                      ),
                    ),
                    Text(
                      'PERINGKAT',
                      style: GoogleFonts.fredoka(
                        fontSize: 44,
                        fontWeight: FontWeight.w900,
                        color: Colors.white, // White fill
                        shadows: const [Shadow(color: Colors.black45, blurRadius: 8, offset: Offset(0, 4))],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1.5),
                  ),
                  child: const Text(
                    'Raih skor tertinggi dan jadilah juara!',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        if (_isLoading)
          const SliverFillRemaining(
            child: Center(child: CircularProgressIndicator(color: Colors.white)),
          )
        else if (_leaderboard.isEmpty)
          const SliverFillRemaining(
            child: Center(
              child: Text(
                'Belum ada data.',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          )
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 120),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = _leaderboard[index];
                  final isMe = user.uid == widget.currentProgress?.uid;
                  return _buildLeaderboardItem(user, index + 1, isMe);
                },
                childCount: _leaderboard.length,
              ),
            ),
          ),
      ],
    )));
  }

  Widget _buildLeaderboardItem(UserProgress user, int rank, bool isMe) {
    Color cardColor = Colors.white;
    Color borderColor = Colors.grey.shade400;
    Widget rankIcon;

    if (rank == 1) {
      borderColor = const Color(0xFFFFD700); // Gold
      rankIcon = const Icon(Icons.workspace_premium_rounded, color: Color(0xFFFFD700), size: 28);
    } else if (rank == 2) {
      borderColor = const Color(0xFFC0C0C0); // Silver
      rankIcon = const Icon(Icons.workspace_premium_rounded, color: Color(0xFFC0C0C0), size: 28);
    } else if (rank == 3) {
      borderColor = const Color(0xFFCD7F32); // Bronze
      rankIcon = const Icon(Icons.workspace_premium_rounded, color: Color(0xFFCD7F32), size: 28);
    } else {
      rankIcon = Container(
        width: 28,
        height: 28,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: borderColor,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$rank',
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 13),
        ),
      );
    }

    final displayName = user.nama.isNotEmpty ? user.nama : 'Pemain';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 3),
        boxShadow: [
          BoxShadow(
            color: borderColor,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          rankIcon,
          const SizedBox(width: 12),
          CircleAvatar(
            radius: 20,
            backgroundColor: AppColors.primary,
            backgroundImage: user.profileImage.isNotEmpty ? AssetImage(user.profileImage) : null,
            child: user.profileImage.isEmpty
                ? Text(
                    displayName[0].toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: isMe ? FontWeight.w900 : FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Text(
                      'Kelas ${user.kelasAktif}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (isMe) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'KAMU',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFFFB300).withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB300), width: 1.5),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.star_rounded, color: Color(0xFFFFB300), size: 16),
                const SizedBox(width: 4),
                Text(
                  '${user.totalXP}',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD69400),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
