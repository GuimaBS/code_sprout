import 'package:flutter/material.dart';

import 'data/flowchart_shape_catalog.dart';
import 'models/diagram_model.dart';
import 'models/exercise_model.dart';
import 'widgets/exercise_answer_editor.dart';
import 'widgets/flowchart_shape_widget.dart';

class ExerciseBoardWorkspaceResult {
  final List<BoardElement> elements;
  final List<ExerciseAlternative> alternatives;
  final Map<String, String> placements;

  ExerciseBoardWorkspaceResult({
    required List<BoardElement> elements,
    required List<ExerciseAlternative> alternatives,
    required Map<String, String> placements,
  })  : elements = List<BoardElement>.unmodifiable(elements),
        alternatives =
        List<ExerciseAlternative>.unmodifiable(alternatives),
        placements = Map<String, String>.unmodifiable(placements);
}

class ExerciseBoardWorkspacePage extends StatefulWidget {
  final List<BoardElement> initialElements;
  final List<ExerciseAlternative> initialAlternatives;
  final Map<String, String> initialPlacements;

  final double logicalWidth;
  final double logicalHeight;

  const ExerciseBoardWorkspacePage({
    super.key,
    this.initialElements = const <BoardElement>[],
    this.initialAlternatives =
    const <ExerciseAlternative>[],
    this.initialPlacements = const <String, String>{},
    this.logicalWidth = 1000,
    this.logicalHeight = 700,
  });

  @override
  State<ExerciseBoardWorkspacePage> createState() =>
      _ExerciseBoardWorkspacePageState();
}

