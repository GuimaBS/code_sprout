import '../models/diagram_model.dart';

class FlowchartShapeDefinition {
  final FlowchartShapeType type;
  final String name;
  final String description;

  final double defaultWidth;
  final double defaultHeight;

  const FlowchartShapeDefinition({
    required this.type,
    required this.name,
    required this.description,
    this.defaultWidth = 260,
    this.defaultHeight = 130,
  });
}

class FlowchartShapeCatalog {
  static const List<FlowchartShapeDefinition> all =
  <FlowchartShapeDefinition>[
    FlowchartShapeDefinition(
      type: FlowchartShapeType.startEnd,
      name: 'Início/Fim',
      description:
      'Indica o início ou o encerramento do fluxo.',
      defaultWidth: 260,
      defaultHeight: 120,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.process,
      name: 'Processo',
      description:
      'Representa uma ação ou processamento.',
      defaultWidth: 260,
      defaultHeight: 120,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.decision,
      name: 'Decisão',
      description:
      'Representa uma condição ou escolha.',
      defaultWidth: 220,
      defaultHeight: 160,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.inputOutput,
      name: 'Entrada/Saída',
      description:
      'Representa a entrada ou a saída de informações.',
      defaultWidth: 260,
      defaultHeight: 120,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.predefinedProcess,
      name: 'Processo predefinido',
      description:
      'Representa uma sub-rotina ou processo já definido.',
      defaultWidth: 260,
      defaultHeight: 120,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.document,
      name: 'Documento',
      description:
      'Representa um documento utilizado ou produzido.',
      defaultWidth: 260,
      defaultHeight: 140,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.multipleDocuments,
      name: 'Múltiplos documentos',
      description:
      'Representa um conjunto de documentos.',
      defaultWidth: 260,
      defaultHeight: 150,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.database,
      name: 'Banco de dados',
      description:
      'Representa informações armazenadas em banco de dados.',
      defaultWidth: 220,
      defaultHeight: 150,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.storedData,
      name: 'Dados armazenados',
      description:
      'Representa dados mantidos em armazenamento.',
      defaultWidth: 240,
      defaultHeight: 120,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.manualInput,
      name: 'Entrada manual',
      description:
      'Representa dados inseridos manualmente.',
      defaultWidth: 260,
      defaultHeight: 120,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.manualOperation,
      name: 'Operação manual',
      description:
      'Representa uma atividade realizada manualmente.',
      defaultWidth: 250,
      defaultHeight: 130,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.preparation,
      name: 'Preparação',
      description:
      'Representa uma etapa de configuração ou preparação.',
      defaultWidth: 240,
      defaultHeight: 130,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.connector,
      name: 'Conector',
      description:
      'Conecta partes do fluxo na mesma página.',
      defaultWidth: 100,
      defaultHeight: 100,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.offPageConnector,
      name: 'Conector externo',
      description:
      'Conecta o fluxo a outra página ou quadro.',
      defaultWidth: 150,
      defaultHeight: 150,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.delay,
      name: 'Espera',
      description:
      'Representa atraso ou tempo de espera.',
      defaultWidth: 230,
      defaultHeight: 120,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.display,
      name: 'Exibição',
      description:
      'Representa informações mostradas em uma tela.',
      defaultWidth: 240,
      defaultHeight: 120,
    ),
    FlowchartShapeDefinition(
      type: FlowchartShapeType.annotation,
      name: 'Anotação',
      description:
      'Acrescenta uma explicação ao fluxograma.',
      defaultWidth: 260,
      defaultHeight: 110,
    ),
  ];

  static FlowchartShapeDefinition? findByType(
      FlowchartShapeType type,
      ) {
    for (final FlowchartShapeDefinition definition in all) {
      if (definition.type == type) {
        return definition;
      }
    }

    return null;
  }

  static BoardElement createElement({
    required String id,
    required FlowchartShapeType type,
    required double x,
    required double y,
    String content = '',
    bool acceptsDrop = false,
    double? width,
    double? height,
  }) {
    final FlowchartShapeDefinition? definition =
    findByType(type);

    if (definition == null) {
      throw StateError(
        'A forma solicitada não foi encontrada no catálogo.',
      );
    }

    return BoardElement(
      id: id,
      type: BoardElementType.flowchartShape,
      shapeType: type,
      content: content,
      x: x,
      y: y,
      width: width ?? definition.defaultWidth,
      height: height ?? definition.defaultHeight,
      acceptsDrop: acceptsDrop,
    );
  }
}