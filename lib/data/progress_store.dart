import 'package:flutter/foundation.dart';

import '../models/exercise_model.dart';
import '../models/exercise_progress.dart';

class ProgressStore extends ChangeNotifier {
  final Map<String, ExerciseProgress> _progressByKey =
  <String, ExerciseProgress>{};

  String _createKey({
    required String moduleId,
    required String exerciseId,
  }) {
    return '$moduleId::$exerciseId';
  }

  ExerciseProgress getOrCreateProgress({
    required String moduleId,
    required String exerciseId,
  }) {
    final String key = _createKey(
      moduleId: moduleId,
      exerciseId: exerciseId,
    );

    return _progressByKey.putIfAbsent(
      key,
          () => ExerciseProgress(
        moduleId: moduleId,
        exerciseId: exerciseId,
      ),
    );
  }

  ExerciseProgress? findProgress({
    required String moduleId,
    required String exerciseId,
  }) {
    final String key = _createKey(
      moduleId: moduleId,
      exerciseId: exerciseId,
    );

    return _progressByKey[key];
  }

  bool isExerciseCompleted({
    required String moduleId,
    required String exerciseId,
  }) {
    final ExerciseProgress? progress = findProgress(
      moduleId: moduleId,
      exerciseId: exerciseId,
    );

    return progress?.completed ?? false;
  }

  void registerAttempt({
    required String moduleId,
    required String exerciseId,
    required bool wasCorrect,
  }) {
    final ExerciseProgress progress = getOrCreateProgress(
      moduleId: moduleId,
      exerciseId: exerciseId,
    );

    progress.registerAttempt(
      wasCorrect: wasCorrect,
    );

    notifyListeners();
  }

  void registerHintUse({
    required String moduleId,
    required String exerciseId,
  }) {
    final ExerciseProgress progress = getOrCreateProgress(
      moduleId: moduleId,
      exerciseId: exerciseId,
    );

    if (progress.hintUsed) {
      return;
    }

    progress.registerHintUse();
    notifyListeners();
  }

  int completedCount({
    required String moduleId,
    required Iterable<ExerciseModel> exercises,
  }) {
    return exercises.where((ExerciseModel exercise) {
      if (!exercise.isActive) {
        return false;
      }

      return isExerciseCompleted(
        moduleId: moduleId,
        exerciseId: exercise.id,
      );
    }).length;
  }

  int attemptedCount({
    required String moduleId,
    required Iterable<ExerciseModel> exercises,
  }) {
    return exercises.where((ExerciseModel exercise) {
      if (!exercise.isActive) {
        return false;
      }

      final ExerciseProgress? progress = findProgress(
        moduleId: moduleId,
        exerciseId: exercise.id,
      );

      if (progress == null) {
        return false;
      }

      return progress.status != ExerciseProgressStatus.notStarted;
    }).length;
  }

  int? firstIncompleteExerciseIndex({
    required String moduleId,
    required List<ExerciseModel> exercises,
  }) {
    for (int index = 0; index < exercises.length; index++) {
      final ExerciseModel exercise = exercises[index];

      if (!exercise.isActive) {
        continue;
      }

      final bool completed = isExerciseCompleted(
        moduleId: moduleId,
        exerciseId: exercise.id,
      );

      if (!completed) {
        return index;
      }
    }

    return null;
  }

  bool isModuleCompleted({
    required String moduleId,
    required Iterable<ExerciseModel> exercises,
  }) {
    final List<ExerciseModel> activeExercises = exercises
        .where((ExerciseModel exercise) => exercise.isActive)
        .toList();

    if (activeExercises.isEmpty) {
      return false;
    }

    return activeExercises.every((ExerciseModel exercise) {
      return isExerciseCompleted(
        moduleId: moduleId,
        exerciseId: exercise.id,
      );
    });
  }

  List<ExerciseProgress> progressForModule(String moduleId) {
    return _progressByKey.values
        .where(
          (ExerciseProgress progress) => progress.moduleId == moduleId,
    )
        .toList();
  }

  void resetExercise({
    required String moduleId,
    required String exerciseId,
  }) {
    final String key = _createKey(
      moduleId: moduleId,
      exerciseId: exerciseId,
    );

    final ExerciseProgress? progress = _progressByKey[key];

    if (progress == null) {
      return;
    }

    progress.reset();
    notifyListeners();
  }

  void resetModule(String moduleId) {
    final int previousLength = _progressByKey.length;

    _progressByKey.removeWhere(
          (
          String key,
          ExerciseProgress progress,
          ) {
        return progress.moduleId == moduleId;
      },
    );

    if (_progressByKey.length != previousLength) {
      notifyListeners();
    }
  }

  void clearAll() {
    if (_progressByKey.isEmpty) {
      return;
    }

    _progressByKey.clear();
    notifyListeners();
  }
}