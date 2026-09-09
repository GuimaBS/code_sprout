import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/diagram_model.dart';

class FlowchartShapeWidget extends StatelessWidget {
  final FlowchartShapeType type;
  final String? label;
  final String? semanticLabel;

  final Color fillColor;
  final Color borderColor;
  final Color textColor;

  final double borderWidth;
  final bool selected;

  const FlowchartShapeWidget({
    super.key,
    required this.type,
    this.label,
    this.semanticLabel,
    this.fillColor = const Color(0xFF00F779),
    this.borderColor = const Color(0xFFF7F7F2),
    this.textColor = const Color(0xFF104B50),
    this.borderWidth = 3,
    this.selected = false,
  });

  @override
  Widget build(BuildContext context) {
    final Color effectiveBorderColor = selected
        ? const Color(0xFFFFD54F)
        : borderColor;

    final double effectiveBorderWidth =
    selected ? borderWidth + 2 : borderWidth;

    return Semantics(
      label: semanticLabel ?? label ?? type.name,
      child: CustomPaint(
        painter: FlowchartShapePainter(
          type: type,
          fillColor: fillColor,
          borderColor: effectiveBorderColor,
          borderWidth: effectiveBorderWidth,
        ),
        child: label == null
            ? const SizedBox.shrink()
            : Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24,
              vertical: 16,
            ),
            child: Text(
              label!,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class FlowchartShapePainter extends CustomPainter {
  final FlowchartShapeType type;
  final Color fillColor;
  final Color borderColor;
  final double borderWidth;

  const FlowchartShapePainter({
    required this.type,
    required this.fillColor,
    required this.borderColor,
    required this.borderWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) {
      return;
    }

    final Paint fillPaint = Paint()
      ..color = fillColor
      ..style = PaintingStyle.fill;

    final Paint borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth
      ..strokeJoin = StrokeJoin.round
      ..strokeCap = StrokeCap.round;

    final Rect area = Rect.fromLTWH(
      borderWidth,
      borderWidth,
      size.width - borderWidth * 2,
      size.height - borderWidth * 2,
    );

    switch (type) {
      case FlowchartShapeType.predefinedProcess:
        _drawPredefinedProcess(
          canvas,
          area,
          fillPaint,
          borderPaint,
        );
        return;

      case FlowchartShapeType.document:
        _drawDocument(
          canvas,
          area,
          fillPaint,
          borderPaint,
        );
        return;

      case FlowchartShapeType.multipleDocuments:
        _drawMultipleDocuments(
          canvas,
          area,
          fillPaint,
          borderPaint,
        );
        return;

      case FlowchartShapeType.database:
        _drawDatabase(
          canvas,
          area,
          fillPaint,
          borderPaint,
        );
        return;

      case FlowchartShapeType.annotation:
        _drawAnnotation(
          canvas,
          area,
          fillPaint,
          borderPaint,
        );
        return;

      default:
        final Path path = _createShapePath(
          type,
          area,
        );

        canvas
          ..drawPath(path, fillPaint)
          ..drawPath(path, borderPaint);
    }
  }

  Path _createShapePath(
      FlowchartShapeType shapeType,
      Rect area,
      ) {
    final Path path = Path();

    switch (shapeType) {
      case FlowchartShapeType.startEnd:
        path.addRRect(
          RRect.fromRectAndRadius(
            area,
            Radius.circular(area.height / 2),
          ),
        );
        break;

      case FlowchartShapeType.process:
        path.addRRect(
          RRect.fromRectAndRadius(
            area,
            const Radius.circular(3),
          ),
        );
        break;

      case FlowchartShapeType.decision:
        path
          ..moveTo(area.center.dx, area.top)
          ..lineTo(area.right, area.center.dy)
          ..lineTo(area.center.dx, area.bottom)
          ..lineTo(area.left, area.center.dy)
          ..close();
        break;

      case FlowchartShapeType.inputOutput:
        final double offset = area.width * 0.17;

        path
          ..moveTo(area.left + offset, area.top)
          ..lineTo(area.right, area.top)
          ..lineTo(area.right - offset, area.bottom)
          ..lineTo(area.left, area.bottom)
          ..close();
        break;

      case FlowchartShapeType.storedData:
        final double curve = area.width * 0.14;

        path
          ..moveTo(area.left + curve, area.top)
          ..lineTo(area.right, area.top)
          ..quadraticBezierTo(
            area.right - curve,
            area.center.dy,
            area.right,
            area.bottom,
          )
          ..lineTo(area.left + curve, area.bottom)
          ..quadraticBezierTo(
            area.left - curve * 0.25,
            area.center.dy,
            area.left + curve,
            area.top,
          )
          ..close();
        break;

      case FlowchartShapeType.manualInput:
        final double offset = area.width * 0.16;

        path
          ..moveTo(area.left + offset, area.top)
          ..lineTo(area.right, area.top)
          ..lineTo(area.right, area.bottom)
          ..lineTo(area.left, area.bottom)
          ..close();
        break;

      case FlowchartShapeType.manualOperation:
        final double offset = area.width * 0.15;

        path
          ..moveTo(area.left, area.top)
          ..lineTo(area.right, area.top)
          ..lineTo(area.right - offset, area.bottom)
          ..lineTo(area.left + offset, area.bottom)
          ..close();
        break;

      case FlowchartShapeType.preparation:
        final double offset = area.width * 0.18;

        path
          ..moveTo(area.left + offset, area.top)
          ..lineTo(area.right - offset, area.top)
          ..lineTo(area.right, area.center.dy)
          ..lineTo(area.right - offset, area.bottom)
          ..lineTo(area.left + offset, area.bottom)
          ..lineTo(area.left, area.center.dy)
          ..close();
        break;

      case FlowchartShapeType.connector:
        path.addOval(area);
        break;

      case FlowchartShapeType.offPageConnector:
        final double pointHeight = area.height * 0.28;

        path
          ..moveTo(area.left, area.top)
          ..lineTo(area.right, area.top)
          ..lineTo(
            area.right,
            area.bottom - pointHeight,
          )
          ..lineTo(
            area.center.dx,
            area.bottom,
          )
          ..lineTo(
            area.left,
            area.bottom - pointHeight,
          )
          ..close();
        break;

      case FlowchartShapeType.delay:
        final double curveStart =
            area.left + area.width * 0.52;

        path
          ..moveTo(area.left, area.top)
          ..lineTo(curveStart, area.top)
          ..cubicTo(
            area.right,
            area.top,
            area.right,
            area.bottom,
            curveStart,
            area.bottom,
          )
          ..lineTo(area.left, area.bottom)
          ..close();
        break;

      case FlowchartShapeType.display:
        final double pointWidth = area.width * 0.14;
        final double curveWidth = area.width * 0.22;

        path
          ..moveTo(
            area.left + pointWidth,
            area.top,
          )
          ..lineTo(
            area.right - curveWidth,
            area.top,
          )
          ..quadraticBezierTo(
            area.right,
            area.top,
            area.right,
            area.center.dy,
          )
          ..quadraticBezierTo(
            area.right,
            area.bottom,
            area.right - curveWidth,
            area.bottom,
          )
          ..lineTo(
            area.left + pointWidth,
            area.bottom,
          )
          ..lineTo(
            area.left,
            area.center.dy,
          )
          ..close();
        break;

      case FlowchartShapeType.predefinedProcess:
      case FlowchartShapeType.document:
      case FlowchartShapeType.multipleDocuments:
      case FlowchartShapeType.database:
      case FlowchartShapeType.annotation:
        break;
    }

    return path;
  }

  void _drawPredefinedProcess(
      Canvas canvas,
      Rect area,
      Paint fillPaint,
      Paint borderPaint,
      ) {
    final RRect shape = RRect.fromRectAndRadius(
      area,
      const Radius.circular(3),
    );

    canvas
      ..drawRRect(shape, fillPaint)
      ..drawRRect(shape, borderPaint);

    final double leftLine =
        area.left + area.width * 0.13;

    final double rightLine =
        area.right - area.width * 0.13;

    canvas
      ..drawLine(
        Offset(leftLine, area.top),
        Offset(leftLine, area.bottom),
        borderPaint,
      )
      ..drawLine(
        Offset(rightLine, area.top),
        Offset(rightLine, area.bottom),
        borderPaint,
      );
  }

  void _drawDocument(
      Canvas canvas,
      Rect area,
      Paint fillPaint,
      Paint borderPaint,
      ) {
    final Path path = _documentPath(area);

    canvas
      ..drawPath(path, fillPaint)
      ..drawPath(path, borderPaint);
  }

  void _drawMultipleDocuments(
      Canvas canvas,
      Rect area,
      Paint fillPaint,
      Paint borderPaint,
      ) {
    final double offset = math.min(
      area.width,
      area.height,
    ) *
        0.08;

    final Rect backArea = Rect.fromLTWH(
      area.left + offset * 2,
      area.top,
      area.width - offset * 2,
      area.height - offset * 2,
    );

    final Rect middleArea = Rect.fromLTWH(
      area.left + offset,
      area.top + offset,
      area.width - offset * 2,
      area.height - offset * 2,
    );

    final Rect frontArea = Rect.fromLTWH(
      area.left,
      area.top + offset * 2,
      area.width - offset * 2,
      area.height - offset * 2,
    );

    _drawDocument(
      canvas,
      backArea,
      fillPaint,
      borderPaint,
    );

    _drawDocument(
      canvas,
      middleArea,
      fillPaint,
      borderPaint,
    );

    _drawDocument(
      canvas,
      frontArea,
      fillPaint,
      borderPaint,
    );
  }

  Path _documentPath(Rect area) {
    final double waveHeight = area.height * 0.16;

    return Path()
      ..moveTo(area.left, area.top)
      ..lineTo(area.right, area.top)
      ..lineTo(
        area.right,
        area.bottom - waveHeight,
      )
      ..cubicTo(
        area.right - area.width * 0.25,
        area.bottom - waveHeight * 2,
        area.left + area.width * 0.25,
        area.bottom + waveHeight * 0.25,
        area.left,
        area.bottom - waveHeight,
      )
      ..close();
  }

  void _drawDatabase(
      Canvas canvas,
      Rect area,
      Paint fillPaint,
      Paint borderPaint,
      ) {
    final double ovalHeight = area.height * 0.24;

    final Rect body = Rect.fromLTRB(
      area.left,
      area.top + ovalHeight / 2,
      area.right,
      area.bottom - ovalHeight / 2,
    );

    final Rect topOval = Rect.fromLTWH(
      area.left,
      area.top,
      area.width,
      ovalHeight,
    );

    final Rect bottomOval = Rect.fromLTWH(
      area.left,
      area.bottom - ovalHeight,
      area.width,
      ovalHeight,
    );

    canvas
      ..drawRect(body, fillPaint)
      ..drawOval(bottomOval, fillPaint)
      ..drawOval(topOval, fillPaint)
      ..drawLine(
        Offset(area.left, topOval.center.dy),
        Offset(area.left, bottomOval.center.dy),
        borderPaint,
      )
      ..drawLine(
        Offset(area.right, topOval.center.dy),
        Offset(area.right, bottomOval.center.dy),
        borderPaint,
      )
      ..drawOval(topOval, borderPaint)
      ..drawArc(
        bottomOval,
        0,
        math.pi,
        false,
        borderPaint,
      );
  }

  void _drawAnnotation(
      Canvas canvas,
      Rect area,
      Paint fillPaint,
      Paint borderPaint,
      ) {
    final double pointWidth = area.width * 0.13;

    final Path background = Path()
      ..moveTo(
        area.left + pointWidth,
        area.top,
      )
      ..lineTo(area.right, area.top)
      ..lineTo(area.right, area.bottom)
      ..lineTo(
        area.left + pointWidth,
        area.bottom,
      )
      ..lineTo(area.left, area.center.dy)
      ..close();

    canvas
      ..drawPath(background, fillPaint)
      ..drawPath(background, borderPaint)
      ..drawLine(
        Offset(
          area.left + pointWidth,
          area.top,
        ),
        Offset(
          area.left + pointWidth,
          area.bottom,
        ),
        borderPaint,
      );
  }

  @override
  bool shouldRepaint(
      covariant FlowchartShapePainter oldDelegate,
      ) {
    return oldDelegate.type != type ||
        oldDelegate.fillColor != fillColor ||
        oldDelegate.borderColor != borderColor ||
        oldDelegate.borderWidth != borderWidth;
  }
}