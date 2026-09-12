import 'package:flutter/material.dart';

import 'data/app_data.dart';
import 'models/exercise_model.dart';
import 'models/learning_module.dart';
import 'models/diagram_model.dart';
import 'exercise_board_workspace_page.dart';

class CreateExercisePage extends StatefulWidget {
  const CreateExercisePage({super.key});

  @override
  State<CreateExercisePage> createState() =>
      _CreateExercisePageState();
}

class _CreateExercisePageState extends State<CreateExercisePage> {
  static const Color _pageBackground = Color(0xFF0A2826);
  static const Color _background = Color(0xFF123D39);
  static const Color _panel = Color(0xFF184B47);
  static const Color _green = Color(0xFF00F779);
  static const Color _white = Color(0xFFF7F7F2);
  static const Color _border = Color(0xFF087B50);

  static const String _createModuleValue =
      '__create_new_module__';

  final GlobalKey<FormState> _formKey =
  GlobalKey<FormState>();

  List<BoardElement> _boardElements = <BoardElement>[];

  List<ExerciseAlternative> _alternatives =
  <ExerciseAlternative>[];

  Map<String, String> _answerPlacements =
  <String, String>{};

  final TextEditingController _statementController =
  TextEditingController();

  final TextEditingController _hintController =
  TextEditingController();

  final TextEditingController _subjectController =
  TextEditingController();

  final TextEditingController _authorController =
  TextEditingController(text: 'Administrador');

  final TextEditingController _languageController =
  TextEditingController();

  String? _selectedModuleId;

  ExerciseType _selectedType =
      ExerciseType.dragLabelsToDiagram;

  ExerciseDifficulty _selectedDifficulty =
      ExerciseDifficulty.beginner;

  bool _languageEnabled = false;
  bool _contentVisible = false;

  int get _nextExerciseOrder {
    final String? moduleId = _selectedModuleId;

    if (moduleId == null) {
      return 1;
    }

    final LearningModule? selectedModule =
    moduleStore.findModule(moduleId);

    if (selectedModule == null) {
      return 1;
    }

    int nextOrder = 1;

    for (final ExerciseModel exercise
    in selectedModule.exercises) {
      if (exercise.order >= nextOrder) {
        nextOrder = exercise.order + 1;
      }
    }

    return nextOrder;
  }

  String get _automaticLessonTitle {
    return 'Lição $_nextExerciseOrder';
  }

  @override
  void initState() {
    super.initState();

    final List<LearningModule> modules =
        moduleStore.modules;

    if (modules.isNotEmpty) {
      _selectedModuleId = modules.first.id;
      _subjectController.text = modules.first.subject;
    }

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
    _statementController.dispose();
    _hintController.dispose();
    _subjectController.dispose();
    _authorController.dispose();
    _languageController.dispose();

    super.dispose();
  }

  void _selectModule(String? moduleId) {
    if (moduleId == null) {
      return;
    }

    if (moduleId == _createModuleValue) {
      _showCreateModuleDialog();
      return;
    }

    final LearningModule? module =
    moduleStore.findModule(moduleId);

    setState(() {
      _selectedModuleId = moduleId;

      if (module != null) {
        _subjectController.text = module.subject;
      }
    });
  }

