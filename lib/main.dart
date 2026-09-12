import 'package:flutter/material.dart';

import 'data/app_data.dart';
import 'exercise_page.dart';
import 'lesson_history_page.dart';
import 'login_page.dart';
import 'models/exercise_model.dart';
import 'module_completed_page.dart';
import 'profile_page.dart';
import 'models/learning_module.dart';

void main() {
  runApp(const CodeSproutApp());
}

class CodeSproutApp extends StatelessWidget {
  const CodeSproutApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'CodeSprout',
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF123D39),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00F779),
          brightness: Brightness.dark,
        ),
      ),
      home: LoginPage(
        homeBuilder: (BuildContext context) => const HomePage(),
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const Color backgroundColor = Color(0xFF123D39);
  static const Color cardColor = Color(0xFF184B47);
  static const Color borderColor = Color(0xFF087B50);
  static const Color greenColor = Color(0xFF00F779);
  static const Color whiteColor = Color(0xFFF4F4F4);

  String? _selectedModuleId;

  @override
  void initState() {
    super.initState();

    final List<LearningModule> modules =
        moduleStore.modules;

    if (modules.isNotEmpty) {
      _selectedModuleId = modules.first.id;
    }

    progressStore.addListener(_refreshHome);
    moduleStore.addListener(_refreshHome);
  }

  @override
  void dispose() {
    progressStore.removeListener(_refreshHome);
    moduleStore.removeListener(_refreshHome);
    super.dispose();
  }

  void _refreshHome() {
    if (!mounted) {
      return;
    }

    final List<LearningModule> modules =
        moduleStore.modules;

    setState(() {
      if (modules.isEmpty) {
        _selectedModuleId = null;
        return;
      }

      final bool selectedModuleStillExists =
          moduleStore.findModule(_selectedModuleId ?? '') != null;

      if (!selectedModuleStillExists) {
        _selectedModuleId = modules.first.id;
      }
    });
  }

  List<ExerciseModel> _activeExercisesFor(
      LearningModule module,
      ) {
    final List<ExerciseModel> exercises =
    module.exercises
        .where(
          (ExerciseModel exercise) =>
      exercise.isActive,
    )
        .toList();

    exercises.sort(
          (
          ExerciseModel first,
          ExerciseModel second,
          ) {
        return first.order.compareTo(second.order);
      },
    );

    return exercises;
  }

  bool _isModuleUnlocked(
      int moduleIndex,
      List<LearningModule> modules,
      ) {
    // O primeiro módulo está sempre disponível.
    if (moduleIndex == 0) {
      return true;
    }

    final LearningModule previousModule =
    modules[moduleIndex - 1];

    final List<ExerciseModel> previousExercises =
    _activeExercisesFor(previousModule);

    // Um módulo vazio não libera o seguinte.
    if (previousExercises.isEmpty) {
      return false;
    }

    final int completedLessons =
    progressStore.completedCount(
      moduleId: previousModule.id,
      exercises: previousExercises,
    );

    return completedLessons == previousExercises.length;
  }

  Future<void> _showModuleSelector() async {
    final List<LearningModule> modules =
        moduleStore.modules;

    // Com apenas um módulo não existe lista para apresentar.
    if (modules.length <= 1) {
      return;
    }

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext sheetContext) {
        return SafeArea(
          child: FractionallySizedBox(
            heightFactor: 0.65,
            child: Container(
              decoration: const BoxDecoration(
                color: Color(0xFF123D39),
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(24),
                ),
                border: Border(
                  top: BorderSide(
                    color: greenColor,
                    width: 2,
                  ),
                ),
              ),
              child: Column(
                children: <Widget>[
                  Container(
                    width: 48,
                    height: 5,
                    margin: const EdgeInsets.only(
                      top: 12,
                      bottom: 18,
                    ),
                    decoration: BoxDecoration(
                      color: whiteColor.withValues(
                        alpha: 0.45,
                      ),
                      borderRadius:
                      BorderRadius.circular(99),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 22,
                    ),
                    child: Row(
                      children: <Widget>[
                        Icon(
                          Icons.view_module_outlined,
                          color: greenColor,
                          size: 30,
                        ),
                        SizedBox(width: 10),
                        Text(
                          'Selecionar módulo',
                          style: TextStyle(
                            color: whiteColor,
                            fontSize: 24,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.fromLTRB(
                        16,
                        0,
                        16,
                        24,
                      ),
                      itemCount: modules.length,
                      separatorBuilder: (
                          BuildContext context,
                          int index,
                          ) {
                        return const SizedBox(height: 10);
                      },
                      itemBuilder: (
                          BuildContext context,
                          int index,
                          ) {
                        final LearningModule module =
                        modules[index];

                        final bool unlocked =
                        _isModuleUnlocked(
                          index,
                          modules,
                        );

                        final bool selected =
                            module.id ==
                                _selectedModuleId;

                        final String subtitle;

                        if (unlocked) {
                          subtitle = module.subject;
                        } else {
                          subtitle =
                          'Conclua ${modules[index - 1].title} '
                              'para desbloquear.';
                        }

                        return Material(
                          color: selected
                              ? greenColor.withValues(
                            alpha: 0.13,
                          )
                              : cardColor,
                          borderRadius:
                          BorderRadius.circular(12),
                          child: InkWell(
                            onTap: unlocked
                                ? () {
                              setState(() {
                                _selectedModuleId =
                                    module.id;
                              });

                              Navigator.of(
                                sheetContext,
                              ).pop();
                            }
                                : null,
                            borderRadius:
                            BorderRadius.circular(12),
                            child: Container(
                              padding:
                              const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                borderRadius:
                                BorderRadius.circular(
                                  12,
                                ),
                                border: Border.all(
                                  color: selected
                                      ? greenColor
                                      : borderColor,
                                  width: selected ? 2 : 1,
                                ),
                              ),
                              child: Row(
                                children: <Widget>[
                                  Container(
                                    width: 46,
                                    height: 46,
                                    alignment:
                                    Alignment.center,
                                    decoration:
                                    BoxDecoration(
                                      color: const Color(
                                        0xFF163F3B,
                                      ),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: unlocked
                                            ? greenColor
                                            : whiteColor
                                            .withValues(
                                          alpha:
                                          0.25,
                                        ),
                                      ),
                                    ),
                                    child: Icon(
                                      unlocked
                                          ? Icons
                                          .menu_book_rounded
                                          : Icons
                                          .lock_outline_rounded,
                                      color: unlocked
                                          ? greenColor
                                          : whiteColor
                                          .withValues(
                                        alpha:
                                        0.45,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                      CrossAxisAlignment
                                          .start,
                                      children: <Widget>[
                                        Text(
                                          module.title,
                                          style: TextStyle(
                                            color: unlocked
                                                ? whiteColor
                                                : whiteColor
                                                .withValues(
                                              alpha:
                                              0.45,
                                            ),
                                            fontSize: 19,
                                            fontWeight:
                                            FontWeight
                                                .w900,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Text(
                                          subtitle,
                                          style: TextStyle(
                                            color: whiteColor
                                                .withValues(
                                              alpha: unlocked
                                                  ? 0.70
                                                  : 0.38,
                                            ),
                                            fontSize: 13,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (selected)
                                    const Icon(
                                      Icons
                                          .check_circle_rounded,
                                      color: greenColor,
                                    )
                                  else if (!unlocked)
                                    Icon(
                                      Icons.lock_rounded,
                                      color: whiteColor
                                          .withValues(
                                        alpha: 0.38,
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons
                                          .chevron_right_rounded,
                                      color: whiteColor,
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
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).clearSnackBars();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void openModule(
      BuildContext context,
      String moduleId,
      ) {
    final module = moduleStore.findModule(moduleId);

    if (module == null) {
      showMessage(
        context,
        'O módulo solicitado não foi encontrado.',
      );
      return;
    }

    final List<ExerciseModel> activeExercises =
    module.exercises
        .where(
          (ExerciseModel exercise) => exercise.isActive,
    )
        .toList()
      ..sort(
            (
            ExerciseModel first,
            ExerciseModel second,
            ) {
          return first.order.compareTo(second.order);
        },
      );

    if (activeExercises.isEmpty) {
      showMessage(
        context,
        'Este módulo ainda não possui exercícios.',
      );
      return;
    }

    final int? nextExerciseIndex =
    progressStore.firstIncompleteExerciseIndex(
      moduleId: module.id,
      exercises: activeExercises,
    );

    if (nextExerciseIndex == null) {
      final int completedLessons =
      progressStore.completedCount(
        moduleId: module.id,
        exercises: activeExercises,
      );

      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (BuildContext completionContext) {
            return ModuleCompletedPage(
              moduleTitle: module.title,
              completedLessons: completedLessons,
              totalLessons: activeExercises.length,
              onReviewLessons: () {
                Navigator.of(completionContext).pushReplacement(
                  MaterialPageRoute<void>(
                    builder: (BuildContext context) {
                      return LessonHistoryPage(
                        moduleId: module.id,
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      );

      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return ExercisePage(
            moduleId: module.id,
            exerciseIndex: nextExerciseIndex,
          );
        },
      ),
    );
  }

  void openLessonHistory(
      BuildContext context,
      String moduleId,
      ) {
    final module = moduleStore.findModule(moduleId);

    if (module == null) {
      showMessage(
        context,
        'O módulo solicitado não foi encontrado.',
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return LessonHistoryPage(
            moduleId: module.id,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<LearningModule> modules =
        moduleStore.modules;

    final LearningModule? selectedModule =
    _selectedModuleId == null
        ? (modules.isEmpty ? null : modules.first)
        : moduleStore.findModule(
      _selectedModuleId!,
    );

    final List<ExerciseModel> selectedExercises =
    selectedModule == null
        ? <ExerciseModel>[]
        : _activeExercisesFor(selectedModule);

    final int totalLessons =
        selectedExercises.length;

    final int completedLessons =
    selectedModule == null
        ? 0
        : progressStore.completedCount(
      moduleId: selectedModule.id,
      exercises: selectedExercises,
    );

    final double moduleProgress =
    totalLessons == 0
        ? 0
        : completedLessons / totalLessons;

    return Scaffold(
      backgroundColor: const Color(0xFF0A2826),
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 520,
          ),
          color: backgroundColor,
          child: SafeArea(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // ==================================================
                  // CABEÇALHO
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 22, 20, 20),
                    child: Row(
                      children: [
                        const CodeSproutLogo(),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Container(
                            height: 92,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              color: const Color(0xFF102F2D),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: borderColor,
                                width: 1,
                              ),
                            ),
                            child: const Text(
                              'Bem-vindo de volta!',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 29,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // MENU HOME / PERFIL
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Row(
                      children: [
                        Expanded(
                          child: MenuButton(
                            label: 'HOME',
                            selected: true,
                            onTap: () {
                              showMessage(
                                context,
                                'Você já está na tela inicial.',
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: MenuButton(
                            label: 'PERFIL',
                            selected: false,
                            onTap: () {
                              Navigator.of(context).push(
                                PageRouteBuilder<void>(
                                  transitionDuration: const Duration(milliseconds: 180),
                                  reverseTransitionDuration: Duration.zero,
                                  pageBuilder: (
                                      BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation,
                                      ) {
                                    return const ProfilePage();
                                  },
                                  transitionsBuilder: (
                                      BuildContext context,
                                      Animation<double> animation,
                                      Animation<double> secondaryAnimation,
                                      Widget child,
                                      ) {
                                    return FadeTransition(
                                      opacity: CurvedAnimation(
                                        parent: animation,
                                        curve: Curves.easeOut,
                                      ),
                                      child: child,
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  Container(
                    height: 5,
                    color: borderColor,
                    child: Row(
                      children: [
                        Expanded(
                          flex: 4,
                          child: Container(
                            decoration: BoxDecoration(
                              color: greenColor,
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                        const Expanded(
                          flex: 6,
                          child: SizedBox(),
                        ),
                      ],
                    ),
                  ),

                  // =================================================
                  // MENSAGEM DE CONTINUE APRENDENDO
                  // ==================================================

                  const Padding(
                    padding: EdgeInsets.fromLTRB(26, 28, 26, 18),
                    child: Text(
                      'Continue aprendendo',
                      style: TextStyle(
                        color: greenColor,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            onTap: modules.length > 1
                                ? () {
                              _showModuleSelector();
                            }
                                : null,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: <Widget>[
                                Flexible(
                                  child: Text(
                                    selectedModule?.title ??
                                        'Nenhum módulo',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      color: whiteColor,
                                      fontSize: 32,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                ),
                                if (modules.length > 1) ...<Widget>[
                                  const SizedBox(width: 10),
                                  const Icon(
                                    Icons.keyboard_arrow_down_rounded,
                                    color: greenColor,
                                    size: 32,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),

                        SizedBox(
                          width: 70,
                          height: 70,
                          child: AppButton(
                            padding: EdgeInsets.zero,
                            onTap: () {
                              showMessage(
                                context,
                                'Configurações do módulo.',
                              );
                            },
                            child: const Icon(
                              Icons.settings,
                              color: whiteColor,
                              size: 44,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // ==================================================
                  // CARD PRINCIPAL
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 28,
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          if (selectedModule == null) {
                            showMessage(
                              context,
                              'Nenhum módulo está disponível.',
                            );
                            return;
                          }

                          openModule(
                            context,
                            selectedModule.id,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(25),
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment:
                            CrossAxisAlignment.start,
                            children: <Widget>[
                              Row(
                                children: <Widget>[
                                  Expanded(
                                    child: Text(
                                      selectedModule?.subject ??
                                          'Nenhum módulo disponível',
                                      style: const TextStyle(
                                        color: whiteColor,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),
                                  const Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: whiteColor,
                                    size: 34,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 25),
                              ClipRRect(
                                borderRadius:
                                BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: moduleProgress,
                                  minHeight: 15,
                                  backgroundColor:
                                  const Color(0xFF12423F),
                                  valueColor:
                                  const AlwaysStoppedAnimation<Color>(
                                    greenColor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(moduleProgress * 100).round()}%',
                                  style: const TextStyle(
                                    color: Color(0xFFAFC7C5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  // ==================================================
                  // LIÇÕES E DESAFIOS
                  // ==================================================

                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Row(
                      children: [
                        Expanded(
                          child: InformationCard(
                            title: 'Lições',
                            placeholder:
                            '$completedLessons / $totalLessons',
                            onTap: () {
                              if (selectedModule == null) {
                                showMessage(
                                  context,
                                  'Nenhum módulo está disponível.',
                                );
                                return;
                              }

                              openLessonHistory(
                                context,
                                selectedModule.id,
                              );
                            },
                          ),
                        ),

                        const SizedBox(width: 20),

                        Expanded(
                          child: InformationCard(
                            title: 'Desafios',
                            placeholder: '—',
                            onTap: () {
                              showMessage(
                                context,
                                'Área de desafios.',
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ==================================================
                  // CONQUISTAS
                  // ==================================================

                  const Padding(
                    padding: EdgeInsets.fromLTRB(28, 35, 28, 17),
                    child: Text(
                      'Conquistas',
                      style: TextStyle(
                        color: whiteColor,
                        fontSize: 31,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(28, 0, 28, 40),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          showMessage(
                            context,
                            'Área de conquistas.',
                          );
                        },
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            color: cardColor,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: borderColor,
                            ),
                          ),
                          child: const Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              AchievementPlaceholder(
                                icon: Icons.emoji_events_outlined,
                              ),

                              AchievementPlaceholder(
                                icon: Icons.workspace_premium_outlined,
                              ),

                              AchievementPlaceholder(
                                icon: Icons.handshake_outlined,
                              ),

                              AchievementPlaceholder(
                                icon: Icons.calendar_month_outlined,
                              ),

                              Icon(
                                Icons.arrow_forward_ios_rounded,
                                color: whiteColor,
                                size: 34,
                              ),
                            ],
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
      ),
    );
  }
}

// ============================================================
// LOGO PROVISÓRIA
// ============================================================

class CodeSproutLogo extends StatelessWidget {
  const CodeSproutLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF075F46),
        border: Border.all(
          color: const Color(0xFF00F779),
          width: 2,
        ),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            child: Icon(
              Icons.eco,
              color: Color(0xFF9EFF75),
              size: 39,
            ),
          ),

          Positioned(
            bottom: 8,
            child: Text(
              'CS',
              style: TextStyle(
                color: Color(0xFF00F779),
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOTÃO HOME / PERFIL
// ============================================================

class MenuButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const MenuButton({
    super.key,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF00F779)
                    : const Color(0xFFEAF6F4),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BOTÃO PADRÃO
// ============================================================

class AppButton extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;

  const AppButton({
    super.key,
    required this.child,
    required this.onTap,
    this.padding = const EdgeInsets.symmetric(
      vertical: 14,
      horizontal: 20,
    ),
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF163F3B),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: const Color(0xFF087B50),
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

// ============================================================
// CARD LIÇÕES / DESAFIOS
// ============================================================

class InformationCard extends StatelessWidget {
  final String title;
  final String placeholder;
  final VoidCallback onTap;

  const InformationCard({
    super.key,
    required this.title,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 145,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF184B47),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: const Color(0xFF087B50),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Color(0xFFF4F4F4),
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const Spacer(),

              Center(
                child: Text(
                  placeholder,
                  style: const TextStyle(
                    color: Color(0xFF00F779),
                    fontSize: 43,
                    fontWeight: FontWeight.bold,
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

// ============================================================
// CONQUISTAS PROVISÓRIAS
// ============================================================

class AchievementPlaceholder extends StatelessWidget {
  final IconData icon;

  const AchievementPlaceholder({
    super.key,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      icon,
      size: 42,
      color: const Color(0xFF00F779),
    );
  }
}
