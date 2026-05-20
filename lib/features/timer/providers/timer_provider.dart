import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class TimerState {
  final int elapsedSeconds;
  final bool isRunning;
  final bool isPaused;

  const TimerState({
    this.elapsedSeconds = 0,
    this.isRunning = false,
    this.isPaused = false,
  });

  TimerState copyWith({int? elapsedSeconds, bool? isRunning, bool? isPaused}) {
    return TimerState(
      elapsedSeconds: elapsedSeconds ?? this.elapsedSeconds,
      isRunning: isRunning ?? this.isRunning,
      isPaused: isPaused ?? this.isPaused,
    );
  }

  String get formattedTime {
    final hours = elapsedSeconds ~/ 3600;
    final minutes = (elapsedSeconds % 3600) ~/ 60;
    final secs = elapsedSeconds % 60;
    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }
}

class TimerNotifier extends StateNotifier<TimerState> {
  Timer? _timer;

  TimerNotifier() : super(const TimerState());

  void start() {
    if (state.isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
    state = state.copyWith(isRunning: true, isPaused: false);
  }

  void pause() {
    _timer?.cancel();
    state = state.copyWith(isPaused: true, isRunning: false);
  }

  void resume() {
    if (state.isRunning) return;
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(elapsedSeconds: state.elapsedSeconds + 1);
    });
    state = state.copyWith(isRunning: true, isPaused: false);
  }

  void stop() {
    _timer?.cancel();
    _timer = null;
    state = const TimerState();
  }

  int get durationInMinutes => state.elapsedSeconds ~/ 60;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}

final timerProvider = StateNotifierProvider<TimerNotifier, TimerState>((ref) {
  return TimerNotifier();
});
