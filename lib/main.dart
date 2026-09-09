import 'package:flutter/material.dart';

import 'data/app_data.dart';
import 'exercise_page.dart';
import 'lesson_history_page.dart';
import 'login_page.dart';
import 'models/exercise_model.dart';
import 'module_completed_page.dart';
import 'profile_page.dart';

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

  @override
  void initState() {
    super.initState();
    progressStore.addListener(_refreshProgress);
  }

  @override
  void dispose() {
    progressStore.removeListener(_refreshProgress);
    super.dispose();
  }

  void _refreshProgress() {
    if (!mounted) {
      return;
    }

    setState(() {});
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
    final module1 = moduleStore.findModule('module-1');

    final List<ExerciseModel> module1Exercises =
    module1 == null
        ? <ExerciseModel>[]
        : (module1.exercises
        .where(
          (ExerciseModel exercise) =>
      exercise.isActive,
    )
        .toList()
      ..sort(
            (
            ExerciseModel first,
            ExerciseModel second,
            ) {
          return first.order.compareTo(second.order);
        },
      ));

    final int module1TotalLessons =
        module1Exercises.length;

    final int module1CompletedLessons =
    module1 == null
        ? 0
        : progressStore.completedCount(
      moduleId: module1.id,
      exercises: module1Exercises,
    );

    final double module1Progress =
    module1TotalLessons == 0
        ? 0
        : module1CompletedLessons /
        module1TotalLessons;

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
                            onTap: () {
                              openModule(context, 'module-1');
                            },
                            child: Text(
                              module1?.title ?? 'Módulo 1',
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                              ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 28),
                    child: Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () {
                          openModule(context, 'module-1');
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
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Lógica de Programação',
                                      style: TextStyle(
                                        color: whiteColor,
                                        fontSize: 25,
                                        fontWeight: FontWeight.w900,
                                      ),
                                    ),
                                  ),

                                  Icon(
                                    Icons.arrow_forward_ios_rounded,
                                    color: whiteColor,
                                    size: 34,
                                  ),
                                ],
                              ),

                              const SizedBox(height: 25),

                              ClipRRect(
                                borderRadius: BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: module1Progress,
                                  minHeight: 15,
                                  backgroundColor: const Color(0xFF12423F),
                                  valueColor: const AlwaysStoppedAnimation<Color>(
                                    greenColor,
                                  ),
                                ),
                              ),

                              const SizedBox(height: 12),

                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  '${(module1Progress * 100).round()}%',
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
                            '$module1CompletedLessons / $module1TotalLessons',
                            onTap: () {
                              openLessonHistory(
                                context,
                                'module-1',
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
  final VoidCallback onTap;
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
