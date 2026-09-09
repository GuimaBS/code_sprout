import 'dart:math' as math;

import 'package:flutter/material.dart';

class ModuleCompletedPage extends StatefulWidget {
  final String moduleTitle;
  final int completedLessons;
  final int totalLessons;
  final VoidCallback? onReviewLessons;

  const ModuleCompletedPage({
    super.key,
    required this.moduleTitle,
    required this.completedLessons,
    required this.totalLessons,
    this.onReviewLessons,
  });

  @override
  State<ModuleCompletedPage> createState() =>
      _ModuleCompletedPageState();
}

class _ModuleCompletedPageState extends State<ModuleCompletedPage>
    with SingleTickerProviderStateMixin {
  static const Color _pageBackground = Color(0xFF0A2826);
  static const Color _background = Color(0xFF123D39);
  static const Color _panel = Color(0xFF184B47);
  static const Color _green = Color(0xFF00F779);
  static const Color _darkGreen = Color(0xFF075F46);
  static const Color _white = Color(0xFFF7F7F2);

  late final AnimationController _confettiController;

  bool _contentVisible = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();

    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3200),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      setState(() {
        _contentVisible = true;
      });
    });
  }

  @override
  void dispose() {
    _confettiController.dispose();
    super.dispose();
  }

  double get _progress {
    if (widget.totalLessons <= 0) {
      return 0;
    }

    return (widget.completedLessons / widget.totalLessons)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  Future<void> _returnToHome() async {
    if (_leaving) {
      return;
    }

    setState(() {
      _leaving = true;
      _contentVisible = false;
    });

    await Future<void>.delayed(
      const Duration(milliseconds: 420),
    );

    if (!mounted) {
      return;
    }

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          color: _background,
          child: SafeArea(
            child: Stack(
              children: <Widget>[
                Positioned.fill(
                  child: IgnorePointer(
                    child: AnimatedBuilder(
                      animation: _confettiController,
                      builder: (
                          BuildContext context,
                          Widget? child,
                          ) {
                        return CustomPaint(
                          painter: _ConfettiPainter(
                            progress: _confettiController.value,
                          ),
                        );
                      },
                    ),
                  ),
                ),
                Positioned.fill(
                  child: AnimatedOpacity(
                    opacity: _contentVisible ? 1 : 0,
                    duration: const Duration(milliseconds: 500),
                    curve: Curves.easeOut,
                    child: AnimatedScale(
                      scale: _contentVisible ? 1 : 0.88,
                      duration: const Duration(milliseconds: 550),
                      curve: Curves.easeOutBack,
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(
                          24,
                          46,
                          24,
                          40,
                        ),
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight:
                            MediaQuery.sizeOf(context).height - 120,
                          ),
                          child: Center(
                            child: _buildCompletionCard(),
                          ),
                        ),
                      ),
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

  Widget _buildCompletionCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        25,
        34,
        25,
        28,
      ),
      decoration: BoxDecoration(
        color: _panel.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: _green,
          width: 2,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _green.withValues(alpha: 0.18),
            blurRadius: 30,
            spreadRadius: 4,
          ),
          const BoxShadow(
            color: Colors.black45,
            blurRadius: 22,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          _buildCelebrationIcon(),
          const SizedBox(height: 25),
          const Text(
            'MÓDULO CONCLUÍDO!',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white,
              fontSize: 31,
              height: 1.1,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 15),
          Text(
            widget.moduleTitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _green,
              fontSize: 25,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'Parabéns! Você completou todas as atividades '
                'disponíveis neste módulo.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white.withValues(alpha: 0.86),
              fontSize: 17,
              height: 1.4,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 28),
          _buildProgressPanel(),
          const SizedBox(height: 30),
          SizedBox(
            width: double.infinity,
            child: _CompletionButton(
              text: 'Voltar para Home',
              icon: Icons.home_rounded,
              onPressed: _returnToHome,
            ),
          ),
          if (widget.onReviewLessons != null) ...<Widget>[
            const SizedBox(height: 13),
            SizedBox(
              width: double.infinity,
              child: _SecondaryButton(
                text: 'Rever lições',
                icon: Icons.history_edu_rounded,
                onPressed: widget.onReviewLessons!,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildCelebrationIcon() {
    return Container(
      width: 142,
      height: 142,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: _darkGreen,
        border: Border.all(
          color: _white,
          width: 7,
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: _green.withValues(alpha: 0.42),
            blurRadius: 25,
            spreadRadius: 5,
          ),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 18,
            child: Icon(
              Icons.eco_rounded,
              color: Color(0xFF9EFF75),
              size: 67,
            ),
          ),
          Positioned(
            bottom: 16,
            child: Icon(
              Icons.check_circle_rounded,
              color: _white,
              size: 48,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressPanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFF102F2D),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: _green.withValues(alpha: 0.48),
        ),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(
                Icons.task_alt_rounded,
                color: _green,
                size: 27,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  '${widget.completedLessons} de '
                      '${widget.totalLessons} lições concluídas',
                  style: const TextStyle(
                    color: _white,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Text(
                '${(_progress * 100).round()}%',
                style: const TextStyle(
                  color: _green,
                  fontSize: 19,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: _progress,
              minHeight: 13,
              backgroundColor: const Color(0xFF194440),
              valueColor:
              const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _CompletionButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF00F779),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        hoverColor: Colors.white.withValues(alpha: 0.18),
        splashColor: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 62,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFF7F7F2),
              width: 5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: const Color(0xFF104B50),
                size: 28,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFF104B50),
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
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

class _SecondaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onPressed,
        hoverColor: Colors.white.withValues(alpha: 0.08),
        splashColor: Colors.white.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          height: 58,
          padding: const EdgeInsets.symmetric(
            horizontal: 18,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(
              color: const Color(0xFFF7F7F2),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                icon,
                color: const Color(0xFFF7F7F2),
                size: 26,
              ),
              const SizedBox(width: 10),
              Flexible(
                child: Text(
                  text,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Color(0xFFF7F7F2),
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
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

class _ConfettiPainter extends CustomPainter {
  final double progress;

  const _ConfettiPainter({
    required this.progress,
  });

  static const List<Color> _colors = <Color>[
    Color(0xFF00F779),
    Color(0xFF9EFF75),
    Color(0xFFF7F7F2),
    Color(0xFF00D4C8),
    Color(0xFFFFD54F),
    Color(0xFF4FC3F7),
  ];

  @override
  void paint(Canvas canvas, Size size) {
    final math.Random random = math.Random(407);
    final Paint paint = Paint();

    for (int index = 0; index < 52; index++) {
      final double startingX = random.nextDouble() * size.width;
      final double delay = random.nextDouble();
      final double speed = 0.75 + random.nextDouble() * 0.75;
      final double horizontalMovement =
          10 + random.nextDouble() * 32;
      final double phase =
          random.nextDouble() * math.pi * 2;
      final double pieceSize =
          5 + random.nextDouble() * 7;

      final double fallingProgress =
          ((progress * speed) + delay) % 1;

      final double x = startingX +
          math.sin(
            progress * math.pi * 2 + phase,
          ) *
              horizontalMovement;

      final double y =
          -25 + fallingProgress * (size.height + 50);

      final double opacity = fallingProgress > 0.88
          ? ((1 - fallingProgress) / 0.12)
          .clamp(0.0, 1.0)
          .toDouble()
          : 0.9;

      paint.color = _colors[index % _colors.length]
          .withValues(alpha: opacity);

      canvas.save();
      canvas.translate(x, y);
      canvas.rotate(
        progress * math.pi * 4 + phase,
      );

      if (index % 3 == 0) {
        canvas.drawCircle(
          Offset.zero,
          pieceSize * 0.55,
          paint,
        );
      } else if (index % 3 == 1) {
        canvas.drawRRect(
          RRect.fromRectAndRadius(
            Rect.fromCenter(
              center: Offset.zero,
              width: pieceSize,
              height: pieceSize * 1.8,
            ),
            const Radius.circular(2),
          ),
          paint,
        );
      } else {
        canvas.drawOval(
          Rect.fromCenter(
            center: Offset.zero,
            width: pieceSize,
            height: pieceSize * 2,
          ),
          paint,
        );
      }

      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(
      covariant _ConfettiPainter oldDelegate,
      ) {
    return oldDelegate.progress != progress;
  }
}