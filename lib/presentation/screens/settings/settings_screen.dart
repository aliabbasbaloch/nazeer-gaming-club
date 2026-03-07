import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../providers/settings_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _showTargetSelector = false;

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final colors = ref.watch(appColorsProvider);

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.navbar,
        centerTitle: true,
        title: Text('Settings',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: colors.textPrimary)),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            // ── Developer card ────────────────────────────────────────────
            const _DeveloperCard(),
            const SizedBox(height: 20),

            // ── Appearance ───────────────────────────────────────────────
            const _SectionHeader(title: 'Appearance'),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.dark_mode,
                  title: 'Dark Mode',
                  trailing: Switch(
                    value: settings.isDarkMode,
                    onChanged: (_) =>
                        ref.read(settingsProvider.notifier).toggleDarkMode(),
                    activeThumbColor: AppColors.primary,
                  ),
                  onTap: () =>
                      ref.read(settingsProvider.notifier).toggleDarkMode(),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // ── Game ─────────────────────────────────────────────────────
            const _SectionHeader(title: 'Game'),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.flag,
                  title: 'Default Target Score',
                  subtitle: '${settings.defaultTargetScore}',
                  trailing: AnimatedRotation(
                    turns: _showTargetSelector ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(Icons.chevron_right,
                        color: colors.textSecondary, size: 20),
                  ),
                  onTap: () => setState(
                      () => _showTargetSelector = !_showTargetSelector),
                ),
                if (_showTargetSelector)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    child: _TargetScoreSelector(
                      selected: settings.defaultTargetScore,
                      onSelect: (score) => ref
                          .read(settingsProvider.notifier)
                          .updateDefaultTargetScore(score),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 20),

            // ── About ─────────────────────────────────────────────────────
            const _SectionHeader(title: 'About'),
            _SettingsGroup(
              children: [
                _SettingsRow(
                  icon: Icons.info_outline,
                  title: 'About App',
                  trailing: Icon(Icons.chevron_right,
                      color: colors.textSecondary, size: 20),
                  onTap: () => _showAboutAppDialog(context),
                ),
                const _Divider(),
                _SettingsRow(
                  icon: Icons.verified,
                  title: 'App Version',
                  subtitle: AppConstants.appVersion,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showAboutAppDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(AppConstants.appName),
        content: const Text(
          'A premium snooker score tracking application.\n\n'
          'Developer: Ali Abbas\n\n'
          'Version ${AppConstants.appVersion}',
        ),
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Developer Card
// ─────────────────────────────────────────────────────────────────────────────

class _DeveloperCard extends StatelessWidget {
  const _DeveloperCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          )
        ],
      ),
      child: Column(
        children: [
          // Circular logo
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            AppConstants.appName,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          const Text(
            'by Ali Abbas',
            style: TextStyle(
              fontSize: 13,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Version ${AppConstants.appVersion}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Section Header
// ─────────────────────────────────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 16, 6),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 1.2,
          color: colors.textSecondary,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Group (iOS-style inset grouped list)
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsGroup extends StatelessWidget {
  final List<Widget> children;
  const _SettingsGroup({required this.children});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: colors.bgCard,
        borderRadius: BorderRadius.circular(14),
        boxShadow: colors.cardShadow,
      ),
      child: Column(children: children),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Settings Row
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsRow({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: SizedBox(
        height: 54,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 22),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        color: colors.textPrimary,
                      ),
                    ),
                    if (subtitle case final subtitle?)
                      Text(
                        subtitle,
                        style: TextStyle(
                            fontSize: 13, color: colors.textSecondary),
                      ),
                  ],
                ),
              ),
              ?trailing,
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Inset divider
// ─────────────────────────────────────────────────────────────────────────────

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 52),
      child: Container(height: 0.5, color: colors.border),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Target Score Selector (same as Home screen)
// ─────────────────────────────────────────────────────────────────────────────

class _TargetScoreSelector extends StatelessWidget {
  final int selected;
  final ValueChanged<int> onSelect;

  const _TargetScoreSelector({
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: AppConstants.targetScores.map((score) {
        final isSelected = score == selected;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3),
            child: GestureDetector(
              onTap: () => onSelect(score),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppColors.primary
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primary, width: 1.5),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppColors.primary.withValues(alpha: 0.2),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  '$score',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.bold,
                    color: isSelected
                        ? Colors.white
                        : AppColors.primary,
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}
