import 'package:flutter/material.dart';

import 'data/app_data.dart';
import 'models/exercise_model.dart';
import 'models/learning_module.dart';
import 'module_completed_page.dart';
import 'lesson_history_page.dart';

class ExercisePage extends StatefulWidget {
  final String moduleId;
  final int exerciseIndex;

  const ExercisePage({
    super.key,
    required this.moduleId,
    required this.exerciseIndex,
  });

  @override
  State<ExercisePage> createState() => _ExercisePageState();
}

enum FlowSymbol { decision, input, start, process }

class _ExercisePageState extends State<ExercisePage> {
  static const Color _pageBackground = Color(0xFF0A2826);
  static const Color _background = Color(0xFF123D39);
  static const Color _panel = Color(0xFF104B50);
  static const Color _green = Color(0xFF00F779);
  static const Color _darkGreen = Color(0xFF075F46);
  static const Color _white = Color(0xFFF7F7F2);

  LearningModule get _currentModule {
    final module = moduleStore.findModule(widget.moduleId);

    if (module == null) {
      throw StateError('Módulo ${widget.moduleId} não encontrado.');
    }

    return module;
  }

  List<ExerciseModel> get _activeExercises {
    final exercises = _currentModule.exercises
        .where((exercise) => exercise.isActive)
        .toList();

    exercises.sort((a, b) => a.order.compareTo(b.order));

    return exercises;
  }

  ExerciseModel get _currentExercise {
    return _activeExercises[widget.exerciseIndex];
  }

  int get _lessonNumber {
    return widget.exerciseIndex + 1;
  }

  int get _totalLessons {
    return _activeExercises.length;
  }

  double get _lessonProgress {
    if (_totalLessons == 0) {
      return 0;
    }

    return _lessonNumber / _totalLessons;
  }

  String get _lessonCounterText {
    return 'Lição $_lessonNumber de $_totalLessons';
  }

  int? _findNextIncompleteExerciseIndex() {
    return progressStore.firstIncompleteExerciseIndex(
      moduleId: widget.moduleId,
      exercises: _activeExercises,
    );
  }

  static const List<String> _allLabels = <String>[
    'Entrada',
    'Saída',
    'Decisão',
    'Processo',
    'Repetição',
    'Início',
  ];

  static const Map<FlowSymbol, Set<String>> _correctAnswers =
      <FlowSymbol, Set<String>>{
        FlowSymbol.decision: <String>{'Decisão'},
        // O paralelogramo representa operações de entrada ou de saída.
        FlowSymbol.input: <String>{'Entrada', 'Saída'},
        FlowSymbol.start: <String>{'Início'},
        FlowSymbol.process: <String>{'Processo'},
      };

  final Map<FlowSymbol, String?> _answers = <FlowSymbol, String?>{
    FlowSymbol.decision: null,
    FlowSymbol.input: null,
    FlowSymbol.start: null,
    FlowSymbol.process: null,
  };

  bool _showInstruction = false;
  bool _activityStarted = false;
  bool _showHintPopup = false;
  bool _showNegative = false;
  bool _showSuccess = false;

