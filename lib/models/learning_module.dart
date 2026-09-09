import 'exercise_model.dart';

class LearningModule {
  final String id;
  final String title;
  final String description;
  final String subject;

  final int order;
  final bool isActive;

  final List<ExerciseModel> exercises;

  const LearningModule({
    required this.id,
    required this.title,
    required this.description,
    required this.subject,
    required this.order,
    required this.exercises,
    this.isActive = true,
  });

  int get activeExerciseCount {
    return exercises.where((exercise) => exercise.isActive).length;
  }

  LearningModule copyWith({
    String? id,
    String? title,
    String? description,
    String? subject,
    int? order,
    bool? isActive,
    List<ExerciseModel>? exercises,
  }) {
    return LearningModule(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      subject: subject ?? this.subject,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      exercises: exercises ?? this.exercises,
    );
  }
}