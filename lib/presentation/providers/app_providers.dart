import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/audio_service.dart';
import '../../core/services/storage_service.dart';
import '../../data/models/quiz_attempt_model.dart';
import '../../data/models/unit_model.dart';
import '../../data/models/user_progress_model.dart';
import '../../data/repositories/curriculum_repository_impl.dart';
import '../../data/repositories/progress_repository_impl.dart';
import '../../domain/repositories/curriculum_repository.dart';
import '../../domain/repositories/progress_repository.dart';

// Service providers (can be overridden in tests)
final storageServiceProvider = Provider<StorageService>((ref) {
  return SharedPreferencesStorageService();
});

final audioServiceProvider = Provider<AudioService>((ref) {
  final service = FlutterTtsAudioService();
  ref.onDispose(() => service.dispose());
  return service;
});

// Repository providers
final curriculumRepositoryProvider = Provider<CurriculumRepository>((ref) {
  return CurriculumRepositoryImpl();
});

final progressRepositoryProvider = Provider<ProgressRepository>((ref) {
  final storage = ref.watch(storageServiceProvider);
  return ProgressRepositoryImpl(storage);
});

// Curriculum data provider
final curriculumUnitsProvider = FutureProvider<List<UnitModel>>((ref) async {
  final repo = ref.watch(curriculumRepositoryProvider);
  return repo.getAllUnits();
});

// Progress AsyncNotifier provider (Riverpod 2.x & 3.x modern pattern)
class ProgressNotifier extends AsyncNotifier<UserProgressModel> {
  @override
  Future<UserProgressModel> build() async {
    final repo = ref.watch(progressRepositoryProvider);
    return repo.getProgress();
  }

  Future<void> completeLesson(String lessonId) async {
    final repo = ref.read(progressRepositoryProvider);
    await repo.markLessonComplete(lessonId);
    state = AsyncValue.data(await repo.getProgress());
  }

  Future<void> recordQuizResult(String unitId, int scorePercent) async {
    final repo = ref.read(progressRepositoryProvider);
    await repo.recordQuizResult(unitId, scorePercent);
    state = AsyncValue.data(await repo.getProgress());
  }

  Future<void> recordQuizAttempt(QuizAttemptModel attempt) async {
    final repo = ref.read(progressRepositoryProvider);
    await repo.recordQuizAttempt(attempt);
    state = AsyncValue.data(await repo.getProgress());
  }

  Future<void> reset() async {
    final repo = ref.read(progressRepositoryProvider);
    await repo.resetProgress();
    state = AsyncValue.data(UserProgressModel.initial());
  }
}

final progressProvider =
    AsyncNotifierProvider<ProgressNotifier, UserProgressModel>(ProgressNotifier.new);

// Theme Mode Notifier
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() => ThemeMode.system;

  void toggle() {
    state = state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
  }

  void setMode(ThemeMode mode) {
    state = mode;
  }
}

final themeModeProvider =
    NotifierProvider<ThemeModeNotifier, ThemeMode>(ThemeModeNotifier.new);
