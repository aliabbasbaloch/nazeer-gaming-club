import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/transfer/game_transfer_service.dart';
import '../../../data/models/game.dart';

class ShareQrScreen extends StatelessWidget {
  final Game game;

  const ShareQrScreen({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);
    final qrData = GameTransferService.encodeGame(game);

    return Scaffold(
      backgroundColor: colors.bgPage,
      appBar: AppBar(
        backgroundColor: colors.navbar,
        title: Text(
          'Transfer Game',
          style: TextStyle(color: colors.textPrimary),
        ),
        iconTheme: IconThemeData(color: colors.textPrimary),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Info card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Icon(Icons.qr_code, color: colors.accent, size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Share this QR Code',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'The other player scans this to load your game',
                      style: TextStyle(
                        color: colors.textMuted,
                        fontSize: 13,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // QR code container with cyan glow
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: colors.accent.withValues(alpha: 0.25),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: QrImageView(
                    data: qrData,
                    version: QrVersions.auto,
                    size: 260,
                    eyeStyle: const QrEyeStyle(
                      eyeShape: QrEyeShape.square,
                      color: AppColors.primary,
                    ),
                    dataModuleStyle: const QrDataModuleStyle(
                      dataModuleShape: QrDataModuleShape.square,
                      color: Color(0xFF080F1E),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Game Summary section
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'GAME SUMMARY',
                  style: TextStyle(
                    color: colors.accent,
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 2,
                  ),
                ),
              ),
              const SizedBox(height: 12),

              // Player list
              ...game.players.map((player) {
                Color chipColor;
                Color chipTextColor;
                if (player.isCompleted) {
                  chipColor = AppColors.warning;
                  chipTextColor = Colors.black;
                } else if (player.id == game.currentPlayerId) {
                  chipColor = AppColors.primary;
                  chipTextColor = Colors.white;
                } else {
                  chipColor = colors.bgElevated;
                  chipTextColor = colors.textSecondary;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: colors.bgCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colors.border),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            player.name,
                            style: TextStyle(
                              color: colors.textPrimary,
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: chipColor,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${player.score}',
                            style: TextStyle(
                              color: chipTextColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),

              const SizedBox(height: 16),

              // Target score
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: colors.bgCard,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Row(
                  children: [
                    Icon(Icons.flag, color: colors.accent, size: 18),
                    const SizedBox(width: 8),
                    Text(
                      'Target Score',
                      style: TextStyle(
                        color: colors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${game.targetScore}',
                      style: TextStyle(
                        color: colors.textPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bottom note
              Text(
                'QR code expires when you leave this screen',
                style: TextStyle(
                  color: colors.textMuted,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
