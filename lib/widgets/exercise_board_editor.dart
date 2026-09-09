import 'package:flutter/material.dart';

import '../data/flowchart_shape_catalog.dart';
import '../models/diagram_model.dart';
import 'flowchart_shape_widget.dart';

class ExerciseBoardEditor extends StatefulWidget {
  final List<BoardElement> initialElements;
  final ValueChanged<List<BoardElement>> onChanged;

  final double logicalWidth;
  final double logicalHeight;

  const ExerciseBoardEditor({
    super.key,
    required this.onChanged,
    this.initialElements = const <BoardElement>[],
    this.logicalWidth = 1000,
    this.logicalHeight = 700,
  });

  @override
  State<ExerciseBoardEditor> createState() =>
      _ExerciseBoardEditorState();
}

class _ExerciseBoardEditorState
    extends State<ExerciseBoardEditor> {
  static const Color _panel = Color(0xFF184B47);
  static const Color _boardColor = Color(0xFF104B50);
  static const Color _green = Color(0xFF00F779);
  static const Color _white = Color(0xFFF7F7F2);
  static const Color _border = Color(0xFF087B50);

  final GlobalKey _boardKey = GlobalKey();

  late List<BoardElement> _elements;

  String? _selectedElementId;
  int _elementCounter = 0;

  @override
  void initState() {
    super.initState();

    _elements = List<BoardElement>.from(
      widget.initialElements,
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

  void _notifyChanges() {
    widget.onChanged(
      List<BoardElement>.unmodifiable(_elements),
    );
  }

  void _addShape(
      FlowchartShapeType type,
      Offset globalPosition,
      ) {
    final BuildContext? boardContext =
        _boardKey.currentContext;

    if (boardContext == null) {
      return;
    }

    final RenderObject? renderObject =
    boardContext.findRenderObject();

    if (renderObject is! RenderBox) {
      return;
    }

    final Offset localPosition =
    renderObject.globalToLocal(globalPosition);

    final FlowchartShapeDefinition? definition =
    FlowchartShapeCatalog.findByType(type);

    if (definition == null) {
      return;
    }

    final double horizontalScale =
        widget.logicalWidth / renderObject.size.width;

    final double verticalScale =
        widget.logicalHeight / renderObject.size.height;

    final double logicalX =
        localPosition.dx * horizontalScale;

    final double logicalY =
        localPosition.dy * verticalScale;

    final double x = (logicalX -
        definition.defaultWidth / 2)
        .clamp(
      0.0,
      widget.logicalWidth -
          definition.defaultWidth,
    )
        .toDouble();

    final double y = (logicalY -
        definition.defaultHeight / 2)
        .clamp(
      0.0,
      widget.logicalHeight -
          definition.defaultHeight,
    )
        .toDouble();

    _elementCounter++;

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

    _notifyChanges();
  }

  void _moveElement(
      BoardElement element,
      DragUpdateDetails details,
      double boardWidth,
      double boardHeight,
      ) {
    final double horizontalScale =
        widget.logicalWidth / boardWidth;

    final double verticalScale =
        widget.logicalHeight / boardHeight;

    final double newX =
    (element.x + details.delta.dx * horizontalScale)
        .clamp(
      0.0,
      widget.logicalWidth - element.width,
    )
        .toDouble();

    final double newY =
    (element.y + details.delta.dy * verticalScale)
        .clamp(
      0.0,
      widget.logicalHeight - element.height,
    )
        .toDouble();

    final int index = _elements.indexWhere(
          (BoardElement currentElement) =>
      currentElement.id == element.id,
    );

    if (index == -1) {
      return;
    }

    setState(() {
      _elements[index] = element.copyWith(
        x: newX,
        y: newY,
      );

      _selectedElementId = element.id;
    });

    _notifyChanges();
  }

  void _selectElement(String elementId) {
    setState(() {
      _selectedElementId = elementId;
    });
  }

  void _removeSelectedElement() {
    final String? selectedId = _selectedElementId;

    if (selectedId == null) {
      return;
    }

    setState(() {
      _elements.removeWhere(
            (BoardElement element) =>
        element.id == selectedId,
      );

      _selectedElementId = null;
    });

    _notifyChanges();
  }

  Future<void> _editSelectedElement() async {
    final BoardElement? element = _selectedElement;

    if (element == null) {
      return;
    }

    final TextEditingController controller =
    TextEditingController(
      text: element.content,
    );

    final String? newContent =
    await showDialog<String>(
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
            style: const TextStyle(
              color: _white,
            ),
            decoration: InputDecoration(
              labelText: 'Conteúdo',
              hintText:
              'Deixe vazio para não exibir texto.',
              labelStyle: const TextStyle(
                color: _green,
              ),
              hintStyle: TextStyle(
                color: _white.withValues(
                  alpha: 0.4,
                ),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(11),
                borderSide: const BorderSide(
                  color: _border,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius:
                BorderRadius.circular(11),
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
                foregroundColor:
                const Color(0xFF104B50),
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

    if (!mounted || newContent == null) {
      return;
    }

    final int index = _elements.indexWhere(
          (BoardElement currentElement) =>
      currentElement.id == element.id,
    );

    if (index == -1) {
      return;
    }

    setState(() {
      _elements[index] = element.copyWith(
        content: newContent,
      );
    });

    _notifyChanges();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        const Row(
          children: <Widget>[
            Icon(
              Icons.widgets_outlined,
              color: _green,
              size: 25,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Biblioteca de formas',
                style: TextStyle(
                  color: _white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'Arraste uma forma da biblioteca para o quadro.',
          style: TextStyle(
            color: _white.withValues(alpha: 0.68),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 15),
        _buildShapeLibrary(),
        const SizedBox(height: 24),
        const Row(
          children: <Widget>[
            Icon(
              Icons.account_tree_outlined,
              color: _green,
              size: 25,
            ),
            SizedBox(width: 9),
            Expanded(
              child: Text(
                'Quadro da atividade',
                style: TextStyle(
                  color: _white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          'Depois de inserir uma forma, arraste-a para alterar sua posição.',
          style: TextStyle(
            color: _white.withValues(alpha: 0.68),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 15),
        _buildBoard(),
        if (_selectedElement != null) ...<Widget>[
          const SizedBox(height: 13),
          _buildSelectedElementTools(),
        ],
      ],
    );
  }

  Widget _buildShapeLibrary() {
    return SizedBox(
      height: 154,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: FlowchartShapeCatalog.all.length,
        separatorBuilder: (
            BuildContext context,
            int index,
            ) {
          return const SizedBox(width: 12);
        },
        itemBuilder: (
            BuildContext context,
            int index,
            ) {
          final FlowchartShapeDefinition definition =
          FlowchartShapeCatalog.all[index];

          return _buildDraggableLibraryItem(
            definition,
          );
        },
      ),
    );
  }

  Widget _buildDraggableLibraryItem(
      FlowchartShapeDefinition definition,
      ) {
    final Widget card = Container(
      width: 132,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _border,
        ),
      ),
      child: Column(
        children: <Widget>[
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(7),
              child: FlowchartShapeWidget(
                type: definition.type,
              ),
            ),
          ),
          const SizedBox(height: 7),
          Text(
            definition.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _white,
              fontSize: 12,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );

    return Tooltip(
      message: definition.description,
      child: Draggable<FlowchartShapeType>(
        data: definition.type,
        dragAnchorStrategy:
        pointerDragAnchorStrategy,
        feedback: Material(
          color: Colors.transparent,
          child: SizedBox(
            width: 135,
            height: 90,
            child: FlowchartShapeWidget(
              type: definition.type,
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.35,
          child: card,
        ),
        child: card,
      ),
    );
  }

  Widget _buildBoard() {
    return LayoutBuilder(
      builder: (
          BuildContext context,
          BoxConstraints constraints,
          ) {
        final double boardWidth =
            constraints.maxWidth;

        final double boardHeight =
        (boardWidth * 0.7)
            .clamp(280.0, 420.0)
            .toDouble();

        return DragTarget<FlowchartShapeType>(
          onWillAcceptWithDetails: (
              DragTargetDetails<FlowchartShapeType>
              details,
              ) {
            return true;
          },
          onAcceptWithDetails: (
              DragTargetDetails<FlowchartShapeType>
              details,
              ) {
            _addShape(
              details.data,
              details.offset,
            );
          },
          builder: (
              BuildContext context,
              List<FlowchartShapeType?>
              candidateData,
              List<dynamic> rejectedData,
              ) {
            final bool receivingShape =
                candidateData.isNotEmpty;

            return AnimatedContainer(
              key: _boardKey,
              duration:
              const Duration(milliseconds: 180),
              width: boardWidth,
              height: boardHeight,
              decoration: BoxDecoration(
                color: _boardColor,
                borderRadius:
                BorderRadius.circular(14),
                border: Border.all(
                  color: receivingShape
                      ? _green
                      : _white.withValues(
                    alpha: 0.72,
                  ),
                  width: receivingShape ? 3 : 1.5,
                ),
                boxShadow: receivingShape
                    ? <BoxShadow>[
                  BoxShadow(
                    color: _green.withValues(
                      alpha: 0.22,
                    ),
                    blurRadius: 18,
                  ),
                ]
                    : null,
              ),
              child: ClipRRect(
                borderRadius:
                BorderRadius.circular(12),
                child: Stack(
                  children: <Widget>[
                    if (_elements.isEmpty)
                      Center(
                        child: IgnorePointer(
                          child: Column(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: <Widget>[
                              Icon(
                                Icons
                                    .open_with_rounded,
                                color:
                                _white.withValues(
                                  alpha: 0.44,
                                ),
                                size: 52,
                              ),
                              const SizedBox(
                                height: 12,
                              ),
                              Text(
                                'Arraste as formas para cá',
                                style: TextStyle(
                                  color:
                                  _white.withValues(
                                    alpha: 0.54,
                                  ),
                                  fontSize: 15,
                                  fontWeight:
                                  FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    for (
                    final BoardElement element
                    in _elements
                    )
                      _buildBoardElement(
                        element: element,
                        boardWidth: boardWidth,
                        boardHeight: boardHeight,
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
            element,
            details,
            boardWidth,
            boardHeight,
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

  Widget _buildSelectedElementTools() {
    final BoardElement? element = _selectedElement;

    if (element == null ||
        element.shapeType == null) {
      return const SizedBox.shrink();
    }

    final FlowchartShapeDefinition? definition =
    FlowchartShapeCatalog.findByType(
      element.shapeType!,
    );

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 15,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _green.withValues(alpha: 0.55),
        ),
      ),
      child: Row(
        children: <Widget>[
          const Icon(
            Icons.check_circle_outline_rounded,
            color: _green,
          ),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
              definition?.name ?? 'Forma selecionada',
              style: const TextStyle(
                color: _white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Editar texto',
            onPressed: _editSelectedElement,
            icon: const Icon(
              Icons.edit_rounded,
              color: _white,
            ),
          ),
          IconButton(
            tooltip: 'Excluir forma',
            onPressed: _removeSelectedElement,
            icon: const Icon(
              Icons.delete_outline_rounded,
              color: Color(0xFFFF7777),
            ),
          ),
        ],
      ),
    );
  }
}