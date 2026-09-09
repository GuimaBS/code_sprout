enum FlowchartShapeType {
  startEnd,
  process,
  decision,
  inputOutput,
  predefinedProcess,
  document,
  multipleDocuments,
  database,
  storedData,
  manualInput,
  manualOperation,
  preparation,
  connector,
  offPageConnector,
  delay,
  display,
  annotation,
}

enum BoardElementType {
  flowchartShape,
  text,
  image,
}

class BoardElement {
  final String id;
  final BoardElementType type;

  // Usado quando o elemento for uma forma de fluxograma.
  final FlowchartShapeType? shapeType;

  // Texto apresentado dentro ou próximo do elemento.
  final String content;

  // Futuramente poderá guardar o caminho de uma imagem ou recurso.
  final String? resourceReference;

  // Posição no quadro.
  final double x;
  final double y;

  // Dimensões do elemento.
  final double width;
  final double height;

  final double rotation;
  final bool acceptsDrop;

  const BoardElement({
    required this.id,
    required this.type,
    required this.x,
    required this.y,
    required this.width,
    required this.height,
    this.shapeType,
    this.content = '',
    this.resourceReference,
    this.rotation = 0,
    this.acceptsDrop = false,
  });

  BoardElement copyWith({
    String? id,
    BoardElementType? type,
    FlowchartShapeType? shapeType,
    String? content,
    String? resourceReference,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    bool? acceptsDrop,
  }) {
    return BoardElement(
      id: id ?? this.id,
      type: type ?? this.type,
      shapeType: shapeType ?? this.shapeType,
      content: content ?? this.content,
      resourceReference:
      resourceReference ?? this.resourceReference,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      acceptsDrop: acceptsDrop ?? this.acceptsDrop,
    );
  }
}

class BoardConnection {
  final String id;
  final String fromElementId;
  final String toElementId;
  final String label;
  final bool showArrow;

  const BoardConnection({
    required this.id,
    required this.fromElementId,
    required this.toElementId,
    this.label = '',
    this.showArrow = true,
  });

  BoardConnection copyWith({
    String? id,
    String? fromElementId,
    String? toElementId,
    String? label,
    bool? showArrow,
  }) {
    return BoardConnection(
      id: id ?? this.id,
      fromElementId:
      fromElementId ?? this.fromElementId,
      toElementId:
      toElementId ?? this.toElementId,
      label: label ?? this.label,
      showArrow: showArrow ?? this.showArrow,
    );
  }
}

class ExerciseBoard {
  // Tamanho lógico do quadro. A interface fará a adaptação à tela.
  final double logicalWidth;
  final double logicalHeight;

  final List<BoardElement> elements;
  final List<BoardConnection> connections;

  final bool showGrid;
  final bool allowElementMovement;
  final bool allowConnections;

  const ExerciseBoard({
    required this.logicalWidth,
    required this.logicalHeight,
    required this.elements,
    required this.connections,
    this.showGrid = false,
    this.allowElementMovement = false,
    this.allowConnections = false,
  });

  ExerciseBoard copyWith({
    double? logicalWidth,
    double? logicalHeight,
    List<BoardElement>? elements,
    List<BoardConnection>? connections,
    bool? showGrid,
    bool? allowElementMovement,
    bool? allowConnections,
  }) {
    return ExerciseBoard(
      logicalWidth:
      logicalWidth ?? this.logicalWidth,
      logicalHeight:
      logicalHeight ?? this.logicalHeight,
      elements: elements ?? this.elements,
      connections: connections ?? this.connections,
      showGrid: showGrid ?? this.showGrid,
      allowElementMovement:
      allowElementMovement ?? this.allowElementMovement,
      allowConnections:
      allowConnections ?? this.allowConnections,
    );
  }
}