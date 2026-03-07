import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/transfer/game_transfer_model.dart';
import '../../../core/transfer/game_transfer_service.dart';
import '../../providers/game_provider.dart';
import '../draw/draw_screen.dart';

class ScanQrScreen extends ConsumerStatefulWidget {
  const ScanQrScreen({super.key});

  @override
  ConsumerState<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends ConsumerState<ScanQrScreen> {
  final MobileScannerController _scannerController = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  void _onQRDetected(BarcodeCapture capture) {
    if (_isProcessing) return;

    final rawValue = capture.barcodes.firstOrNull?.rawValue;
    if (rawValue == null) return;

    _isProcessing = true;

    try {
      final transfer = GameTransferService.decodeGame(rawValue);
      _showConfirmationDialog(transfer);
    } on InvalidQRException catch (e) {
      _showErrorSnackBar(e.message);
      _isProcessing = false;
    } catch (_) {
      _showErrorSnackBar('Failed to read QR code');
      _isProcessing = false;
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showConfirmationDialog(GameTransferModel transfer) {
    final currentGame = ref.read(gameProvider);
    final hasActiveGame =
        currentGame != null && currentGame.players.isNotEmpty;

    final formattedDate =
        DateFormat('d MMM yyyy, h:mm a').format(transfer.transferredAt.toLocal());

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.bgCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppColors.border),
        ),
        title: const Text(
          'Load This Game?',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transfer timestamp
              Row(
                children: [
                  const Icon(Icons.access_time,
                      color: AppColors.textMuted, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    formattedDate,
                    style: const TextStyle(
                      color: AppColors.textMuted,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Player list
              ...transfer.players.map((p) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        if (p.isCompleted)
                          const Icon(Icons.check_circle,
                              color: AppColors.warning, size: 16)
                        else
                          const Icon(Icons.person,
                              color: AppColors.textMuted, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            p.name,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Text(
                          '${p.score}',
                          style: TextStyle(
                            color: p.isCompleted
                                ? AppColors.warning
                                : AppColors.textSecondary,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 12),

              // Target score
              Row(
                children: [
                  const Icon(Icons.flag, color: AppColors.accent, size: 16),
                  const SizedBox(width: 6),
                  Text(
                    'Target: ${transfer.targetScore}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),

              // Warning if active game
              if (hasActiveGame) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.warningBg,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.warning.withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_rounded,
                          color: AppColors.warning, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Your current game will be replaced',
                          style: TextStyle(
                            color: AppColors.warning,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _isProcessing = false;
            },
            child:
                const Text('Cancel', style: TextStyle(color: AppColors.textMuted)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _loadTransferredGame(transfer);
            },
            child: const Text(
              'Load Game',
              style: TextStyle(
                  color: AppColors.accent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _loadTransferredGame(GameTransferModel transfer) async {
    await ref.read(gameProvider.notifier).loadTransferredGame(transfer);
    ref.read(navigateToHomeProvider.notifier).state = true;

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Game loaded — ${transfer.players.length} players',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      appBar: AppBar(
        backgroundColor: AppColors.navbar,
        title: const Text(
          'Scan to Receive Game',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        iconTheme: const IconThemeData(color: AppColors.textPrimary),
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _scannerController,
            onDetect: _onQRDetected,
            errorBuilder: (context, error, child) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(32),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.camera_alt,
                          color: AppColors.textMuted, size: 48),
                      const SizedBox(height: 16),
                      Text(
                        error.errorCode == MobileScannerErrorCode.permissionDenied
                            ? 'Camera permission denied.\nPlease enable it in Settings.'
                            : 'Camera error: ${error.errorDetails?.message ?? 'Unknown'}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),

          // Scan overlay
          CustomPaint(
            size: Size.infinite,
            painter: _ScanOverlayPainter(),
          ),

          // Instruction card at top
          Positioned(
            top: 24,
            left: 24,
            right: 24,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.bgCard.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.qr_code_scanner,
                      color: AppColors.accent, size: 24),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Point camera at the QR code\non the other player\'s phone',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom instruction text
          Positioned(
            bottom: 80,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Point camera at QR code',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScanOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const cutoutSize = 240.0;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final left = cx - cutoutSize / 2;
    final top = cy - cutoutSize / 2;
    final right = cx + cutoutSize / 2;
    final bottom = cy + cutoutSize / 2;

    // Dark overlay with transparent cutout
    final overlayPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.6);
    final cutoutRect = Rect.fromLTRB(left, top, right, bottom);

    canvas.saveLayer(Offset.zero & size, Paint());
    canvas.drawRect(Offset.zero & size, overlayPaint);
    canvas.drawRect(cutoutRect, Paint()..blendMode = BlendMode.clear);
    canvas.restore();

    // Cyan L-shaped corner brackets
    const bracketLen = 30.0;
    const bracketThickness = 3.0;
    final bracketPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = bracketThickness
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Top-left
    canvas.drawLine(
        Offset(left, top + bracketLen), Offset(left, top), bracketPaint);
    canvas.drawLine(
        Offset(left, top), Offset(left + bracketLen, top), bracketPaint);

    // Top-right
    canvas.drawLine(Offset(right - bracketLen, top), Offset(right, top),
        bracketPaint);
    canvas.drawLine(
        Offset(right, top), Offset(right, top + bracketLen), bracketPaint);

    // Bottom-left
    canvas.drawLine(Offset(left, bottom - bracketLen), Offset(left, bottom),
        bracketPaint);
    canvas.drawLine(Offset(left, bottom), Offset(left + bracketLen, bottom),
        bracketPaint);

    // Bottom-right
    canvas.drawLine(Offset(right - bracketLen, bottom),
        Offset(right, bottom), bracketPaint);
    canvas.drawLine(Offset(right, bottom),
        Offset(right, bottom - bracketLen), bracketPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