class _ExerciseBoardWorkspacePageState
    extends State<ExerciseBoardWorkspacePage> {
  static const Color _pageBackground = Color(0xFF0A2826);
  static const Color _header = Color(0xFF102F2D);
  static const Color _panel = Color(0xFF184B47);
  static const Color _boardColor = Color(0xFF104B50);
  static const Color _green = Color(0xFF00F779);
  static const Color _white = Color(0xFFF7F7F2);
  static const Color _border = Color(0xFF087B50);

  late List<BoardElement> _elements;
  late List<ExerciseAlternative> _alternatives;
  late Map<String, String> _placements;

  String? _selectedElementId;
  int _elementCounter = 0;

  @override
  void initState() {
    super.initState();

    _elements = List<BoardElement>.from(
      widget.initialElements,
    );

    _alternatives = List<ExerciseAlternative>.from(
      widget.initialAlternatives,
    );

    _placements = Map<String, String>.from(
      widget.initialPlacements,
    );
  }

  BoardElement? get _selectedElement {
    for (final BoardElement element in _elements) {
      if (element.id == _selectedElementId) {
        return element;
      }
    }

    return null;
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

  void _addShape(FlowchartShapeType type) {
    final FlowchartShapeDefinition? definition =
    FlowchartShapeCatalog.findByType(type);

    if (definition == null) {
      return;
    }

    _elementCounter++;

    final double variation =
        ((_elementCounter - 1) % 5) * 22;

    final double x = (
        (widget.logicalWidth - definition.defaultWidth) / 2 +
            variation
    ).clamp(
      0.0,
      widget.logicalWidth - definition.defaultWidth,
    ).toDouble();

    final double y = (
        (widget.logicalHeight - definition.defaultHeight) / 2 +
            variation
    ).clamp(
      0.0,
      widget.logicalHeight - definition.defaultHeight,
    ).toDouble();

    final BoardElement newElement =
    FlowchartShapeCatalog.createElement(
      id:
      'element-${DateTime.now().microsecondsSinceEpoch}-$_elementCounter',
      type: type,
      x: x,
      y: y,
      acceptsDrop: true,
    );

    setState(() {
      _elements.add(newElement);
      _selectedElementId = newElement.id;
    });
  }

  void _selectElement(String? elementId) {
    setState(() {
      _selectedElementId = elementId;
    });
  }

  void _moveElement({
    required String elementId,
    required DragUpdateDetails details,
    required double boardWidth,
    required double boardHeight,
  }) {
    final int index = _elements.indexWhere(
          (BoardElement element) => element.id == elementId,
    );

    if (index == -1) {
      return;
    }

    final BoardElement currentElement = _elements[index];

    final double horizontalScale =
        widget.logicalWidth / boardWidth;

    final double verticalScale =
        widget.logicalHeight / boardHeight;

    final double newX = (
        currentElement.x +
            details.delta.dx * horizontalScale
    ).clamp(
      0.0,
      widget.logicalWidth - currentElement.width,
    ).toDouble();

    final double newY = (
        currentElement.y +
            details.delta.dy * verticalScale
    ).clamp(
      0.0,
      widget.logicalHeight - currentElement.height,
    ).toDouble();

    setState(() {
      _elements[index] = currentElement.copyWith(
        x: newX,
        y: newY,
      );

      _selectedElementId = currentElement.id;
    });
  }

  void _removeSelectedElement() {
    final String? selectedId = _selectedElementId;

    if (selectedId == null) {
      _showMessage(
        'Selecione uma forma antes de excluir.',
        isError: true,
      );
      return;
    }

    setState(() {
      _elements.removeWhere(
            (BoardElement element) =>
        element.id == selectedId,
      );

      _placements.remove(selectedId);
      _selectedElementId = null;
    });
  }

  Future<void> _editSelectedElement() async {
    final BoardElement? element = _selectedElement;

    if (element == null) {
      _showMessage(
        'Selecione uma forma antes de editar.',
        isError: true,
      );
      return;
    }

    final TextEditingController controller =
    TextEditingController(
      text: element.content,
    );

    final String? content = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _panel,
          title: const Text(
            'Texto da forma',
            style: TextStyle(
              color: _white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            maxLines: 3,
            style: const TextStyle(color: _white),
            decoration: InputDecoration(
              labelText: 'Conteúdo',
              hintText:
              'Deixe vazio para não exibir texto.',
              labelStyle: const TextStyle(
                color: _green,
              ),
              hintStyle: TextStyle(
                color: _white.withValues(alpha: 0.4),
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
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text(
                'Cancelar',
                style: TextStyle(color: _white),
              ),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: _green,
                foregroundColor: _boardColor,
              ),
              onPressed: () {
                Navigator.of(dialogContext).pop(
                  controller.text.trim(),
                );
              },
              child: const Text(
                'Aplicar',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (!mounted || content == null) {
      return;
    }

    final int index = _elements.indexWhere(
          (BoardElement currentElement) {
        return currentElement.id == element.id;
      },
    );

    if (index == -1) {
      return;
    }

    setState(() {
      _elements[index] = element.copyWith(
        content: content,
      );
    });
  }

  Future<void> _showShapePicker() async {
    final TextEditingController searchController =
    TextEditingController();

    final FlowchartShapeType? selectedType =
    await showModalBottomSheet<FlowchartShapeType>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return StatefulBuilder(
          builder: (
              BuildContext context,
              StateSetter setSheetState,
              ) {
            final String query =
            searchController.text.trim().toLowerCase();

            final List<FlowchartShapeDefinition>
            filteredShapes =
            FlowchartShapeCatalog.all.where(
                  (FlowchartShapeDefinition definition) {
                if (query.isEmpty) {
                  return true;
                }

                return definition.name
                    .toLowerCase()
                    .contains(query) ||
                    definition.description
                        .toLowerCase()
                        .contains(query);
              },
            ).toList();

            return FractionallySizedBox(
              heightFactor: 0.88,
              child: Container(
                decoration: const BoxDecoration(
                  color: _panel,
                  borderRadius: BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                ),
                child: SafeArea(
                  top: false,
                  child: Column(
                    children: <Widget>[
                      Container(
                        width: 46,
                        height: 5,
                        margin:
                        const EdgeInsets.only(top: 11),
                        decoration: BoxDecoration(
                          color: _white.withValues(
                            alpha: 0.35,
                          ),
                          borderRadius:
                          BorderRadius.circular(99),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(
                          18,
                          15,
                          18,
                          12,
                        ),
                        child: Row(
                          children: <Widget>[
                            const Expanded(
                              child: Text(
                                'Escolher forma',
                                style: TextStyle(
                                  color: _white,
                                  fontSize: 22,
                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () {
                                Navigator.of(sheetContext)
                                    .pop();
                              },
                              icon: const Icon(
                                Icons.close_rounded,
                                color: _white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 18,
                        ),
                        child: TextField(
                          controller: searchController,
                          style: const TextStyle(
                            color: _white,
                          ),
                          onChanged: (_) {
                            setSheetState(() {});
                          },
                          decoration: InputDecoration(
                            hintText:
                            'Pesquisar símbolo...',
                            prefixIcon: const Icon(
                              Icons.search_rounded,
                              color: _green,
                            ),
                            suffixIcon:
                            searchController.text.isEmpty
                                ? null
                                : IconButton(
                              onPressed: () {
                                searchController
                                    .clear();

                                setSheetState(
                                      () {},
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .close_rounded,
                                color: _white,
                              ),
                            ),
                            hintStyle: TextStyle(
                              color: _white.withValues(
                                alpha: 0.45,
                              ),
                            ),
                            filled: true,
                            fillColor: _boardColor,
                            enabledBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(
                                color: _border,
                              ),
                            ),
                            focusedBorder:
                            OutlineInputBorder(
                              borderRadius:
                              BorderRadius.circular(12),
                              borderSide:
                              const BorderSide(
                                color: _green,
                                width: 2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Expanded(
                        child: filteredShapes.isEmpty
                            ? const Center(
                          child: Text(
                            'Nenhuma forma encontrada.',
                            style: TextStyle(
                              color: _white,
                              fontWeight:
                              FontWeight.w700,
                            ),
                          ),
                        )
                            : ListView.separated(
                          padding:
                          const EdgeInsets.fromLTRB(
                            18,
                            4,
                            18,
                            24,
                          ),
                          itemCount:
                          filteredShapes.length,
                          separatorBuilder: (
                              BuildContext context,
                              int index,
                              ) {
                            return const SizedBox(
                              height: 9,
                            );
                          },
                          itemBuilder: (
                              BuildContext context,
                              int index,
                              ) {
                            final definition =
                            filteredShapes[index];

                            return Material(
                              color: _boardColor,
                              borderRadius:
                              BorderRadius.circular(
                                12,
                              ),
                              child: InkWell(
                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                                onTap: () {
                                  Navigator.of(
                                    sheetContext,
                                  ).pop(
                                    definition.type,
                                  );
                                },
                                child: Padding(
                                  padding:
                                  const EdgeInsets
                                      .symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  child: Row(
                                    children: <Widget>[
                                      SizedBox(
                                        width: 66,
                                        height: 48,
                                        child:
                                        FlowchartShapeWidget(
                                          type:
                                          definition
                                              .type,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 13,
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment
                                              .start,
                                          children: <Widget>[
                                            Text(
                                              definition
                                                  .name,
                                              style:
                                              const TextStyle(
                                                color:
                                                _white,
                                                fontSize:
                                                15,
                                                fontWeight:
                                                FontWeight
                                                    .w900,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              definition
                                                  .description,
                                              style:
                                              TextStyle(
                                                color: _white
                                                    .withValues(
                                                  alpha:
                                                  0.62,
                                                ),
                                                fontSize:
                                                12,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      const Icon(
                                        Icons
                                            .add_circle_outline_rounded,
                                        color: _green,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    searchController.dispose();

    if (!mounted || selectedType == null) {
      return;
    }

    _addShape(selectedType);
  }

  Future<void> _showAlternativesEditor() async {
    List<ExerciseAlternative> temporaryAlternatives =
    List<ExerciseAlternative>.from(_alternatives);

    Map<String, String> temporaryPlacements =
    Map<String, String>.from(_placements);

    final bool? applyChanges =
    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return FractionallySizedBox(
          heightFactor: 0.92,
          child: Container(
            decoration: const BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(24),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      17,
                      10,
                      10,
                    ),
                    child: Row(
                      children: <Widget>[
                        const Expanded(
                          child: Text(
                            'Alternativas e gabarito',
                            style: TextStyle(
                              color: _white,
                              fontSize: 21,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            Navigator.of(sheetContext)
                                .pop(false);
                          },
                          icon: const Icon(
                            Icons.close_rounded,
                            color: _white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        8,
                        18,
                        18,
                      ),
                      child: ExerciseAnswerEditor(
                        boardElements: _elements,
                        initialAlternatives:
                        temporaryAlternatives,
                        initialPlacements:
                        temporaryPlacements,
                        onChanged: (
                            List<ExerciseAlternative>
                            alternatives,
                            Map<String, String> placements,
                            ) {
                          temporaryAlternatives =
                          List<ExerciseAlternative>.from(
                            alternatives,
                          );

                          temporaryPlacements =
                          Map<String, String>.from(
                            placements,
                          );
                        },
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.fromLTRB(
                      18,
                      12,
                      18,
                      16,
                    ),
                    decoration: const BoxDecoration(
                      color: _header,
                      border: Border(
                        top: BorderSide(color: _border),
                      ),
                    ),
                    child: Row(
                      children: <Widget>[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.of(sheetContext)
                                  .pop(false);
                            },
                            child: const Text('Cancelar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton(
                            style: FilledButton.styleFrom(
                              backgroundColor: _green,
                              foregroundColor: _boardColor,
                            ),
                            onPressed: () {
                              Navigator.of(sheetContext)
                                  .pop(true);
                            },
                            child: const Text(
                              'Aplicar',
                              style: TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || applyChanges != true) {
      return;
    }

    setState(() {
      _alternatives = temporaryAlternatives;
      _placements = temporaryPlacements;
    });
  }

  void _finishEditing() {
    if (_elements.isEmpty) {
      _showMessage(
        'Adicione pelo menos uma forma ao quadro.',
        isError: true,
      );
      return;
    }

    final List<BoardElement> targets = _elements.where(
          (BoardElement element) {
        return element.type ==
            BoardElementType.flowchartShape;
      },
    ).toList();

    if (_alternatives.isEmpty) {
      _showMessage(
        'Configure as alternativas da atividade.',
        isError: true,
      );
      return;
    }

    final bool incompleteAnswerKey = targets.any(
          (BoardElement element) {
        return !_placements.containsKey(element.id);
      },
    );

    if (incompleteAnswerKey) {
      _showMessage(
        'Defina a resposta correta para todas as formas.',
        isError: true,
      );
      return;
    }

    Navigator.of(context).pop(
      ExerciseBoardWorkspaceResult(
        elements: _elements,
        alternatives: _alternatives,
        placements: _placements,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: SafeArea(
        child: Column(
          children: <Widget>[
            _buildHeader(),
            Expanded(
              child: Row(
                children: <Widget>[
                  _buildToolRail(),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: LayoutBuilder(
                        builder: (
                            BuildContext context,
                            BoxConstraints constraints,
                            ) {
                          return _buildBoard(
                            boardWidth:
                            constraints.maxWidth,
                            boardHeight:
                            constraints.maxHeight,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 72,
      padding: const EdgeInsets.symmetric(horizontal: 8),
      decoration: const BoxDecoration(
        color: _header,
        border: Border(
          bottom: BorderSide(
            color: _border,
            width: 1.5,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          IconButton(
            tooltip: 'Cancelar edição',
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: const Icon(
              Icons.arrow_back_rounded,
              color: _white,
            ),
          ),
          const SizedBox(width: 4),
          const Expanded(
            child: Text(
              'Editor do quadro',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: _white,
                fontSize: 20,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: _green,
              foregroundColor: _boardColor,
            ),
            onPressed: _finishEditing,
            icon: const Icon(Icons.check_rounded),
            label: const Text(
              'Concluir',
              style: TextStyle(
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolRail() {
    return Container(
      width: 78,
      color: _header,
      padding: const EdgeInsets.symmetric(
        horizontal: 7,
        vertical: 11,
      ),
      child: Column(
        children: <Widget>[
          _WorkspaceToolButton(
            icon: Icons.category_outlined,
            label: 'Formas',
            onTap: _showShapePicker,
          ),
          const SizedBox(height: 10),
          _WorkspaceToolButton(
            icon: Icons.rule_folder_outlined,
            label: 'Respostas',
            badge: _alternatives.length,
            onTap: _showAlternativesEditor,
          ),
          const SizedBox(height: 10),
          _WorkspaceToolButton(
            icon: Icons.edit_outlined,
            label: 'Texto',
            enabled: _selectedElement != null,
            onTap: _editSelectedElement,
          ),
          const SizedBox(height: 10),
          _WorkspaceToolButton(
            icon: Icons.delete_outline_rounded,
            label: 'Excluir',
            enabled: _selectedElement != null,
            destructive: true,
            onTap: _removeSelectedElement,
          ),
          const Spacer(),
          Text(
            '${_elements.length}',
            style: const TextStyle(
              color: _green,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            _elements.length == 1
                ? 'forma'
                : 'formas',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white.withValues(alpha: 0.6),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBoard({
    required double boardWidth,
    required double boardHeight,
  }) {
    return GestureDetector(
      onTap: () {
        _selectElement(null);
      },
      child: Container(
        width: boardWidth,
        height: boardHeight,
        decoration: BoxDecoration(
          color: _boardColor,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: _white.withValues(alpha: 0.7),
            width: 1.5,
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(13),
          child: Stack(
            children: <Widget>[
              if (_elements.isEmpty)
                Center(
                  child: IgnorePointer(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(
                          Icons.touch_app_outlined,
                          color: _white.withValues(alpha: 0.45),
                          size: 48,
                        ),
                        const SizedBox(height: 11),
                        Text(
                          'Use o botão Formas para começar',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color:
                            _white.withValues(alpha: 0.58),
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              for (final BoardElement element in _elements)
                _buildBoardElement(
                  element: element,
                  boardWidth: boardWidth,
                  boardHeight: boardHeight,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBoardElement({
    required BoardElement element,
    required double boardWidth,
    required double boardHeight,
  }) {
    if (element.shapeType == null) {
      return const SizedBox.shrink();
    }

    final double horizontalScale =
        boardWidth / widget.logicalWidth;

    final double verticalScale =
        boardHeight / widget.logicalHeight;

    return Positioned(
      left: element.x * horizontalScale,
      top: element.y * verticalScale,
      width: element.width * horizontalScale,
      height: element.height * verticalScale,
      child: GestureDetector(
        onTap: () {
          _selectElement(element.id);
        },
        onPanStart: (_) {
          _selectElement(element.id);
        },
        onPanUpdate: (DragUpdateDetails details) {
          _moveElement(
            elementId: element.id,
            details: details,
            boardWidth: boardWidth,
            boardHeight: boardHeight,
          );
        },
        child: FlowchartShapeWidget(
          type: element.shapeType!,
          label: element.content.isEmpty
              ? null
              : element.content,
          selected:
          element.id == _selectedElementId,
        ),
      ),
    );
  }
}

class _WorkspaceToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool enabled;
  final bool destructive;
  final int? badge;

  const _WorkspaceToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
    this.enabled = true,
    this.destructive = false,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    const Color green = Color(0xFF00F779);
    const Color white = Color(0xFFF7F7F2);
    const Color panel = Color(0xFF184B47);
    const Color error = Color(0xFFFF7777);

    final Color foregroundColor = !enabled
        ? white.withValues(alpha: 0.28)
        : destructive
        ? error
        : green;

    return Material(
      color: enabled
          ? panel
          : panel.withValues(alpha: 0.45),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 64,
          height: 68,
          child: Stack(
            children: <Widget>[
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      icon,
                      color: foregroundColor,
                      size: 25,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: foregroundColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              if (badge != null && badge! > 0)
                Positioned(
                  top: 5,
                  right: 5,
                  child: Container(
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 4,
                    ),
                    decoration: BoxDecoration(
                      color: green,
                      borderRadius: BorderRadius.circular(99),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '$badge',
                      style: const TextStyle(
                        color: Color(0xFF104B50),
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}