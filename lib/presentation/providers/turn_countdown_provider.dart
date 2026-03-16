import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'settings_provider.dart';

final turnCountdownProvider =
    StateNotifierProvider<TurnCountdownNotifier, int>((ref) {
  return TurnCountdownNotifier(ref);
});

class TurnCountdownNotifier extends StateNotifier<int> {
  TurnCountdownNotifier(this._ref) : super(30);
  final Ref _ref;
  Timer? _timer;

  void startCountdown() {
    _timer?.cancel();
    state = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (state <= 1) {
        _timer?.cancel();
        state = 0;
      } else {
        state--;
        if (state == 10) {
          if (_ref.read(settingsProvider).hapticEnabled) {
            HapticFeedback.mediumImpact();
          }
        }
      }
    });
  }

  void stopCountdown() {
    _timer?.cancel();
    state = -1;
  }

  void resetCountdown() {
    startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
