import 'package:flutter/material.dart';

import 'data/app_data.dart';
import 'models/exercise_model.dart';
import 'models/exercise_progress.dart';
import 'models/learning_module.dart';

class LessonHistoryPage extends StatelessWidget {
  final String moduleId;

  const LessonHistoryPage({super.key, required this.moduleId});

  static const Color _pageBackground = Color(0xFF0A2826);
  static const Color _background = Color(0xFF123D39);
  static const Color _panel = Color(0xFF184B47);
  static const Color _green = Color(0xFF00F779);
  static const Color _white = Color(0xFFF7F7F2);
  static const Color _warning = Color(0xFFFFD54F);

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: progressStore,
      builder: (BuildContext context, Widget? child) {
        final LearningModule? module = moduleStore.findModule(moduleId);

        if (module == null) {
          return _buildMissingModule(context);
        }

        final List<ExerciseModel> exercises =
            module.exercises
                .where((ExerciseModel exercise) => exercise.isActive)
                .toList()
              ..sort((ExerciseModel first, ExerciseModel second) {
                return first.order.compareTo(second.order);
              });

        final int completedLessons = progressStore.completedCount(
          moduleId: module.id,
          exercises: exercises,
        );

        return Scaffold(
          backgroundColor: _pageBackground,
          body: Center(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 520),
              color: _background,
              child: SafeArea(
                child: Column(
                  children: <Widget>[
                    _buildHeader(context, module.title),
                    Expanded(
                      child: exercises.isEmpty
                          ? _buildEmptyState()
                          : _buildHistoryContent(
                              module: module,
                              exercises: exercises,
                              completedLessons: completedLessons,
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

  Widget _buildHeader(BuildContext context, String moduleTitle) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 17, 18, 17),
      decoration: const BoxDecoration(
        color: Color(0xFF102F2D),
        border: Border(bottom: BorderSide(color: Color(0xFF087B50), width: 2)),
      ),
      child: Row(
        children: <Widget>[
          Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.of(context).pop();
              },
              borderRadius: BorderRadius.circular(99),
              child: const Padding(
                padding: EdgeInsets.all(8),
                child: Icon(Icons.arrow_back_rounded, color: _white, size: 30),
              ),
            ),
          ),
          const SizedBox(width: 9),
          const _HistoryLogo(),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                const Text(
                  'Histórico de lições',
                  style: TextStyle(
                    color: _white,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  moduleTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: _green,
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent({
    required LearningModule module,
    required List<ExerciseModel> exercises,
    required int completedLessons,
  }) {
    final double progress = exercises.isEmpty
        ? 0
        : completedLessons / exercises.length;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(22, 24, 22, 38),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildSummary(
            completedLessons: completedLessons,
            totalLessons: exercises.length,
            progress: progress,
          ),
          const SizedBox(height: 25),
          const Text(
            'Todas as lições',
            style: TextStyle(
              color: _white,
              fontSize: 26,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Consulte seu desempenho em cada atividade.',
            style: TextStyle(
              color: _white.withValues(alpha: 0.72),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 18),
          for (int index = 0; index < exercises.length; index++) ...<Widget>[
            _buildLessonCard(
              moduleId: module.id,
              exercise: exercises[index],
              lessonNumber: index + 1,
            ),
            if (index < exercises.length - 1) const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }

  Widget _buildSummary({
    required int completedLessons,
    required int totalLessons,
    required double progress,
  }) {
    return Container(
      padding: const EdgeInsets.all(21),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _green.withValues(alpha: 0.55)),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 54,
                height: 54,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF075F46),
                ),
                child: const Icon(
                  Icons.auto_graph_rounded,
                  color: _green,
                  size: 31,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    const Text(
                      'Progresso do módulo',
                      style: TextStyle(
                        color: _white,
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$completedLessons de $totalLessons '
                      'lições concluídas',
                      style: const TextStyle(
                        color: _green,
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(progress * 100).round()}%',
                style: const TextStyle(
                  color: _green,
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          const SizedBox(height: 17),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 13,
              backgroundColor: const Color(0xFF123D39),
              valueColor: const AlwaysStoppedAnimation<Color>(_green),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLessonCard({
    required String moduleId,
    required ExerciseModel exercise,
    required int lessonNumber,
  }) {
    final ExerciseProgress? progress = progressStore.findProgress(
      moduleId: moduleId,
      exerciseId: exercise.id,
    );

    final bool completed = progress?.completed ?? false;

    final bool started =
        progress != null && (progress.attempts > 0 || progress.hintUsed);

    final String statusText;

    final Color statusColor;

    final IconData statusIcon;

    if (completed) {
      statusText = 'Concluída';
      statusColor = _green;
      statusIcon = Icons.check_circle_rounded;
    } else if (started) {
      statusText = 'Em andamento';
      statusColor = _warning;
      statusIcon = Icons.pending_rounded;
    } else {
      statusText = 'Não iniciada';
      statusColor = _white.withValues(alpha: 0.58);
      statusIcon = Icons.radio_button_unchecked_rounded;
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: completed
              ? _green.withValues(alpha: 0.7)
              : const Color(0xFF087B50),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: statusColor.withValues(alpha: 0.16),
                  border: Border.all(color: statusColor),
                ),
                child: Text(
                  '$lessonNumber',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Lição $lessonNumber',
                  style: const TextStyle(
                    color: _white,
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(99),
                  border: Border.all(color: statusColor.withValues(alpha: 0.8)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(statusIcon, color: statusColor, size: 17),
                    const SizedBox(width: 5),
                    Text(
                      statusText,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            exercise.statement,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: _white.withValues(alpha: 0.86),
              fontSize: 15,
              height: 1.35,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: Color(0xFF087B50), height: 1),
          const SizedBox(height: 14),
          _buildProgressDetails(
            progress: progress,
            started: started,
            completed: completed,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressDetails({
    required ExerciseProgress? progress,
    required bool started,
    required bool completed,
  }) {
    if (!started || progress == null) {
      return Text(
        'Esta atividade ainda não foi realizada.',
        style: TextStyle(
          color: _white.withValues(alpha: 0.62),
          fontSize: 14,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Wrap(
          spacing: 10,
          runSpacing: 9,
          children: <Widget>[
            _buildInformationBadge(
              icon: Icons.touch_app_rounded,
              text: _attemptText(progress.attempts),
            ),
            _buildInformationBadge(
              icon: Icons.close_rounded,
              text: _errorText(progress.incorrectAttempts),
            ),
            if (progress.hintUsed)
              _buildInformationBadge(
                icon: Icons.lightbulb_rounded,
                text: 'Dica utilizada',
              ),
          ],
        ),
        const SizedBox(height: 13),
        Text(
          _feedbackText(progress: progress, completed: completed),
          style: TextStyle(
            color: completed ? _green : _warning,
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w800,
          ),
        ),
        if (progress.completedAt != null) ...<Widget>[
          const SizedBox(height: 7),
          Text(
            'Concluída em ${_formatDate(progress.completedAt!)}',
            style: TextStyle(
              color: _white.withValues(alpha: 0.58),
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildInformationBadge({
    required IconData icon,
    required String text,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: const Color(0xFF102F2D),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: _green, size: 17),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: _white,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  String _feedbackText({
    required ExerciseProgress progress,
    required bool completed,
  }) {
    if (completed && progress.incorrectAttempts == 0) {
      return 'Excelente! Atividade concluída sem erros.';
    }

    if (completed) {
      return 'Atividade concluída após correção das tentativas.';
    }

    if (progress.lastAttemptWasCorrect == false) {
      return 'A última tentativa foi incorreta. Continue tentando.';
    }

    if (progress.hintUsed) {
      return 'A dica foi consultada. A atividade ainda está pendente.';
    }

    return 'Atividade iniciada e ainda não concluída.';
  }

  String _attemptText(int attempts) {
    if (attempts == 1) {
      return '1 tentativa';
    }

    return '$attempts tentativas';
  }

  String _errorText(int errors) {
    if (errors == 1) {
      return '1 erro';
    }

    return '$errors erros';
  }

  String _formatDate(DateTime date) {
    final String day = date.day.toString().padLeft(2, '0');
    final String month = date.month.toString().padLeft(2, '0');
    final String hour = date.hour.toString().padLeft(2, '0');
    final String minute = date.minute.toString().padLeft(2, '0');

    return '$day/$month/${date.year} às $hour:$minute';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.menu_book_rounded,
              color: _green.withValues(alpha: 0.76),
              size: 76,
            ),
            const SizedBox(height: 20),
            const Text(
              'Nenhuma lição cadastrada',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _white,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Este módulo ainda não possui exercícios ativos.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _white.withValues(alpha: 0.67),
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMissingModule(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          color: _background,
          alignment: Alignment.center,
          padding: const EdgeInsets.all(28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(
                Icons.error_outline_rounded,
                color: _warning,
                size: 72,
              ),
              const SizedBox(height: 18),
              const Text(
                'Módulo não encontrado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 22),
              _HistoryBackButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryLogo extends StatelessWidget {
  const _HistoryLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 50,
      height: 50,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF075F46),
        border: Border.all(color: const Color(0xFF00F779), width: 2),
      ),
      child: const Icon(Icons.eco_rounded, color: Color(0xFF9EFF75), size: 31),
    );
  }
}

class _HistoryBackButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _HistoryBackButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF00F779),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF7F7F2), width: 4),
          ),
          child: const Text(
            'Voltar',
            style: TextStyle(
              color: Color(0xFF104B50),
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}
