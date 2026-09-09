import 'package:flutter/foundation.dart';

import '../models/diagram_model.dart';
import '../models/exercise_model.dart';
import '../models/learning_module.dart';

class ModuleStore extends ChangeNotifier {
  final List<LearningModule> _modules = <LearningModule>[
    const LearningModule(
      id: 'module-1',
      title: 'Módulo 1',
      description: 'Exercícios introdutórios de lógica de programação.',
      subject: 'Lógica de Programação',
      order: 1,
      exercises: <ExerciseModel>[
        ExerciseModel(
          id: 'module-1-exercise-1',
          moduleId: 'module-1',
          title: 'Exercício 1',
          statement: 'Identifique os seguintes símbolos de fluxograma.',
          hint:
          'Observe o formato de cada símbolo. O losango representa '
              'uma decisão, o retângulo representa um processo e o oval '
              'representa o início.',
          subject: 'Lógica de Programação',
          programmingLanguage: null,
          author: 'Administrador',
          order: 1,
          type: ExerciseType.dragLabelsToDiagram,
          difficulty: ExerciseDifficulty.beginner,
          board: ExerciseBoard(
            logicalWidth: 1000,
            logicalHeight: 700,
            showGrid: false,
            allowElementMovement: false,
            allowConnections: false,
            elements: <BoardElement>[
              BoardElement(
                id: 'target-decision',
                type: BoardElementType.flowchartShape,
                shapeType: FlowchartShapeType.decision,
                x: 100,
                y: 80,
                width: 300,
                height: 170,
                acceptsDrop: true,
              ),
              BoardElement(
                id: 'target-input',
                type: BoardElementType.flowchartShape,
                shapeType: FlowchartShapeType.inputOutput,
                x: 600,
                y: 80,
                width: 300,
                height: 150,
                acceptsDrop: true,
              ),
              BoardElement(
                id: 'target-start',
                type: BoardElementType.flowchartShape,
                shapeType: FlowchartShapeType.startEnd,
                x: 100,
                y: 400,
                width: 300,
                height: 150,
                acceptsDrop: true,
              ),
              BoardElement(
                id: 'target-process',
                type: BoardElementType.flowchartShape,
                shapeType: FlowchartShapeType.process,
                x: 600,
                y: 400,
                width: 300,
                height: 150,
                acceptsDrop: true,
              ),
            ],
            connections: <BoardConnection>[],
          ),
          alternatives: <ExerciseAlternative>[
            ExerciseAlternative(
              id: 'input',
              label: 'Entrada',
            ),
            ExerciseAlternative(
              id: 'output',
              label: 'Saída',
            ),
            ExerciseAlternative(
              id: 'decision',
              label: 'Decisão',
            ),
            ExerciseAlternative(
              id: 'process',
              label: 'Processo',
            ),
            ExerciseAlternative(
              id: 'repetition',
              label: 'Repetição',
            ),
            ExerciseAlternative(
              id: 'start',
              label: 'Início',
            ),
          ],
          answerKey: ExerciseAnswerKey(
            placements: <String, String>{
              'target-decision': 'decision',
              'target-input': 'input',
              'target-start': 'start',
              'target-process': 'process',
            },
          ),
          positiveFeedback: 'Excelente! Você acertou a atividade!',
          negativeFeedback:
          'Que pena! Revise os símbolos e tente novamente.',
        ),
      ],
    ),
  ];

  List<LearningModule> get modules {
    final result = List<LearningModule>.from(_modules)
      ..sort((a, b) => a.order.compareTo(b.order));

    return List<LearningModule>.unmodifiable(result);
  }

  LearningModule? findModule(String moduleId) {
    for (final module in _modules) {
      if (module.id == moduleId) {
        return module;
      }
    }

    return null;
  }

  ExerciseModel? findExercise({
    required String moduleId,
    required String exerciseId,
  }) {
    final module = findModule(moduleId);

    if (module == null) {
      return null;
    }

    for (final exercise in module.exercises) {
      if (exercise.id == exerciseId) {
        return exercise;
      }
    }

    return null;
  }

  void addModule(LearningModule module) {
    _modules.add(module);
    notifyListeners();
  }

  void updateModule(LearningModule updatedModule) {
    final index = _modules.indexWhere(
          (module) => module.id == updatedModule.id,
    );

    if (index == -1) {
      return;
    }

    _modules[index] = updatedModule;
    notifyListeners();
  }

  void addExercise({
    required String moduleId,
    required ExerciseModel exercise,
  }) {
    final moduleIndex = _modules.indexWhere(
          (module) => module.id == moduleId,
    );

    if (moduleIndex == -1) {
      return;
    }

    final currentModule = _modules[moduleIndex];

    final updatedExercises = <ExerciseModel>[
      ...currentModule.exercises,
      exercise,
    ]..sort((a, b) => a.order.compareTo(b.order));

    _modules[moduleIndex] = currentModule.copyWith(
      exercises: updatedExercises,
    );

    notifyListeners();
  }

  void updateExercise({
    required String moduleId,
    required ExerciseModel updatedExercise,
  }) {
    final moduleIndex = _modules.indexWhere(
          (module) => module.id == moduleId,
    );

    if (moduleIndex == -1) {
      return;
    }

    final currentModule = _modules[moduleIndex];

    final exerciseIndex = currentModule.exercises.indexWhere(
          (exercise) => exercise.id == updatedExercise.id,
    );

    if (exerciseIndex == -1) {
      return;
    }

    final updatedExercises = List<ExerciseModel>.from(
      currentModule.exercises,
    );

    updatedExercises[exerciseIndex] = updatedExercise;
    updatedExercises.sort((a, b) => a.order.compareTo(b.order));

    _modules[moduleIndex] = currentModule.copyWith(
      exercises: updatedExercises,
    );

    notifyListeners();
  }

  void removeExercise({
    required String moduleId,
    required String exerciseId,
  }) {
    final moduleIndex = _modules.indexWhere(
          (module) => module.id == moduleId,
    );

    if (moduleIndex == -1) {
      return;
    }

    final currentModule = _modules[moduleIndex];

    final updatedExercises = currentModule.exercises
        .where((exercise) => exercise.id != exerciseId)
        .toList();

    _modules[moduleIndex] = currentModule.copyWith(
      exercises: updatedExercises,
    );

    notifyListeners();
  }

  String createId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}