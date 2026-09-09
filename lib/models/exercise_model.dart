import 'diagram_model.dart';

enum ExerciseType {
  dragLabelsToDiagram,
  buildFlowchart,
  multipleChoice,
  orderBlocks,
  completeDiagram,
}

enum ExerciseDifficulty {
  beginner,
  intermediate,
  advanced,
}

enum AlternativeContentType {
  text,
  flowchartShape,
}

enum ExerciseAttachmentType {
  image,
  document,
}

class ExerciseAlternative {
  final String id;
  final String label;
  final AlternativeContentType contentType;

  // Utilizado quando a alternativa for uma forma, e não apenas texto.
  final FlowchartShapeType? shapeType;

  const ExerciseAlternative({
    required this.id,
    required this.label,
    this.contentType = AlternativeContentType.text,
    this.shapeType,
  });
}

class ExerciseAttachment {
  final String id;
  final String name;
  final ExerciseAttachmentType type;

  // Pode representar um asset ou outra referência local futuramente.
  final String reference;

  const ExerciseAttachment({
    required this.id,
    required this.name,
    required this.type,
    required this.reference,
  });
}

class ExerciseAnswerKey {
  // Relaciona o ID de um alvo do quadro ao ID da alternativa correta.
  final Map<String, String> placements;

  // Para futuras questões de múltipla escolha.
  final List<String> correctAlternativeIds;

  // Para futuros exercícios de ordenação.
  final List<String> orderedAlternativeIds;

  const ExerciseAnswerKey({
    this.placements = const <String, String>{},
    this.correctAlternativeIds = const <String>[],
    this.orderedAlternativeIds = const <String>[],
  });
}

class ExerciseModel {
  final String id;
  final String moduleId;

  final String title;
  final String statement;
  final String hint;

  final String subject;

  // Será nulo quando o botão "Linguagem" estiver desligado.
  final String? programmingLanguage;

  final String author;

  final int order;
  final ExerciseType type;
  final ExerciseDifficulty difficulty;

  // Quadro que o estudante verá.
  final ExerciseBoard board;

  // Gabarito visual opcional para exercícios de construção completa.
  final ExerciseBoard? solutionBoard;

  final List<ExerciseAlternative> alternatives;
  final List<ExerciseAttachment> attachments;

  final ExerciseAnswerKey answerKey;

  final String positiveFeedback;
  final String negativeFeedback;

  final bool isActive;

  const ExerciseModel({
    required this.id,
    required this.moduleId,
    required this.title,
    required this.statement,
    required this.hint,
    required this.subject,
    required this.author,
    required this.order,
    required this.type,
    required this.difficulty,
    required this.board,
    required this.alternatives,
    required this.answerKey,
    this.programmingLanguage,
    this.solutionBoard,
    this.attachments = const <ExerciseAttachment>[],
    this.positiveFeedback = 'Excelente! Você acertou a atividade!',
    this.negativeFeedback = 'Que pena! Revise sua resposta e tente novamente.',
    this.isActive = true,
  });

  bool get usesProgrammingLanguage {
    return programmingLanguage != null &&
        programmingLanguage!.trim().isNotEmpty;
  }

  ExerciseModel copyWith({
    String? id,
    String? moduleId,
    String? title,
    String? statement,
    String? hint,
    String? subject,
    String? programmingLanguage,
    bool removeProgrammingLanguage = false,
    String? author,
    int? order,
    ExerciseType? type,
    ExerciseDifficulty? difficulty,
    ExerciseBoard? board,
    ExerciseBoard? solutionBoard,
    List<ExerciseAlternative>? alternatives,
    List<ExerciseAttachment>? attachments,
    ExerciseAnswerKey? answerKey,
    String? positiveFeedback,
    String? negativeFeedback,
    bool? isActive,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      moduleId: moduleId ?? this.moduleId,
      title: title ?? this.title,
      statement: statement ?? this.statement,
      hint: hint ?? this.hint,
      subject: subject ?? this.subject,
      programmingLanguage: removeProgrammingLanguage
          ? null
          : programmingLanguage ?? this.programmingLanguage,
      author: author ?? this.author,
      order: order ?? this.order,
      type: type ?? this.type,
      difficulty: difficulty ?? this.difficulty,
      board: board ?? this.board,
      solutionBoard: solutionBoard ?? this.solutionBoard,
      alternatives: alternatives ?? this.alternatives,
      attachments: attachments ?? this.attachments,
      answerKey: answerKey ?? this.answerKey,
      positiveFeedback: positiveFeedback ?? this.positiveFeedback,
      negativeFeedback: negativeFeedback ?? this.negativeFeedback,
      isActive: isActive ?? this.isActive,
    );
  }
}