  Future<void> _showCreateModuleDialog() async {
    final GlobalKey<FormState> dialogFormKey =
    GlobalKey<FormState>();

    final TextEditingController titleController =
    TextEditingController();

    final TextEditingController descriptionController =
    TextEditingController();

    final TextEditingController subjectController =
    TextEditingController(
      text: 'Lógica de Programação',
    );

    final LearningModule? createdModule =
    await showDialog<LearningModule>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          backgroundColor: _panel,
          title: const Text(
            'Criar novo módulo',
            style: TextStyle(
              color: _white,
              fontWeight: FontWeight.w900,
            ),
          ),
          content: SizedBox(
            width: 420,
            child: Form(
              key: dialogFormKey,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    TextFormField(
                      controller: titleController,
                      style: const TextStyle(
                        color: _white,
                      ),
                      decoration: _inputDecoration(
                        label: 'Nome do módulo',
                        hint: 'Exemplo: Módulo 2',
                      ),
                      validator: (String? value) {
                        final String name =
                            value?.trim() ?? '';

                        if (name.isEmpty) {
                          return 'Informe o nome do módulo.';
                        }

                        final bool alreadyExists =
                        moduleStore.modules.any(
                              (LearningModule module) {
                            return module.title
                                .trim()
                                .toLowerCase() ==
                                name.toLowerCase();
                          },
                        );

                        if (alreadyExists) {
                          return 'Já existe um módulo com esse nome.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: subjectController,
                      style: const TextStyle(
                        color: _white,
                      ),
                      decoration: _inputDecoration(
                        label: 'Assunto',
                        hint: 'Lógica de Programação',
                      ),
                      validator: _requiredValidator,
                    ),
                    const SizedBox(height: 15),
                    TextFormField(
                      controller: descriptionController,
                      maxLines: 3,
                      style: const TextStyle(
                        color: _white,
                      ),
                      decoration: _inputDecoration(
                        label: 'Descrição',
                        hint:
                        'Descreva os conteúdos do módulo.',
                      ),
                      validator: _requiredValidator,
                    ),
                  ],
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
                if (!(dialogFormKey.currentState
                    ?.validate() ??
                    false)) {
                  return;
                }

                int nextOrder = 1;

                for (
                final LearningModule module
                in moduleStore.modules
                ) {
                  if (module.order >= nextOrder) {
                    nextOrder = module.order + 1;
                  }
                }

                final LearningModule newModule =
                LearningModule(
                  id: moduleStore.createId('module'),
                  title: titleController.text.trim(),
                  description:
                  descriptionController.text.trim(),
                  subject: subjectController.text.trim(),
                  order: nextOrder,
                  exercises:
                  const <ExerciseModel>[],
                );

                Navigator.of(dialogContext).pop(
                  newModule,
                );
              },
              child: const Text(
                'Criar módulo',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ],
        );
      },
    );

    titleController.dispose();
    descriptionController.dispose();
    subjectController.dispose();

    if (!mounted || createdModule == null) {
      return;
    }

    moduleStore.addModule(createdModule);

    setState(() {
      _selectedModuleId = createdModule.id;
      _subjectController.text =
          createdModule.subject;
    });

