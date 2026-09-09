enum ExerciseProgressStatus {
  notStarted,
  inProgress,
  completed,
}

class ExerciseProgress {
  final String moduleId;
  final String exerciseId;

  int attempts;
  int incorrectAttempts;

  bool hintUsed;
  bool completed;
  bool? lastAttemptWasCorrect;

  DateTime? lastAttemptAt;
  DateTime? completedAt;

  ExerciseProgress({
    required this.moduleId,
    required this.exerciseId,
    this.attempts = 0,
    this.incorrectAttempts = 0,
    this.hintUsed = false,
    this.completed = false,
    this.lastAttemptWasCorrect,
    this.lastAttemptAt,
    this.completedAt,
  });

  ExerciseProgressStatus get status {
    if (completed) {
      return ExerciseProgressStatus.completed;
    }

    if (attempts > 0 || hintUsed) {
      return ExerciseProgressStatus.inProgress;
    }

    return ExerciseProgressStatus.notStarted;
  }

  void registerAttempt({
    required bool wasCorrect,
  }) {
    attempts++;
    lastAttemptWasCorrect = wasCorrect;
    lastAttemptAt = DateTime.now();

    if (wasCorrect) {
      completed = true;
      completedAt ??= DateTime.now();
    } else {
      incorrectAttempts++;
    }
  }

  void registerHintUse() {
    hintUsed = true;
  }

  void reset() {
    attempts = 0;
    incorrectAttempts = 0;
    hintUsed = false;
    completed = false;
    lastAttemptWasCorrect = null;
    lastAttemptAt = null;
    completedAt = null;
  }
}