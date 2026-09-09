import 'package:flutter/material.dart';

import '../data/flowchart_shape_catalog.dart';
import '../models/diagram_model.dart';
import '../models/exercise_model.dart';

typedef ExerciseAnswerChanged = void Function(
    List<ExerciseAlternative> alternatives,
    Map<String, String> placements,
    );

class ExerciseAnswerEditor extends StatefulWidget {
  final List<BoardElement> boardElements;
  final List<ExerciseAlternative> initialAlternatives;
  final Map<String, String> initialPlacements;
  final ExerciseAnswerChanged onChanged;

  const ExerciseAnswerEditor({
    super.key,
    required this.boardElements,
    required this.onChanged,
    this.initialAlternatives = const <ExerciseAlternative>[],
    this.initialPlacements = const <String, String>{},
  });

  @override
  State<ExerciseAnswerEditor> createState() =>
      _ExerciseAnswerEditorState();
}

class _ExerciseAnswerEditorState
    extends State<ExerciseAnswerEditor> {
  static const Color _background = Color(0xFF104B50);
  static const Color _panel = Color(0xFF184B47);
  static const Color _green = Color(0xFF00F779);
  static const Color _white = Color(0xFFF7F7F2);
  static const Color _border = Color(0xFF087B50);
  static const Color _error = Color(0xFFFF6B6B);

  final TextEditingController _alternativeController =
  TextEditingController();

  final FocusNode _alternativeFocusNode = FocusNode();

  late List<ExerciseAlternative> _alternatives;
  late Map<String, String> _placements;

  @override
  void initState() {
    super.initState();

    _alternatives = List<ExerciseAlternative>.from(
      widget.initialAlternatives,
    );

    _placements = Map<String, String>.from(
      widget.initialPlacements,
    );
  }

  @override
  void didUpdateWidget(
      covariant ExerciseAnswerEditor oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    final Set<String> validTargetIds = _targets
        .map((BoardElement element) => element.id)
        .toSet();

    final Set<String> validAlternativeIds = _alternatives
        .map((ExerciseAlternative alternative) => alternative.id)
        .toSet();

    final int previousLength = _placements.length;

    _placements.removeWhere(
          (String targetId, String alternativeId) {
        return !validTargetIds.contains(targetId) ||
            !validAlternativeIds.contains(alternativeId);
      },
    );

    if (previousLength != _placements.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _emitChanges();
        }
      });
    }
  }

  @override
  void dispose() {
    _alternativeController.dispose();
    _alternativeFocusNode.dispose();

    super.dispose();
  }

  List<BoardElement> get _targets {
    return widget.boardElements.where(
          (BoardElement element) {
        return element.type ==
            BoardElementType.flowchartShape;
      },
    ).toList();
  }

  void _addAlternative() {
    final String label =
    _alternativeController.text.trim();

    if (label.isEmpty) {
      _showMessage(
        'Digite o texto da alternativa.',
        isError: true,
      );
      return;
    }

    final bool alreadyExists = _alternatives.any(
          (ExerciseAlternative alternative) {
        return alternative.label.trim().toLowerCase() ==
            label.toLowerCase();
      },
    );

    if (alreadyExists) {
      _showMessage(
        'Essa alternativa já foi adicionada.',
        isError: true,
      );
      return;
    }

    final ExerciseAlternative newAlternative =
    ExerciseAlternative(
      id:
      'alternative-${DateTime.now().microsecondsSinceEpoch}',
      label: label,
    );

    setState(() {
      _alternatives.add(newAlternative);
      _alternativeController.clear();
    });

    _emitChanges();
    _alternativeFocusNode.requestFocus();
  }

  void _removeAlternative(String alternativeId) {
    setState(() {
      _alternatives.removeWhere(
            (ExerciseAlternative alternative) {
          return alternative.id == alternativeId;
        },
      );

      _placements.removeWhere(
            (String targetId, String answerId) {
          return answerId == alternativeId;
        },
      );
    });

    _emitChanges();
  }

  void _setPlacement({
    required String targetId,
    required String? alternativeId,
  }) {
    setState(() {
      if (alternativeId == null) {
        _placements.remove(targetId);
      } else {
        _placements[targetId] = alternativeId;
      }
    });

    _emitChanges();
  }

  void _emitChanges() {
    widget.onChanged(
      List<ExerciseAlternative>.unmodifiable(
        _alternatives,
      ),
      Map<String, String>.unmodifiable(
        _placements,
      ),
    );
  }

  void _showMessage(
      String message, {
        bool isError = false,
      }) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          backgroundColor: isError
              ? const Color(0xFF8C2E2A)
              : const Color(0xFF173F3C),
        ),
      );
  }

  String _targetLabel(
      BoardElement element,
      int index,
      ) {
    if (element.content.trim().isNotEmpty) {
      return element.content.trim();
    }

    if (element.shapeType != null) {
      final String? shapeName =
          FlowchartShapeCatalog.findByType(
            element.shapeType!,
          )?.name;

      if (shapeName != null) {
        return 'Forma ${index + 1} — $shapeName';
      }
    }

    return 'Elemento ${index + 1}';
  }

  @override
  Widget build(BuildContext context) {
    final List<BoardElement> targets = _targets;

    final int answeredTargets = targets.where(
          (BoardElement element) {
        return _placements.containsKey(element.id);
      },
    ).length;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: _border,
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Row(
            children: <Widget>[
              Icon(
                Icons.rule_folder_outlined,
                color: _green,
                size: 26,
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Alternativas e gabarito',
                  style: TextStyle(
                    color: _white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 7),
          Text(
            'Cadastre as respostas disponíveis e indique '
                'qual delas pertence a cada forma.',
            style: TextStyle(
              color: _white.withValues(alpha: 0.68),
              height: 1.35,
            ),
          ),
          const SizedBox(height: 20),
          _buildAlternativeInput(),
          const SizedBox(height: 18),
          _buildAlternativeList(),
          const SizedBox(height: 25),
          const Divider(
            color: _border,
            height: 1,
          ),
          const SizedBox(height: 22),
          Row(
            children: <Widget>[
              const Expanded(
                child: Text(
                  'Gabarito das formas',
                  style: TextStyle(
                    color: _white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              _AnswerCounter(
                answered: answeredTargets,
                total: targets.length,
              ),
            ],
          ),
          const SizedBox(height: 15),
          if (targets.isEmpty)
            _buildEmptyTargets()
          else
            ...List<Widget>.generate(
              targets.length,
                  (int index) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom:
                    index == targets.length - 1 ? 0 : 14,
                  ),
                  child: _buildTargetAnswer(
                    element: targets[index],
                    index: index,
                  ),
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildAlternativeInput() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _alternativeController,
            focusNode: _alternativeFocusNode,
            style: const TextStyle(
              color: _white,
              fontWeight: FontWeight.w700,
            ),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              _addAlternative();
            },
            decoration: InputDecoration(
              labelText: 'Nova alternativa',
              hintText: 'Exemplo: Decisão',
              labelStyle: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w800,
              ),
              hintStyle: TextStyle(
                color: _white.withValues(alpha: 0.38),
              ),
              filled: true,
              fillColor: _background,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 15,
                vertical: 16,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: _border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: _green,
                  width: 2,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 11),
        SizedBox(
          height: 58,
          child: FilledButton(
            onPressed: _addAlternative,
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor:
              const Color(0xFF104B50),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(11),
              ),
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 29,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlternativeList() {
    if (_alternatives.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.circular(11),
          border: Border.all(color: _border),
        ),
        child: Text(
          'Nenhuma alternativa cadastrada.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: _white.withValues(alpha: 0.58),
            fontWeight: FontWeight.w700,
          ),
        ),
      );
    }

    return Wrap(
      spacing: 9,
      runSpacing: 9,
      children: _alternatives.map(
            (ExerciseAlternative alternative) {
          return Container(
            padding: const EdgeInsets.only(
              left: 13,
              top: 4,
              bottom: 4,
              right: 4,
            ),
            decoration: BoxDecoration(
              color: _background,
              borderRadius: BorderRadius.circular(99),
              border: Border.all(color: _green),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  alternative.label,
                  style: const TextStyle(
                    color: _white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: 3),
                IconButton(
                  onPressed: () {
                    _removeAlternative(alternative.id);
                  },
                  tooltip: 'Excluir alternativa',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.close_rounded,
                    color: _error,
                    size: 20,
                  ),
                ),
              ],
            ),
          );
        },
      ).toList(),
    );
  }

  Widget _buildTargetAnswer({
    required BoardElement element,
    required int index,
  }) {
    final String? selectedAlternativeId =
    _placements[element.id];

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(
          color: selectedAlternativeId == null
              ? _border
              : _green,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Text(
            _targetLabel(element, index),
            style: const TextStyle(
              color: _white,
              fontSize: 15,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 11),
          DropdownButtonFormField<String>(
            key: ValueKey<String>(
              '${element.id}-$selectedAlternativeId-'
                  '${_alternatives.length}',
            ),
            initialValue: selectedAlternativeId,
            isExpanded: true,
            dropdownColor: _panel,
            style: const TextStyle(
              color: _white,
              fontWeight: FontWeight.w700,
            ),
            decoration: InputDecoration(
              labelText: 'Resposta correta',
              hintText: _alternatives.isEmpty
                  ? 'Cadastre uma alternativa'
                  : 'Selecione a resposta',
              labelStyle: const TextStyle(
                color: _green,
                fontWeight: FontWeight.w800,
              ),
              hintStyle: TextStyle(
                color: _white.withValues(alpha: 0.42),
              ),
              filled: true,
              fillColor: _panel,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 13,
                vertical: 13,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: _border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(9),
                borderSide: const BorderSide(
                  color: _green,
                  width: 2,
                ),
              ),
            ),
            items: _alternatives.map(
                  (ExerciseAlternative alternative) {
                return DropdownMenuItem<String>(
                  value: alternative.id,
                  child: Text(
                    alternative.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              },
            ).toList(),
            onChanged: _alternatives.isEmpty
                ? null
                : (String? alternativeId) {
              _setPlacement(
                targetId: element.id,
                alternativeId: alternativeId,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyTargets() {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(11),
        border: Border.all(color: _border),
      ),
      child: const Column(
        children: <Widget>[
          Icon(
            Icons.account_tree_outlined,
            color: _green,
            size: 34,
          ),
          SizedBox(height: 9),
          Text(
            'Adicione formas ao quadro para configurar '
                'o gabarito.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerCounter extends StatelessWidget {
  final int answered;
  final int total;

  const _AnswerCounter({
    required this.answered,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final bool completed =
        total > 0 && answered == total;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 11,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: completed
            ? const Color(0xFF00F779)
            : const Color(0xFF104B50),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(
          color: const Color(0xFF00F779),
        ),
      ),
      child: Text(
        '$answered de $total',
        style: TextStyle(
          color: completed
              ? const Color(0xFF104B50)
              : const Color(0xFFF7F7F2),
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}