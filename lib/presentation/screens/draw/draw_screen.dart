import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/draw_provider.dart';
import '../../providers/settings_provider.dart';

/// Provider to track tab switching for navigation after "Add to Game"
final navigateToHomeProvider = StateProvider<bool>((ref) => false);

class DrawScreen extends ConsumerStatefulWidget {
  const DrawScreen({super.key});

  @override
  ConsumerState<DrawScreen> createState() => _DrawScreenState();
}

class _DrawScreenState extends ConsumerState<DrawScreen>
    with SingleTickerProviderStateMixin {
  final _nameController = TextEditingController();
  late AnimationController _revealController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _revealController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.5, end: 1.12), weight: 60),
      TweenSequenceItem(tween: Tween(begin: 1.12, end: 0.95), weight: 20),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(
      parent: _revealController,
      curve: Curves.easeOutBack,
    ));
  }

  @override
  void dispose() {
    _nameController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  void _addName() {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;
    ref.read(drawProvider.notifier).addName(name);
    _nameController.clear();
  }

  void _drawNext() {
    HapticFeedback.lightImpact();
    ref.read(drawProvider.notifier).drawNext();
    _revealController.forward(from: 0);
  }

  void _showResetDialog() {
    final colors = AppColors.of(context);
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Draw'),
        content: const Text(
            'This will clear all names and the current draw. Continue?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(drawProvider.notifier).reset();
            },
            child: Text('Reset', style: TextStyle(color: colors.danger)),
          ),
        ],
      ),
    );
  }

  void _showAddToGameDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Start New Game'),
        content: const Text(
            'This will replace the current game with the drawn player order. Continue?'),
        actions: [
          TextButton(
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _addToGameAndNavigate();
            },
            child: const Text('Start Game'),
          ),
        ],
      ),
    );
  }

  void _addToGameAndNavigate() {
    // Signal to navigate to Home tab
    ref.read(navigateToHomeProvider.notifier).state = true;
  }

  @override
  Widget build(BuildContext context) {
    final drawData = ref.watch(drawProvider);
    final colors = ref.watch(appColorsProvider);
    final canAddName = drawData.candidateNames.length < 12 &&
        drawData.drawState != DrawState.drawing &&
        drawData.drawState != DrawState.complete;
    final canDraw = drawData.candidateNames.length >= 2 &&
        drawData.drawState != DrawState.complete;
    final isComplete = drawData.drawState == DrawState.complete;
    final hasData = drawData.candidateNames.isNotEmpty ||
        drawData.drawnNames.isNotEmpty;

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.navbar,
        centerTitle: true,
        title: Text(
          'Name Draw',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.textPrimary,
          ),
        ),
        actions: [
          if (hasData)
            IconButton(
              onPressed: _showResetDialog,
              icon: Icon(
                Icons.refresh,
                color: colors.danger,
                size: 22,
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Name entry row
              _AddNameRow(
                controller: _nameController,
                canAdd: canAddName,
                onAdd: _addName,
              ),
              const SizedBox(height: 20),

              // Candidate chips section - only show if candidates exist and not complete
              if (drawData.candidateNames.isNotEmpty &&
                  !isComplete) ...[
                const _SectionHeader(label: 'Names to Draw'),
                const SizedBox(height: 8),
                _CandidateChips(
                  names: drawData.candidateNames,
                  canRemove: drawData.drawState == DrawState.empty ||
                      drawData.drawState == DrawState.ready,
                  onRemove: (index) =>
                      ref.read(drawProvider.notifier).removeName(index),
                ),
                const SizedBox(height: 20),
              ],

              // Empty state
              if (drawData.candidateNames.isEmpty &&
                  drawData.drawnNames.isEmpty)
                const _EmptyState(),

              // Reveal card
              if (drawData.candidateNames.isNotEmpty ||
                  drawData.drawnNames.isNotEmpty) ...[
                const _SectionHeader(label: 'Draw Result'),
                const SizedBox(height: 8),
                _RevealCard(
                  drawData: drawData,
                  scaleAnimation: _scaleAnimation,
                ),
                const SizedBox(height: 20),
              ],

              // Draw button OR Add to Game button
              if (drawData.candidateNames.isNotEmpty ||
                  drawData.drawnNames.isNotEmpty) ...[
                if (!isComplete)
                  _DrawButton(
                    canDraw: canDraw,
                    onTap: _drawNext,
                    remaining: drawData.candidateNames.length -
                        drawData.drawnNames.length,
                  )
                else
                  _AddToGameButton(
                    onTap: _showAddToGameDialog,
                  ),
                const SizedBox(height: 20),
              ],

              // Drawn order list
              if (drawData.drawnNames.isNotEmpty) ...[
                const _SectionHeader(label: 'Draw Order'),
                const SizedBox(height: 8),
                _DrawnOrderList(
                  names: drawData.drawnNames,
                ),
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
// Add Name Row
// ─────────────────────────────────────────────────────────────────────────────

class _AddNameRow extends StatefulWidget {
  final TextEditingController controller;
  final bool canAdd;
  final VoidCallback onAdd;

  const _AddNameRow({
    required this.controller,
    required this.canAdd,
    required this.onAdd,
  });

  @override
  State<_AddNameRow> createState() => _AddNameRowState();
}

class _AddNameRowState extends State<_AddNameRow> {
  double _btnScale = 1.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(12),
            ),
            child: TextField(
              controller: widget.controller,
              decoration: InputDecoration(
                hintText: 'Enter player name...',
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                prefixIcon: Icon(Icons.person_add,
                    color: AppColors.primary, size: 20),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: widget.controller,
                  builder: (_, val, _) => val.text.isEmpty
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onTap: () => widget.controller.clear(),
                          child: Icon(Icons.cancel,
                              size: 18, color: colors.textMuted),
                        ),
                ),
                border: InputBorder.none,
                hintStyle:
                    TextStyle(color: colors.textSecondary, fontSize: 15),
              ),
              style: TextStyle(color: colors.textPrimary),
              onSubmitted: (_) => widget.onAdd(),
              enabled: widget.canAdd,
            ),
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
                gradient: widget.canAdd
                    ? AppColors.primaryGradient
                    : null,
                color: widget.canAdd ? null : colors.textMuted,
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
// Candidate Chips
// ─────────────────────────────────────────────────────────────────────────────

class _CandidateChips extends StatelessWidget {
  final List<String> names;
  final bool canRemove;
  final void Function(int index) onRemove;

  const _CandidateChips({
    required this.names,
    required this.canRemove,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: List.generate(names.length, (index) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: colors.bgCard,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colors.border, width: 1),
            boxShadow: colors.cardShadow,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                names[index],
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: colors.textPrimary,
                ),
              ),
              if (canRemove) ...[
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: () => onRemove(index),
                  child: Icon(
                    Icons.cancel,
                    size: 18,
                    color: colors.textSecondary,
                  ),
                ),
              ],
            ],
          ),
        );
      }),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Empty State
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.1),
            ),
            child: const Center(
              child: Text(
                '🎲',
                style: TextStyle(fontSize: 36),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Add at least 2 names',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: colors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'to start a random draw',
            style: TextStyle(
              fontSize: 14,
              color: colors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Reveal Card
// ─────────────────────────────────────────────────────────────────────────────

class _RevealCard extends StatelessWidget {
  final DrawData drawData;
  final Animation<double> scaleAnimation;

  const _RevealCard({
    required this.drawData,
    required this.scaleAnimation,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final hasDrawn = drawData.lastDrawnName != null;
    final position = drawData.drawnNames.length;

    return AnimatedBuilder(
      animation: scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: hasDrawn ? scaleAnimation.value : 1.0,
          child: child,
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
        decoration: BoxDecoration(
          gradient: colors.cardGradient,
          borderRadius: BorderRadius.circular(20),
          boxShadow: colors.cardShadow,
        ),
        child: hasDrawn
            ? Column(
                children: [
                  // Position badge
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: AppColors.primary.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '#$position',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Drawn name
                  Text(
                    drawData.lastDrawnName!,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: colors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  // Decorative sparkles
                  const Text(
                    '✨',
                    style: TextStyle(fontSize: 24),
                  ),
                ],
              )
            : Column(
                children: [
                  Icon(
                    Icons.shuffle,
                    size: 40,
                    color: colors.textSecondary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap Draw Next to reveal\nthe first name',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: colors.textSecondary,
                      fontStyle: FontStyle.italic,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Draw Button
// ─────────────────────────────────────────────────────────────────────────────

class _DrawButton extends StatefulWidget {
  final bool canDraw;
  final VoidCallback onTap;
  final int remaining;

  const _DrawButton({
    required this.canDraw,
    required this.onTap,
    required this.remaining,
  });

  @override
  State<_DrawButton> createState() => _DrawButtonState();
}

class _DrawButtonState extends State<_DrawButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTapDown: (_) {
        if (widget.canDraw) setState(() => _scale = 0.95);
      },
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        if (widget.canDraw) widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            gradient: widget.canDraw
                ? AppColors.primaryGradient
                : null,
            color: widget.canDraw
                ? null
                : colors.textMuted.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(14),
            boxShadow: widget.canDraw
                ? [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.shuffle,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Draw Next',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              if (widget.remaining > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${widget.remaining}',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Add to Game Button
// ─────────────────────────────────────────────────────────────────────────────

class _AddToGameButton extends StatefulWidget {
  final VoidCallback onTap;

  const _AddToGameButton({
    required this.onTap,
  });

  @override
  State<_AddToGameButton> createState() => _AddToGameButtonState();
}

class _AddToGameButtonState extends State<_AddToGameButton> {
  double _scale = 1.0;

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      onTapDown: (_) => setState(() => _scale = 0.95),
      onTapUp: (_) {
        setState(() => _scale = 1.0);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _scale = 1.0),
      child: AnimatedScale(
        scale: _scale,
        duration: const Duration(milliseconds: 100),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: colors.success,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: colors.success.withValues(alpha: 0.35),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.play_arrow,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Add to Game',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Drawn Order List
// ─────────────────────────────────────────────────────────────────────────────

class _DrawnOrderList extends StatelessWidget {
  final List<String> names;

  const _DrawnOrderList({
    required this.names,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Column(
      children: List.generate(names.length, (index) {
        return TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
          builder: (context, value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(opacity: value, child: child),
            );
          },
          child: Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: colors.bgCard,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                left: BorderSide(color: AppColors.warning, width: 4),
              ),
              boxShadow: colors.cardShadow,
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Position badge
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.warning.withValues(alpha: 0.4),
                        width: 1,
                      ),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '#${index + 1}',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.warning,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name
                  Expanded(
                    child: Text(
                      names[index],
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: colors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