  @override
  void initState() {
    super.initState();

    // Aguarda o primeiro desenho da tela para que o pop-up possa surgir
    // com uma animação visível.

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() => _showInstruction = true);
    });
  }

  List<String> get _availableLabels {
    final Set<String> used = _answers.values.whereType<String>().toSet();
    return _allLabels.where((String label) => !used.contains(label)).toList();
  }

  void _startActivity() {
    setState(() {
      _activityStarted = true;
      _showInstruction = false;
    });
  }

  void _placeLabel(FlowSymbol symbol, String label) {
    setState(() {
      // Se o rótulo já estava em outro símbolo, ele é retirado de lá.
      for (final FlowSymbol key in _answers.keys) {
        if (_answers[key] == label) {
          _answers[key] = null;
        }
      }
      _answers[symbol] = label;
    });
  }

  void _removeLabel(FlowSymbol symbol) {
    setState(() => _answers[symbol] = null);
  }

  void _validateActivity() {
    final bool hasEmptyTarget = _answers.values.any(
      (String? value) => value == null,
    );

    if (hasEmptyTarget) {
      _showMessage('Arraste um rótulo para cada símbolo antes de validar.');
      return;
    }

    final bool isCorrect = _correctAnswers.entries.every((
      MapEntry<FlowSymbol, Set<String>> entry,
    ) {
      return entry.value.contains(_answers[entry.key]);
    });

    progressStore.registerAttempt(
      moduleId: widget.moduleId,
      exerciseId: _currentExercise.id,
      wasCorrect: isCorrect,
    );

    if (!isCorrect) {
      setState(() {
        _showNegative = true;
      });
      return;
    }

    setState(() {
      _showSuccess = true;
    });
  }

  void _showHint() {
    progressStore.registerHintUse(
      moduleId: widget.moduleId,
      exerciseId: _currentExercise.id,
    );

    setState(() {
      _showHintPopup = true;
    });
  }

  void _continueAfterSuccess() {
    final List<ExerciseModel> exercises = _activeExercises;

    final int? nextExerciseIndex = _findNextIncompleteExerciseIndex();

    if (nextExerciseIndex != null) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(
          builder: (BuildContext context) => ExercisePage(
            moduleId: widget.moduleId,
            exerciseIndex: nextExerciseIndex,
          ),
        ),
      );

      return;
    }

    final int completedLessons = progressStore.completedCount(
      moduleId: widget.moduleId,
      exercises: exercises,
    );

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (BuildContext completionContext) {
          return ModuleCompletedPage(
            moduleTitle: _currentModule.title,
            completedLessons: completedLessons,
            totalLessons: exercises.length,
            onReviewLessons: () {
              Navigator.of(completionContext).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) {
                    return LessonHistoryPage(moduleId: widget.moduleId);
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1800),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF173F3C),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          color: _background,
          child: Stack(
            children: <Widget>[
              SafeArea(child: _buildActivity()),
              _buildInstructionOverlay(),
              _buildHintOverlay(),
              _buildNegativeOverlay(),
              _buildSuccessOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActivity() {
    return IgnorePointer(
      ignoring:
          !_activityStarted || _showHintPopup || _showNegative || _showSuccess,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
        child: Column(
          children: <Widget>[
            _buildHeader(),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.fromLTRB(16, 22, 16, 24),
              decoration: BoxDecoration(
                color: const Color(0xFF102F2D),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: _white.withValues(alpha: 0.58)),
              ),
              child: Column(
                children: <Widget>[
                  const Text(
                    'Identifique os símbolos',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _white,
                      fontSize: 25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Arraste cada nome para o lugar correto',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _white.withValues(alpha: 0.72),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 22),
                  GridView.count(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisCount: 2,
                    mainAxisSpacing: 18,
                    crossAxisSpacing: 18,
                    childAspectRatio: 1.22,
                    children: <Widget>[
                      _buildDropTarget(FlowSymbol.decision),
                      _buildDropTarget(FlowSymbol.input),
                      _buildDropTarget(FlowSymbol.start),
                      _buildDropTarget(FlowSymbol.process),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 22),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 220),
              child: Wrap(
                key: ValueKey<String>(_availableLabels.join('|')),
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: _availableLabels
                    .map((String label) => _buildDraggableLabel(label))
                    .toList(),
              ),
            ),
            const SizedBox(height: 26),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                SizedBox(
                  width: 210,
                  child: _ActionButton(
                    text: 'Validar',
                    icon: Icons.check_circle_outline_rounded,
                    onPressed: _validateActivity,
                  ),
                ),
                const SizedBox(width: 12),
                SizedBox(
                  width: 64,
                  child: _ActionButton(
                    icon: Icons.lightbulb_outline_rounded,
                    semanticLabel: 'Mostrar dica',
                    onPressed: _showHint,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: <Widget>[
        const _SmallLogo(),
        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                _currentModule.title,
                style: const TextStyle(
                  color: _green,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                ),
              ),
              Text(
                _lessonCounterText,
                style: const TextStyle(color: _white, fontSize: 14),
              ),
            ],
          ),
        ),

        PopupMenuButton<String>(
          tooltip: 'Mais opções',
          color: const Color(0xFF173F3C),
          icon: const Icon(Icons.more_vert, color: _white, size: 32),
          onSelected: (String value) {
            if (value == 'menu') {
              Navigator.of(context).pop();
            } else {
              _showMessage(
                'Configurações da atividade serão adicionadas depois.',
              );
            }
          },
          itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(value: 'menu', child: Text('Voltar ao menu')),
            PopupMenuItem<String>(
              value: 'settings',
              child: Text('Configurações'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDropTarget(FlowSymbol symbol) {
    final String? answer = _answers[symbol];

    return DragTarget<String>(
      onWillAcceptWithDetails: (DragTargetDetails<String> details) => true,
      onAcceptWithDetails: (DragTargetDetails<String> details) {
        _placeLabel(symbol, details.data);
      },
      builder:
          (
            BuildContext context,
            List<String?> candidateData,
            List<dynamic> rejectedData,
          ) {
            final bool isHovering = candidateData.isNotEmpty;

            return Semantics(
              label: answer == null
                  ? 'Símbolo sem resposta'
                  : 'Resposta $answer',
              child: GestureDetector(
                onTap: answer == null ? null : () => _removeLabel(symbol),
                child: AnimatedScale(
                  duration: const Duration(milliseconds: 140),
                  scale: isHovering ? 1.05 : 1,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      color: isHovering
                          ? _green.withValues(alpha: 0.12)
                          : Colors.transparent,
                      border: Border.all(
                        color: isHovering ? _green : Colors.transparent,
                        width: 2,
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: Stack(
                      fit: StackFit.expand,
                      alignment: Alignment.center,
                      children: <Widget>[
                        CustomPaint(painter: _FlowShapePainter(symbol)),
                        if (answer != null)
                          Center(
                            child: Container(
                              constraints: const BoxConstraints(maxWidth: 130),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF123D39),
                                borderRadius: BorderRadius.circular(9),
                                border: Border.all(color: _white, width: 1.5),
                                boxShadow: const <BoxShadow>[
                                  BoxShadow(
                                    color: Colors.black38,
                                    blurRadius: 8,
                                    offset: Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: <Widget>[
                                  Flexible(
                                    child: Text(
                                      answer,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: _white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 3),
                                  const Icon(
                                    Icons.close,
                                    color: _white,
                                    size: 15,
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
    );
  }

  Widget _buildDraggableLabel(String label) {
    final Widget chip = _LabelChip(label: label);

    return MouseRegion(
      cursor: SystemMouseCursors.grab,
      child: Draggable<String>(
        data: label,
        feedback: Material(
          color: Colors.transparent,
          child: Transform.scale(scale: 1.06, child: chip),
        ),
        childWhenDragging: Opacity(opacity: 0.25, child: chip),
        child: chip,
      ),
    );
  }

  Widget _buildInstructionOverlay() {
    return IgnorePointer(
      ignoring: !_showInstruction,
      child: AnimatedOpacity(
        opacity: _showInstruction ? 1 : 0,
        duration: const Duration(milliseconds: 330),
        curve: Curves.easeOut,
        child: Container(
          color: Colors.black.withValues(alpha: 0.72),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: AnimatedScale(
            scale: _showInstruction ? 1 : 0.86,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            child: Container(
              width: 440,
              padding: const EdgeInsets.fromLTRB(24, 22, 24, 20),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(color: _white, width: 1.5),
                boxShadow: const <BoxShadow>[
                  BoxShadow(color: Colors.black54, blurRadius: 26),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF102F2D),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: _darkGreen),
                    ),
                    child: Text(
                      _currentModule.title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: _white,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    '$_lessonNumber. ${_currentExercise.statement}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _white,
                      fontSize: 25,
                      height: 1.25,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 180,
                    child: _ActionButton(
                      text: 'Iniciar',
                      onPressed: _startActivity,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      minHeight: 12,
                      value: _lessonProgress,
                      backgroundColor: const Color(0xFF303331),
                      valueColor: const AlwaysStoppedAnimation<Color>(_green),
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    _lessonCounterText,
                    style: const TextStyle(
                      color: _white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSuccessOverlay() {
    return IgnorePointer(
      ignoring: !_showSuccess,
      child: AnimatedOpacity(
        opacity: _showSuccess ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        child: Container(
          color: Colors.black.withValues(alpha: 0.74),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: AnimatedScale(
            scale: _showSuccess ? 1 : 0.82,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: Container(
              width: 440,
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _white, width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _green.withValues(alpha: 0.22),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  const Positioned(
                    left: 0,
                    top: 4,
                    child: Icon(Icons.eco, color: Color(0xFF87E86A), size: 38),
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 3,
                    child: Icon(Icons.eco, color: Color(0xFF87E86A), size: 38),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 106,
                        height: 106,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFF008A43),
                          border: Border.all(color: _white, width: 7),
                        ),
                        child: const Icon(Icons.check, color: _white, size: 70),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'EXCELENTE!',
                        style: TextStyle(
                          color: _white,
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Você acertou a atividade!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _ActionButton(
                              text: 'Prosseguir',
                              onPressed: _continueAfterSuccess,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              text: 'Voltar ao menu',
                              compact: true,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHintOverlay() {
    return IgnorePointer(
      ignoring: !_showHintPopup,
      child: AnimatedOpacity(
        opacity: _showHintPopup ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Container(
          color: Colors.black.withValues(alpha: 0.72),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: AnimatedScale(
            scale: _showHintPopup ? 1 : 0.84,
            duration: const Duration(milliseconds: 380),
            curve: Curves.easeOutBack,
            child: Container(
              width: 420,
              padding: const EdgeInsets.fromLTRB(28, 28, 28, 26),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _white, width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _green.withValues(alpha: 0.20),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  const Positioned(
                    left: 0,
                    top: 4,
                    child: Icon(Icons.eco, color: Color(0xFF87E86A), size: 35),
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 2,
                    child: Icon(Icons.eco, color: Color(0xFF87E86A), size: 35),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 104,
                        height: 104,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: _green,
                          border: Border.all(color: _white, width: 7),
                        ),
                        child: const Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Color(0xFF104B50),
                          size: 65,
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'DICA',
                        style: TextStyle(
                          color: _white,
                          fontSize: 34,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        _currentExercise.hint,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _white,
                          fontSize: 19,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 26),
                      SizedBox(
                        width: 210,
                        child: _ActionButton(
                          text: 'Entendi',
                          onPressed: () {
                            setState(() => _showHintPopup = false);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNegativeOverlay() {
    return IgnorePointer(
      ignoring: !_showNegative,
      child: AnimatedOpacity(
        opacity: _showNegative ? 1 : 0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        child: Container(
          color: Colors.black.withValues(alpha: 0.74),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(20),
          child: AnimatedScale(
            scale: _showNegative ? 1 : 0.82,
            duration: const Duration(milliseconds: 400),
            curve: Curves.easeOutBack,
            child: Container(
              width: 440,
              padding: const EdgeInsets.fromLTRB(28, 30, 28, 28),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _white, width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: const Color(0xFFF44336).withValues(alpha: 0.24),
                    blurRadius: 30,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Stack(
                children: <Widget>[
                  const Positioned(
                    left: 0,
                    top: 4,
                    child: Icon(Icons.eco, color: Color(0xFF9A8460), size: 38),
                  ),
                  const Positioned(
                    right: 0,
                    bottom: 3,
                    child: Icon(Icons.eco, color: Color(0xFF9A8460), size: 38),
                  ),
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Container(
                        width: 106,
                        height: 106,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFF44336),
                          border: Border.all(color: _white, width: 7),
                        ),
                        child: const Icon(
                          Icons.close_rounded,
                          color: _white,
                          size: 76,
                        ),
                      ),
                      const SizedBox(height: 22),
                      const Text(
                        'QUE PENA!',
                        style: TextStyle(
                          color: _white,
                          fontSize: 35,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Você errou a atividade!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _white,
                          fontSize: 21,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Revise a combinação dos símbolos e tente novamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: _white.withValues(alpha: 0.76),
                          fontSize: 15,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 27),
                      Row(
                        children: <Widget>[
                          Expanded(
                            child: _ActionButton(
                              text: 'Corrigir',
                              onPressed: () {
                                setState(() => _showNegative = false);
                              },
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _ActionButton(
                              text: 'Voltar ao menu',
                              compact: true,
                              onPressed: () => Navigator.of(context).pop(),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _LabelChip extends StatelessWidget {
  final String label;

  const _LabelChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 138,
      height: 55,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF104B50),
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: const Color(0xFFF7F7F2), width: 1.4),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 3)),
        ],
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Color(0xFFF7F7F2),
          fontSize: 18,
          fontWeight: FontWeight.w900,
          decoration: TextDecoration.none,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String? text;
  final IconData? icon;
  final String? semanticLabel;
  final VoidCallback onPressed;
  final bool compact;

  const _ActionButton({
    this.text,
    this.icon,
    this.semanticLabel,
    required this.onPressed,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: semanticLabel,
      button: true,
      child: Material(
        color: const Color(0xFF00F779),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onPressed,
          hoverColor: Colors.white.withValues(alpha: 0.17),
          splashColor: Colors.white.withValues(alpha: 0.28),
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 58,
            padding: EdgeInsets.symmetric(horizontal: compact ? 10 : 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF7F7F2), width: 5),
            ),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                if (icon != null) ...<Widget>[
                  Icon(icon, color: const Color(0xFF104B50), size: 28),
                  if (text != null) const SizedBox(width: 7),
                ],
                if (text != null)
                  Flexible(
                    child: Text(
                      text!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      style: TextStyle(
                        color: const Color(0xFF104B50),
                        fontSize: compact ? 16 : 22,
                        height: 1,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SmallLogo extends StatelessWidget {
  const _SmallLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF075F46),
        border: Border.all(color: const Color(0xFF00F779), width: 2),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 4,
            child: Icon(Icons.eco, color: Color(0xFF9EFF75), size: 31),
          ),
          Positioned(
            bottom: 5,
            child: Text(
              'CS',
              style: TextStyle(
                color: Color(0xFF00F779),
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FlowShapePainter extends CustomPainter {
  final FlowSymbol symbol;

  const _FlowShapePainter(this.symbol);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint fill = Paint()
      ..color = const Color(0xFF00F779)
      ..style = PaintingStyle.fill;

    final Paint border = Paint()
      ..color = const Color(0xFFF7F7F2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5
      ..strokeJoin = StrokeJoin.round;

    final Rect area = Rect.fromLTWH(10, 10, size.width - 20, size.height - 20);
    final Path path = Path();

    switch (symbol) {
      case FlowSymbol.decision:
        path
          ..moveTo(area.center.dx, area.top)
          ..lineTo(area.right, area.center.dy)
          ..lineTo(area.center.dx, area.bottom)
          ..lineTo(area.left, area.center.dy)
          ..close();
        break;
      case FlowSymbol.input:
        final double offset = area.width * 0.18;
        path
          ..moveTo(area.left + offset, area.top)
          ..lineTo(area.right, area.top)
          ..lineTo(area.right - offset, area.bottom)
          ..lineTo(area.left, area.bottom)
          ..close();
        break;
      case FlowSymbol.start:
        path.addOval(area);
        break;
      case FlowSymbol.process:
        path.addRRect(RRect.fromRectAndRadius(area, const Radius.circular(2)));
        break;
    }

    canvas
      ..drawPath(path, fill)
      ..drawPath(path, border);
  }

  @override
  bool shouldRepaint(covariant _FlowShapePainter oldDelegate) {
    return oldDelegate.symbol != symbol;
  }
}
