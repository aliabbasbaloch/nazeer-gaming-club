import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/history_action.dart';
import '../../providers/history_provider.dart';
import '../../providers/settings_provider.dart';

// ---------------------------------------------------------------------------

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  void _confirmClear(BuildContext context) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Clear History'),
        content:
            const Text('This will permanently delete all history. Continue?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(historyProvider.notifier).clearHistory();
            },
            child: Text('Clear', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);
    final colors = ref.watch(appColorsProvider);

    // getAllHistory() already returns entries sorted newest-first by timestamp.
    final scoreEntries = history
        .where((a) =>
            a.actionType == ActionType.score ||
            a.actionType == ActionType.subtract)
        .toList();

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.navbar,
        centerTitle: true,
        title: Text(
          'History',
          style:
              TextStyle(fontWeight: FontWeight.bold, color: colors.textPrimary),
        ),
        actions: [
          if (scoreEntries.isNotEmpty)
            IconButton(
              onPressed: () => _confirmClear(context),
              icon: Icon(Icons.delete, color: colors.danger, size: 22),
            ),
        ],
      ),
      body: SafeArea(
        child: scoreEntries.isEmpty
            ? const _EmptyState()
            : ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                itemCount: scoreEntries.length,
                itemBuilder: (context, index) => _HistoryRow(
                  action: scoreEntries[index],
                ),
              ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Empty state
// ---------------------------------------------------------------------------

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.access_time,
              size: 64, color: colors.textSecondary.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            'No History Yet',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: colors.textSecondary),
          ),
          const SizedBox(height: 6),
          Text(
            'Score actions will appear here',
            style: TextStyle(
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: colors.textSecondary),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// History row – mirrors the game.html history panel entry exactly:
//
//  ┌──── ball-colour border │ emoji  player name (bold)         ┌──────┐ │
//  │                        │        ball  •  HH:MM             │  +X  │ │
//  └────────────────────────┴──────────────────────────────────-└──────┘ ┘
// ---------------------------------------------------------------------------

class _HistoryRow extends StatelessWidget {
  final HistoryAction action;

  const _HistoryRow({required this.action});

  // Ball name → left-border colour (AppColors palette)
  static Color _borderColor(String? ballName, bool isSubtract, AppColors colors) {
    if (isSubtract) return colors.danger;
    switch ((ballName ?? '').toLowerCase()) {
      case 'yellow':
        return AppColors.ballYellow;
      case 'green':
        return AppColors.ballGreen;
      case 'brown':
        return AppColors.ballBrown;
      case 'blue':
        return AppColors.ballBlue;
      case 'pink':
        return AppColors.ballPink;
      case 'black':
        return AppColors.ballBlack;
      case 'red':
        return AppColors.ballRed;
      default:
        return colors.success;
    }
  }

  // Ball name → emoji (matches game.html)
  static String _ballEmoji(String? ballName) {
    switch ((ballName ?? '').toLowerCase()) {
      case 'yellow':
        return '\uD83D\uDFE1'; // 🟡
      case 'green':
        return '\uD83D\uDFE2'; // 🟢
      case 'brown':
        return '\uD83D\uDFE4'; // 🟤
      case 'blue':
        return '\uD83D\uDD35'; // 🔵
      case 'pink':
        return '\uD83C\uDF38'; // 🌸
      case 'black':
        return '\u26AB'; // ⚫
      case 'red':
        return '\uD83D\uDD34'; // 🔴
      default:
        return '\uD83C\uDFB1'; // 🎱
    }
  }

  String _formatTime(DateTime ts) {
    final h = ts.hour.toString().padLeft(2, '0');
    final m = ts.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final isSubtract = action.actionType == ActionType.subtract;
    final points = action.pointsChanged ?? 0;
    final badgeColor = isSubtract ? colors.danger : colors.success;
    final border = _borderColor(action.ballColor, isSubtract, colors);
    final emoji = _ballEmoji(action.ballColor);
    final badge = isSubtract ? '\u2212$points' : '+$points';
    final playerName = action.playerName ?? 'Unknown';
    final ballLabel =
        action.ballColor != null ? _cap(action.ballColor!) : '';

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: border, width: 4)),
        boxShadow: colors.cardShadow,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            // Left: emoji
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 10),

            // Middle: player name on top, ball + time below (game.html layout)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    playerName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    ballLabel.isEmpty
                        ? _formatTime(action.timestamp)
                        : '$ballLabel  \u2022  ${_formatTime(action.timestamp)}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Right: +X / −X badge
            Container(
              constraints: const BoxConstraints(minWidth: 54),
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                    color: badgeColor.withValues(alpha: 0.40), width: 1),
              ),
              alignment: Alignment.center,
              child: Text(
                badge,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                  color: badgeColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _cap(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}