    _showMessage(
      'O módulo "${createdModule.title}" foi criado.',
    );
  }

  void _saveExercise() {
    FocusScope.of(context).unfocus();

    final bool valid =
        _formKey.currentState?.validate() ?? false;

    if (!valid) {
      _showMessage(
        'Preencha corretamente os campos obrigatórios.',
        isError: true,
      );
      return;
    }

    final String? moduleId = _selectedModuleId;

    if (moduleId == null) {
      _showMessage(
        'Selecione ou crie um módulo.',
        isError: true,
      );
      return;
    }

    if (_boardElements.isEmpty) {
      _showMessage(
        'Adicione pelo menos uma forma ao quadro.',
        isError: true,
      );
      return;
    }

    final List<BoardElement> boardTargets =
    _boardElements.where((BoardElement element) {
      return element.type ==
          BoardElementType.flowchartShape &&
          element.acceptsDrop;
    }).toList();

    if (boardTargets.isEmpty) {
      _showMessage(
        'O quadro precisa possuir pelo menos uma '
            'forma que aceite respostas.',
        isError: true,
      );
      return;
    }

    if (_alternatives.isEmpty) {
      _showMessage(
        'Cadastre pelo menos uma alternativa.',
        isError: true,
      );
      return;
    }

    final bool incompleteAnswerKey =
    boardTargets.any((BoardElement element) {
      return !_answerPlacements.containsKey(element.id);
    });

    if (incompleteAnswerKey) {
      _showMessage(
        'Selecione a resposta correta para todas '
            'as formas do quadro.',
        isError: true,
      );
      return;
    }

    final Set<String> alternativeIds = _alternatives
        .map((ExerciseAlternative alternative) {
      return alternative.id;
    }).toSet();

    final bool hasInvalidAnswer =
    _answerPlacements.values.any((String alternativeId) {
      return !alternativeIds.contains(alternativeId);
    });

    if (hasInvalidAnswer) {
      _showMessage(
        'O gabarito contém uma alternativa inválida.',
        isError: true,
      );
      return;
    }

    // A ordem é calculada antes da inclusão no módulo.
    final int exerciseOrder = _nextExerciseOrder;

    final ExerciseModel newExercise = ExerciseModel(
      id: moduleStore.createId('exercise'),
      moduleId: moduleId,

      // O título existe apenas para organização interna.
      title: _automaticLessonTitle,

      statement: _statementController.text.trim(),
      hint: _hintController.text.trim(),
      subject: _subjectController.text.trim(),
      programmingLanguage: _languageEnabled
          ? _languageController.text.trim()
          : null,
      author: _authorController.text.trim(),
      order: exerciseOrder,
      type: _selectedType,
      difficulty: _selectedDifficulty,

      board: ExerciseBoard(
        logicalWidth: 1000,
        logicalHeight: 700,
        showGrid: false,
        allowElementMovement: false,
        allowConnections: false,
        elements: List<BoardElement>.unmodifiable(
          _boardElements,
        ),
        connections: const <BoardConnection>[],
      ),

      alternatives:
      List<ExerciseAlternative>.unmodifiable(
        _alternatives,
      ),

      answerKey: ExerciseAnswerKey(
        placements: Map<String, String>.unmodifiable(
          _answerPlacements,
        ),
      ),

      positiveFeedback:
      'Excelente! Você acertou a atividade!',
      negativeFeedback:
      'Que pena! Revise a atividade e tente novamente.',
    );

    moduleStore.addExercise(
      moduleId: moduleId,
      exercise: newExercise,
    );

    _showMessage(
      '${newExercise.title} cadastrada com sucesso.',
    );

    Future<void>.delayed(
      const Duration(milliseconds: 900),
          () {
        if (!mounted) {
          return;
        }

        Navigator.of(context).pop(newExercise);
      },
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

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo é obrigatório.';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(
            maxWidth: 620,
          ),
          color: _background,
          child: SafeArea(
            child: AnimatedOpacity(
              opacity: _contentVisible ? 1 : 0,
              duration:
              const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              child: Column(
                children: <Widget>[
                  _buildHeader(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding:
                      const EdgeInsets.fromLTRB(
                        24,
                        25,
                        24,
                        38,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.stretch,
                          children: <Widget>[
                            const Text(
                              'Nova questão',
                              style: TextStyle(
                                color: _green,
                                fontSize: 28,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Defina as informações básicas da atividade.',
                              style: TextStyle(
                                color: _white.withValues(
                                  alpha: 0.7,
                                ),
                                fontSize: 15,
                              ),
                            ),
                            const SizedBox(height: 27),
                            _buildSectionTitle(
                              'Identificação',
                              Icons.assignment_outlined,
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              controller: _statementController,
                              label: 'Enunciado',
                              hint: 'Informe o comando da questão.',
                              maxLines: 4,
                            ),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller:
                              _hintController,
                              label: 'Dica',
                              hint:
                              'Escreva uma orientação para o aluno.',
                              maxLines: 3,
                            ),
                            const SizedBox(height: 28),
                            _buildSectionTitle(
                              'Classificação',
                              Icons.category_outlined,
                            ),
                            const SizedBox(height: 14),
                            _buildModuleSelector(),
                            const SizedBox(height: 16),
                            _buildTextField(
                              controller:
                              _subjectController,
                              label: 'Assunto',
                              hint:
                              'Lógica de Programação',
                            ),
                            const SizedBox(height: 16),
                            _buildExerciseTypeSelector(),
                            const SizedBox(height: 16),
                            _buildDifficultySelector(),
                            const SizedBox(height: 28),
                            _buildSectionTitle(
                              'Responsável',
                              Icons.person_outline_rounded,
                            ),
                            const SizedBox(height: 14),
                            _buildTextField(
                              controller:
                              _authorController,
                              label: 'Professor ou autor',
                              hint:
                              'Nome do responsável pela questão.',
                            ),
                            const SizedBox(height: 18),
                            _buildLanguageSection(),
                            const SizedBox(height: 30),
                            _buildBoardWorkspaceCard(),
                            const SizedBox(height: 28),
                            Row(
                              children: <Widget>[
                                Expanded(
                                  child: _SecondaryButton(
                                    text: 'Cancelar',
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop();
                                    },
                                  ),
                                ),
                                const SizedBox(width: 15),
                                Expanded(
                                  child: _PrimaryButton(
                                    text: 'Salvar',
                                    icon: Icons.save_rounded,
                                    onPressed: _saveExercise,
                                  ),
                                ),
                              ],
                            ),
                          ],
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

  Widget _buildHeader() {
    return Container(
      height: 88,
      padding: const EdgeInsets.symmetric(
        horizontal: 18,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF102F2D),
        border: Border(
          bottom: BorderSide(
            color: _border,
            width: 2,
          ),
        ),
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
                child: Icon(
                  Icons.arrow_back_rounded,
                  color: _white,
                  size: 31,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 51,
            height: 51,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF075F46),
              border: Border.all(
                color: _green,
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.eco_rounded,
              color: Color(0xFF9EFF75),
              size: 32,
            ),
          ),
          const SizedBox(width: 13),
          const Expanded(
            child: Text(
              'Cadastrar questão',
              style: TextStyle(
                color: _white,
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(
      String title,
      IconData icon,
      ) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: _green,
          size: 25,
        ),
        const SizedBox(width: 9),
        Text(
          title,
          style: const TextStyle(
            color: _white,
            fontSize: 21,
            fontWeight: FontWeight.w900,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(
        color: _white,
        fontWeight: FontWeight.w600,
      ),
      decoration: _inputDecoration(
        label: label,
        hint: hint,
      ),
      validator: _requiredValidator,
    );
  }

  Widget _buildModuleSelector() {
    final List<LearningModule> modules =
        moduleStore.modules;

    return DropdownButtonFormField<String>(
      key: ValueKey<String?>(_selectedModuleId),
      initialValue: _selectedModuleId,
      isExpanded: true,
      dropdownColor: _panel,
      style: const TextStyle(
        color: _white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(
        label: 'Módulo',
        hint: 'Selecione um módulo',
      ),
      items: <DropdownMenuItem<String>>[
        for (final LearningModule module in modules)
          DropdownMenuItem<String>(
            value: module.id,
            child: Text(
              module.title,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        const DropdownMenuItem<String>(
          value: _createModuleValue,
          child: Row(
            children: <Widget>[
              Icon(
                Icons.add_circle_outline_rounded,
                color: _green,
              ),
              SizedBox(width: 9),
              Text(
                'Criar novo módulo',
                style: TextStyle(
                  color: _green,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ],
      onChanged: _selectModule,
      validator: (String? value) {
        if (value == null ||
            value == _createModuleValue) {
          return 'Selecione ou crie um módulo.';
        }

        return null;
      },
    );
  }

  Widget _buildExerciseTypeSelector() {
    return DropdownButtonFormField<ExerciseType>(
      initialValue: _selectedType,
      isExpanded: true,
      dropdownColor: _panel,
      style: const TextStyle(
        color: _white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(
        label: 'Tipo de atividade',
        hint: 'Selecione o tipo',
      ),
      items: ExerciseType.values.map(
            (ExerciseType type) {
          return DropdownMenuItem<ExerciseType>(
            value: type,
            child: Text(
              _exerciseTypeLabel(type),
              overflow: TextOverflow.ellipsis,
            ),
          );
        },
      ).toList(),
      onChanged: (ExerciseType? value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedType = value;
        });
      },
    );
  }

  Widget _buildDifficultySelector() {
    return DropdownButtonFormField<ExerciseDifficulty>(
      initialValue: _selectedDifficulty,
      isExpanded: true,
      dropdownColor: _panel,
      style: const TextStyle(
        color: _white,
        fontSize: 15,
        fontWeight: FontWeight.w700,
      ),
      decoration: _inputDecoration(
        label: 'Dificuldade',
        hint: 'Selecione a dificuldade',
      ),
      items: ExerciseDifficulty.values.map(
            (ExerciseDifficulty difficulty) {
          return DropdownMenuItem<ExerciseDifficulty>(
            value: difficulty,
            child: Text(
              _difficultyLabel(difficulty),
            ),
          );
        },
      ).toList(),
      onChanged: (ExerciseDifficulty? value) {
        if (value == null) {
          return;
        }

        setState(() {
          _selectedDifficulty = value;
        });
      },
    );
  }

  Widget _buildLanguageSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _panel,
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: _border),
      ),
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Switch.adaptive(
                value: _languageEnabled,
                activeTrackColor: _green,
                onChanged: (bool value) {
                  setState(() {
                    _languageEnabled = value;

                    if (!value) {
                      _languageController.clear();
                    }
                  });
                },
              ),
              const SizedBox(width: 9),
              const Expanded(
                child: Text(
                  'Vincular linguagem de programação',
                  style: TextStyle(
                    color: _white,
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          if (_languageEnabled) ...<Widget>[
            const SizedBox(height: 13),
            TextFormField(
              controller: _languageController,
              style: const TextStyle(color: _white),
              decoration: _inputDecoration(
                label: 'Linguagem',
                hint: 'Exemplo: Python',
              ),
              validator: (String? value) {
                if (!_languageEnabled) {
                  return null;
                }

                return _requiredValidator(value);
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _openBoardWorkspace() async {
    FocusScope.of(context).unfocus();

    final ExerciseBoardWorkspaceResult? result =
    await Navigator.of(context)
        .push<ExerciseBoardWorkspaceResult>(
      MaterialPageRoute<ExerciseBoardWorkspaceResult>(
        builder: (BuildContext context) {
          return ExerciseBoardWorkspacePage(
            initialElements: _boardElements,
            initialAlternatives: _alternatives,
            initialPlacements: _answerPlacements,
          );
        },
      ),
    );

    if (!mounted || result == null) {
      return;
    }

    setState(() {
      _boardElements =
      List<BoardElement>.from(result.elements);

      _alternatives =
      List<ExerciseAlternative>.from(
        result.alternatives,
      );

      _answerPlacements =
      Map<String, String>.from(
        result.placements,
      );
    });

    _showMessage(
      'Quadro e gabarito atualizados.',
    );
  }

  Widget _buildBoardWorkspaceCard() {
    final int targetCount = _boardElements.where(
          (BoardElement element) {
        return element.type ==
            BoardElementType.flowchartShape;
      },
    ).length;

    final int answeredCount = _boardElements.where(
          (BoardElement element) {
        return element.type ==
            BoardElementType.flowchartShape &&
            _answerPlacements.containsKey(element.id);
      },
    ).length;

    final bool configured =
        targetCount > 0 &&
            _alternatives.isNotEmpty &&
            answeredCount == targetCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: <Widget>[
        _buildSectionTitle(
          'Quadro da atividade',
          Icons.account_tree_outlined,
        ),
        const SizedBox(height: 14),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: _openBoardWorkspace,
            borderRadius: BorderRadius.circular(15),
            child: Ink(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: _panel,
                borderRadius: BorderRadius.circular(15),
                border: Border.all(
                  color: configured ? _green : _border,
                  width: configured ? 2 : 1.5,
                ),
              ),
              child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 55,
                        height: 55,
                        decoration: BoxDecoration(
                          color: _green.withValues(
                            alpha: 0.12,
                          ),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _green,
                          ),
                        ),
                        child: Icon(
                          configured
                              ? Icons.check_rounded
                              : Icons.edit_outlined,
                          color: _green,
                          size: 29,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                          CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              configured
                                  ? 'Quadro configurado'
                                  : 'Toque para montar o quadro',
                              style: const TextStyle(
                                color: _white,
                                fontSize: 17,
                                fontWeight:
                                FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              configured
                                  ? 'Toque para continuar editando.'
                                  : 'Adicione formas, textos e respostas.',
                              style: TextStyle(
                                color: _white.withValues(
                                  alpha: 0.62,
                                ),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_ios_rounded,
                        color: _green,
                        size: 21,
                      ),
                    ],
                  ),
                  const SizedBox(height: 17),
                  Row(
                    children: <Widget>[
                      Expanded(
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF104B50),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${_boardElements.length}',
                                style: const TextStyle(
                                  color: _green,
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),
                              Text(
                                _boardElements.length == 1
                                    ? 'elemento'
                                    : 'elementos',
                                style: TextStyle(
                                  color: _white.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF104B50),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '${_alternatives.length}',
                                style: const TextStyle(
                                  color: _green,
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),
                              Text(
                                _alternatives.length == 1
                                    ? 'alternativa'
                                    : 'alternativas',
                                style: TextStyle(
                                  color: _white.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Container(
                          padding:
                          const EdgeInsets.symmetric(
                            vertical: 11,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF104B50),
                            borderRadius:
                            BorderRadius.circular(10),
                          ),
                          child: Column(
                            children: <Widget>[
                              Text(
                                '$answeredCount/$targetCount',
                                style: const TextStyle(
                                  color: _green,
                                  fontSize: 20,
                                  fontWeight:
                                  FontWeight.w900,
                                ),
                              ),
                              Text(
                                'gabarito',
                                style: TextStyle(
                                  color: _white.withValues(
                                    alpha: 0.62,
                                  ),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _exerciseTypeLabel(ExerciseType type) {
    switch (type) {
      case ExerciseType.dragLabelsToDiagram:
        return 'Arrastar rótulos para o diagrama';
      case ExerciseType.buildFlowchart:
        return 'Construir fluxograma';
      case ExerciseType.multipleChoice:
        return 'Múltipla escolha';
      case ExerciseType.orderBlocks:
        return 'Ordenar blocos';
      case ExerciseType.completeDiagram:
        return 'Completar diagrama';
    }
  }

  String _difficultyLabel(
      ExerciseDifficulty difficulty,
      ) {
    switch (difficulty) {
      case ExerciseDifficulty.beginner:
        return 'Iniciante';
      case ExerciseDifficulty.intermediate:
        return 'Intermediário';
      case ExerciseDifficulty.advanced:
        return 'Avançado';
    }
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      labelStyle: const TextStyle(
        color: _green,
        fontWeight: FontWeight.w800,
      ),
      hintStyle: TextStyle(
        color: _white.withValues(alpha: 0.38),
      ),
      filled: true,
      fillColor: const Color(0xFF104B50),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 16,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _border,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: _green,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFFF6B6B),
        ),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: Color(0xFFFF6B6B),
          width: 2,
        ),
      ),
    );
  }
}

class _PrimaryButton extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;

  const _PrimaryButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return FilledButton.icon(
      onPressed: onPressed,
      icon: Icon(icon),
      label: Text(text),
      style: FilledButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        backgroundColor: const Color(0xFF00F779),
        foregroundColor: const Color(0xFF104B50),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(
            color: Color(0xFFF7F7F2),
            width: 4,
          ),
        ),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(58),
        foregroundColor: const Color(0xFFF7F7F2),
        textStyle: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
        side: const BorderSide(
          color: Color(0xFFF7F7F2),
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(text),
    );
  }
}