import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../data/models/game.dart';
import '../../../data/models/player.dart';
import '../../../data/models/snooker_ball.dart';
import '../../providers/game_provider.dart';
import '../../providers/game_timer_provider.dart';
import '../../providers/settings_provider.dart';
import '../transfer/share_qr_screen.dart';
import '../transfer/scan_qr_screen.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _nameController = TextEditingController();
  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
  final List<Player> _cachedPlayers = [];

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _syncList(List<Player> newPlayers) {
    // handle insertions
    for (var i = 0; i < newPlayers.length; i++) {
      if (i >= _cachedPlayers.length ||
          _cachedPlayers[i].id != newPlayers[i].id) {
        _cachedPlayers.insert(i, newPlayers[i]);
        _listKey.currentState?.insertItem(i,
            duration: const Duration(milliseconds: 300));
        return;
      }
    }
    // handle removals
    while (_cachedPlayers.length > newPlayers.length) {
      final idx = newPlayers.length;
      final removed = _cachedPlayers.removeAt(idx);
      _listKey.currentState?.removeItem(
        idx,
        (_, animation) => _PlayerListItem(
          player: removed,
          isActive: false,
          targetScore: 150,
          animation: animation,
          onTap: () {},
          onRemove: () {},
        ),
        duration: const Duration(milliseconds: 300),
      );
    }
    // sync values in-place
    for (var i = 0; i < newPlayers.length && i < _cachedPlayers.length; i++) {
      _cachedPlayers[i] = newPlayers[i];
    }
  }

  Future<void> _addPlayer(Game? game) async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    _nameController.clear();
    if (game == null) {
      await ref.read(gameProvider.notifier).createNewGame(
            targetScore:
                ref.read(settingsProvider).defaultTargetScore,
          );
    }
    await ref.read(gameProvider.notifier).addPlayer(name);
  }

  void _showNewGameDialog() {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.bgCard,
        title: Text('New Game', style: TextStyle(color: colors.textPrimary)),
        content: Text('This will end the current game. Continue?', style: TextStyle(color: colors.textSecondary)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).createNewGame();
            },
            child: Text('Start New', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
  }

  void _showRemoveDialog(String id, String name) {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: colors.bgCard,
        title: Text('Remove Player', style: TextStyle(color: colors.textPrimary)),
        content: Text('Remove $name from the game?', style: TextStyle(color: colors.textSecondary)),
        actions: [
          TextButton(
            child: Text('Cancel', style: TextStyle(color: colors.textMuted)),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(gameProvider.notifier).removePlayer(id);
            },
            child: Text('Remove', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
  }

  bool _listsEqual(List<Player> a, List<Player> b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id ||
          a[i].score != b[i].score ||
          a[i].isCompleted != b[i].isCompleted) {
        return false;
      }
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    final game = ref.watch(gameProvider);
    final colors = ref.watch(appColorsProvider);

    // Sync animated list
    if (game != null) {
      final newPlayers = game.players;
      if (!_listsEqual(newPlayers, _cachedPlayers)) {
        WidgetsBinding.instance.addPostFrameCallback(
            (_) { if (mounted) _syncList(List<Player>.from(newPlayers)); });
      }
    }

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.navbar,
        centerTitle: true,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '🎱 Nazeer Gaming Club',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
                color: colors.textPrimary,
              ),
            ),
            Text(
              'by Ali Abbas',
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: colors.textMuted,
              ),
            ),
          ],
        ),
        actions: [
          if (game != null)
            IconButton(
              icon: Icon(Icons.qr_code, color: colors.accent),
              tooltip: 'Transfer Game',
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => ShareQrScreen(game: game)),
              ),
            ),
          IconButton(
            icon: Icon(Icons.qr_code_scanner,
                color: colors.textMuted),
            tooltip: 'Receive Game',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ScanQrScreen()),
            ),
          ),
          IconButton(
            onPressed: _showNewGameDialog,
            icon: Icon(Icons.refresh, color: colors.danger, size: 22),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _AddPlayerRow(
                controller: _nameController,
                canAdd: (game?.players.length ?? 0) < AppConstants.maxPlayers,
                onAdd: () => _addPlayer(game),
              ),
              const SizedBox(height: 20),
              const _SectionHeader(label: 'Players'),
              const SizedBox(height: 8),
              if (game != null && game.players.isNotEmpty) ...[
                AnimatedList(
                  key: _listKey,
                  initialItemCount: game.players.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index, animation) {
                    if (index >= game.players.length) {
                      return const SizedBox.shrink();
                    }
                    final player = game.players[index];
                    return _PlayerListItem(
                      player: player,
                      isActive: player.id == game.currentPlayerId,
                      targetScore: game.targetScore,
                      animation: animation,
                      rank: index + 1,
                      onTap: () {
                        if (!player.isCompleted) {
                          ref
                              .read(gameProvider.notifier)
                              .setCurrentPlayer(player.id);
                        }
                      },
                      onRemove: () =>
                          _showRemoveDialog(player.id, player.name),
                    );
                  },
                ),
              ] else ...[
                const _EmptyPlayersHint(),
              ],
              const SizedBox(height: 20),
              const _SectionHeader(label: 'Current Turn'),
              const SizedBox(height: 8),
              _CurrentPlayerCard(game: game),
              const _GameTimerChip(),
              if (game != null) ...[
                const SizedBox(height: 20),
                const _SectionHeader(label: 'Score'),
                const SizedBox(height: 8),
                _BallGrid(game: game, ref: ref),
                const SizedBox(height: 16),
                _SubtractToggle(game: game),
                const SizedBox(height: 12),
                _ActionButtons(game: game),
                const SizedBox(height: 8),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String label;
  const _SectionHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Container(
          width: 3,
          height: 14,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label.toUpperCase(),
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
            color: colors.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add Player Row
// ─────────────────────────────────────────────────────────────────────────────

class _AddPlayerRow extends StatefulWidget {
  final TextEditingController controller;
  final bool canAdd;
  final VoidCallback onAdd;

  const _AddPlayerRow({
    required this.controller,
    required this.canAdd,
    required this.onAdd,
  });

  @override
  State<_AddPlayerRow> createState() => _AddPlayerRowState();
}

class _AddPlayerRowState extends State<_AddPlayerRow> {
  double _btnScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller,
            decoration: InputDecoration(
              hintText: 'Enter player name...',
              hintStyle: TextStyle(color: colors.textMuted, fontSize: 15),
              filled: true,
              fillColor: colors.bgCard,
              prefixIcon: Icon(Icons.person_add, color: colors.textMuted, size: 20),
              suffixIcon: ValueListenableBuilder<TextEditingValue>(
                valueListenable: widget.controller,
                builder: (_, val, _) => val.text.isEmpty
                    ? const SizedBox.shrink()
                    : IconButton(
                        onPressed: () => widget.controller.clear(),
                        icon: Icon(Icons.close, size: 18, color: colors.textMuted),
                      ),
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(color: AppColors.primary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            ),
            style: TextStyle(color: colors.textPrimary),
            onSubmitted: (_) => widget.onAdd(),
            enabled: widget.canAdd,
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTapDown: (_) => setState(() => _btnScale = 0.92),
          onTapUp: (_) {
            setState(() => _btnScale = 1.0);
            if (widget.canAdd) widget.onAdd();
          },
          onTapCancel: () => setState(() => _btnScale = 1.0),
          child: AnimatedScale(
            scale: _btnScale,
            duration: const Duration(milliseconds: 120),
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: widget.canAdd ? AppColors.primaryGradient : null,
                color: widget.canAdd ? null : colors.textDisabled,
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 22),
            ),
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Player List Item (animated slide+fade)
// ─────────────────────────────────────────────────────────────────────────────

class _PlayerListItem extends StatelessWidget {
  final Player player;
  final bool isActive;
  final int targetScore;
  final Animation<double> animation;
  final int rank;
  final VoidCallback onTap;
  final VoidCallback onRemove;

  const _PlayerListItem({
    required this.player,
    required this.isActive,
    required this.targetScore,
    required this.animation,
    this.rank = 1,
    required this.onTap,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final accentColor = player.isCompleted
        ? AppColors.warning
        : isActive
            ? AppColors.primary
            : colors.border;

    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut)),
      child: FadeTransition(
        opacity: animation,
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isActive ? AppColors.primary : colors.border,
                width: isActive ? 1.5 : 1,
              ),
              boxShadow: isActive
                  ? colors.activeCardShadow(AppColors.primary)
                  : colors.cardShadow,
            ),
            child: IntrinsicHeight(
              child: Row(
                children: [
                  // Left accent bar
                  Container(
                    width: 4,
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(14),
                        bottomLeft: Radius.circular(14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 12),
                    child: Row(
                      children: [
                        Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: colors.bgElevated,
                            shape: BoxShape.circle,
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$rank',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: colors.textSecondary,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          player.name,
                          style: TextStyle(
                            fontSize: isActive ? 16 : 15,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: player.isCompleted
                        ? const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.star,
                                  color: AppColors.warning, size: 20),
                              SizedBox(width: 4),
                            ],
                          )
                        : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Text(
                      '${player.score}',
                      style: TextStyle(
                        fontSize: player.isCompleted
                            ? 16
                            : isActive
                                ? 28
                                : 18,
                        fontWeight: player.isCompleted || isActive
                            ? FontWeight.w700
                            : FontWeight.w500,
                        color: player.isCompleted
                            ? AppColors.warning
                            : isActive
                                ? AppColors.primary
                                : colors.textSecondary,
                      ),
                    ),
                  ),
                  if (!isActive && !player.isCompleted)
                    GestureDetector(
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: Icon(Icons.remove_circle_outline,
                            color: colors.danger, size: 20),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty players hint
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyPlayersHint extends StatelessWidget {
  const _EmptyPlayersHint();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: Icon(
              Icons.group,
              size: 28,
              color: AppColors.primary.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'No Players Yet',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Type a name above and tap + to add players',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: colors.textSecondary,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Current Player Card
// ─────────────────────────────────────────────────────────────────────────────

class _CurrentPlayerCard extends StatefulWidget {
  final Game? game;
  const _CurrentPlayerCard({required this.game});

  @override
  State<_CurrentPlayerCard> createState() => _CurrentPlayerCardState();
}

class _CurrentPlayerCardState extends State<_CurrentPlayerCard> {
  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final game = widget.game;
    final player = game?.currentPlayer;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: colors.cardGradient,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.5),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
          ),
        ],
      ),
      child: player == null
          ? Column(
              children: [
                Icon(Icons.grid_view,
                    size: 40, color: colors.textSecondary),
                const SizedBox(height: 8),
                Text(
                  'Tap a player to start',
                  style: TextStyle(
                    fontSize: 15,
                    color: colors.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: colors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: colors.accent.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    'NOW PLAYING',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 2,
                      color: colors.accent,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  player.name,
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: colors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '${player.score}',
                  style: TextStyle(
                    fontSize: 64,
                    fontWeight: FontWeight.w900,
                    color: colors.isDark ? Colors.white : AppColors.primary,
                    height: 1.0,
                    shadows: colors.isDark
                        ? [Shadow(color: AppColors.primary, blurRadius: 20)]
                        : null,
                  ),
                ),
                if (game != null)
                  Builder(builder: (_) {
                    final remaining = game.targetScore - player.score;
                    final show = remaining > 0 &&
                        remaining <=
                            (game.targetScore *
                                AppConstants.warningThreshold);
                    if (!show) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColors.warning.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: AppColors.warning, width: 1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.warning_amber,
                                color: AppColors.warning, size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '$remaining pts to go',
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: AppColors.warning,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ball Grid (3 balls per row, responsive sizing)
// ─────────────────────────────────────────────────────────────────────────────

class _BallGrid extends StatelessWidget {
  final Game game;
  final WidgetRef ref;

  const _BallGrid(
      {required this.game, required this.ref});

  // All 7 balls grouped: row of 4, row of 3
  static const _row1 = [
    SnookerBall.yellow,
    SnookerBall.green,
    SnookerBall.brown,
    SnookerBall.blue,
  ];
  static const _row2 = [
    SnookerBall.pink,
    SnookerBall.black,
    SnookerBall.red,
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      // 4 balls per row. Gap between balls is 12 (3 gaps for 4 balls).
      // Usable per ball = (width - 3*12) / 4.
      const gap = 12.0;
      final ballSize =
          ((constraints.maxWidth - gap * 3) / 4).clamp(60.0, 90.0);

      Widget buildRow(List<SnookerBall> balls, {bool centered = false}) {
        final buttons = balls
            .map((b) => SizedBox(
                  width: ballSize,
                  child: _BallButton(
                    ball: b,
                    size: ballSize,
                    isSubtract: game.isSubtractMode,
                    onTap: () {
                      if (game.currentPlayer != null) {
                        ref.read(gameProvider.notifier).scorePoints(b);
                      }
                    },
                  ),
                ))
            .toList();

        return Row(
          mainAxisAlignment:
              centered ? MainAxisAlignment.center : MainAxisAlignment.spaceBetween,
          children: [
            for (int i = 0; i < buttons.length; i++) ...[
              buttons[i],
              if (i < buttons.length - 1) const SizedBox(width: gap),
            ]
          ],
        );
      }

      return Column(
        children: [
          buildRow(_row1),
          const SizedBox(height: 12),
          buildRow(_row2, centered: true),
        ],
      );
    });
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Ball Button (3D sphere with highlight)
// ─────────────────────────────────────────────────────────────────────────────

// ─────────────────────────────────────────────────────────────────────────────
// Game Timer Chip
// ─────────────────────────────────────────────────────────────────────────────

class _GameTimerChip extends ConsumerWidget {
  const _GameTimerChip();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final elapsed = ref.watch(gameTimerProvider);
    if (elapsed == 0) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: colors.bgElevated,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border, width: 1),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.timer,
                  size: 14, color: colors.accent),
              const SizedBox(width: 6),
              Text(
                formatGameTime(elapsed),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  fontFeatures: const [FontFeature.tabularFigures()],
                  color: colors.accent,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BallButton extends StatefulWidget {
  final SnookerBall ball;
  final double size;
  final bool isSubtract;
  final VoidCallback onTap;

  const _BallButton({
    required this.ball,
    required this.size,
    required this.isSubtract,
    required this.onTap,
  });

  @override
  State<_BallButton> createState() => _BallButtonState();
}

class _BallButtonState extends State<_BallButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final ball = widget.ball;
    final isBlack = ball == SnookerBall.black;
    final ballColor = isBlack ? const Color(0xFF374151) : ball.color;
    final s = widget.size;
    // Scale derived values relative to ball size
    final highlightSize = s * 0.21;
    final highlightTop = s * 0.15;
    final highlightLeft = s * 0.18;
    final fontSize = (s * 0.30).clamp(14.0, 26.0);
    final labelFontSize = (s * 0.14).clamp(9.0, 13.0);

    final ringColor = isBlack
        ? const Color(0xFF9CA3AF)
        : ballColor.withValues(alpha: 0.6);
    final glowColor = isBlack
        ? const Color(0xFF6B7280).withValues(alpha: 0.5)
        : ballColor.withValues(alpha: 0.45);

    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.88),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 80),
        curve: Curves.bounceOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: ringColor, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: glowColor,
                    blurRadius: 14,
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: SizedBox(
                width: s,
                height: s,
                child: Stack(
                  children: [
                    Container(
                      width: s,
                      height: s,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ballColor,
                      ),
                    ),
                    Positioned(
                      top: highlightTop,
                      left: highlightLeft,
                      child: Container(
                        width: highlightSize,
                        height: highlightSize,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.35),
                        ),
                      ),
                    ),
                    if (widget.isSubtract)
                      Container(
                        width: s,
                        height: s,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: colors.danger.withValues(alpha: 0.15),
                        ),
                      ),
                    Center(
                      child: Text(
                        '${ball.points}',
                        style: TextStyle(
                          fontSize: fontSize,
                          fontWeight: FontWeight.bold,
                          color: ball == SnookerBall.yellow
                              ? const Color(0xFF78350F)
                              : Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 5),
            Text(
              ball.name,
              style: TextStyle(
                fontSize: labelFontSize,
                fontWeight: FontWeight.w600,
                color: ball == SnookerBall.yellow
                    ? AppColors.warning
                    : ballColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Subtract Mode Toggle
// ─────────────────────────────────────────────────────────────────────────────

class _SubtractToggle extends ConsumerWidget {
  final Game game;
  const _SubtractToggle({required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = AppColors.of(context);
    final on = game.isSubtractMode;
    return GestureDetector(
      onTap: () => ref.read(gameProvider.notifier).toggleSubtractMode(),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 48,
        decoration: BoxDecoration(
          gradient: on ? AppColors.subtractGradient : null,
          color: on ? null : colors.bgCard,
          borderRadius: BorderRadius.circular(12),
          border: on
              ? Border.all(color: const Color(0xFFFF6B6B).withValues(alpha: 0.6), width: 1.5)
              : Border.all(color: colors.border, width: 1.5),
          boxShadow: on
              ? [
                  BoxShadow(
                    color: const Color(0xFFEF4444).withValues(alpha: 0.4),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.remove_circle_outline,
                color: on ? Colors.white : colors.textSecondary,
                size: 20),
            const SizedBox(width: 8),
            Text(
              'Subtract Mode',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: on ? Colors.white : colors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Action Buttons (Undo + Next Player)
// ─────────────────────────────────────────────────────────────────────────────

class _ActionButtons extends ConsumerWidget {
  final Game game;
  const _ActionButtons({required this.game});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        Expanded(
          child: _ActionBtn(
            icon: Icons.undo,
            label: 'Undo',
            filled: false,
            onTap: () => ref.read(gameProvider.notifier).undoLastAction(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _ActionBtn(
            icon: Icons.arrow_circle_right,
            label: 'Next Player',
            filled: true,
            onTap: () => ref.read(gameProvider.notifier).nextPlayer(),
          ),
        ),
      ],
    );
  }
}

class _ActionBtn extends StatefulWidget {
  final IconData icon;
  final String label;
  final bool filled;
  final VoidCallback? onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.filled,
    required this.onTap,
  });

  @override
  State<_ActionBtn> createState() => _ActionBtnState();
}

class _ActionBtnState extends State<_ActionBtn> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final enabled = widget.onTap != null;
    final foreground = widget.filled
        ? Colors.white
        : enabled
            ? AppColors.primary
            : colors.textMuted;

    return GestureDetector(
      onTapDown: enabled ? (_) => setState(() => _scale = 0.95) : null,
      onTapUp: enabled
          ? (_) {
              setState(() => _scale = 1.0);
              widget.onTap!();
            }
          : null,
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 120),
        child: Container(
          height: 50,
          decoration: BoxDecoration(
            gradient: widget.filled && enabled
                ? AppColors.primaryGradient
                : null,
            color: widget.filled && enabled
                ? null
                : colors.bgElevated,
            borderRadius: BorderRadius.circular(12),
            border: widget.filled
                ? Border.all(color: colors.accent.withValues(alpha: 0.4), width: 1)
                : Border.all(
                    color: enabled ? colors.border : colors.textMuted,
                    width: 1.5,
                  ),
            boxShadow: widget.filled && enabled
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), blurRadius: 16)]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(widget.icon, color: foreground, size: 20),
              const SizedBox(width: 6),
              Text(
                widget.label,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
