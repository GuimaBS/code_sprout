import 'package:flutter/material.dart';

class AdminPage extends StatelessWidget {
  final WidgetBuilder homeBuilder;

  const AdminPage({
    super.key,
    required this.homeBuilder,
  });

  static const Color _pageBackground = Color(0xFF0A2826);
  static const Color _background = Color(0xFF123D39);
  static const Color _panel = Color(0xFF184B47);
  static const Color _green = Color(0xFF00F779);
  static const Color _white = Color(0xFFF7F7F2);

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(milliseconds: 1700),
          backgroundColor: const Color(0xFF173F3C),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          color: _background,
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 34),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildHeader(context),
                  const SizedBox(height: 30),
                  const Text(
                    'O que deseja fazer?',
                    style: TextStyle(
                      color: _green,
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Escolha uma área para continuar a construção do protótipo.',
                    style: TextStyle(
                      color: _white.withValues(alpha: 0.73),
                      fontSize: 15,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _AdminOptionCard(
                    icon: Icons.add_task_rounded,
                    title: 'Criar questões',
                    description:
                    'Cadastre comandos, opções, gabaritos e dicas dos exercícios.',
                    onTap: () {
                      _showMessage(
                        context,
                        'O editor de questões será construído na próxima etapa.',
                      );
                    },
                  ),
                  const SizedBox(height: 18),
                  _AdminOptionCard(
                    icon: Icons.play_lesson_outlined,
                    title: 'Acessar exercícios',
                    description:
                    'Abra a área do estudante e visualize a Home do CodeSprout.',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(builder: homeBuilder),
                      );
                    },
                  ),
                  const SizedBox(height: 27),
                  Container(
                    padding: const EdgeInsets.all(17),
                    decoration: BoxDecoration(
                      color: const Color(0xFF102F2D),
                      borderRadius: BorderRadius.circular(13),
                      border: Border.all(
                        color: _green.withValues(alpha: 0.38),
                      ),
                    ),
                    child: const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Icon(
                          Icons.info_outline_rounded,
                          color: _green,
                          size: 27,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Este painel é demonstrativo. Novas ferramentas '
                                'administrativas poderão ser adicionadas sem alterar '
                                'a experiência do estudante.',
                            style: TextStyle(
                              color: _white,
                              fontSize: 14,
                              height: 1.4,
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
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: <Widget>[
        const _AdminLogo(),
        const SizedBox(width: 14),
        Expanded(
          child: Container(
            height: 88,
            alignment: Alignment.center,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF102F2D),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF087B50)),
            ),
            child: const Text(
              'Painel de Administração',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: _white,
                fontSize: 22,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        PopupMenuButton<String>(
          tooltip: 'Mais opções',
          color: const Color(0xFF173F3C),
          icon: const Icon(Icons.more_vert, color: _white, size: 31),
          onSelected: (String value) {
            if (value == 'logout') {
              Navigator.of(context).pop();
            } else {
              _showMessage(
                context,
                'As configurações serão adicionadas posteriormente.',
              );
            }
          },
          itemBuilder: (BuildContext context) => const <PopupMenuEntry<String>>[
            PopupMenuItem<String>(
              value: 'settings',
              child: Text('Configurações'),
            ),
            PopupMenuItem<String>(
              value: 'logout',
              child: Text('Sair'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AdminOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _AdminOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AdminPage._panel,
      borderRadius: BorderRadius.circular(15),
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFF00F779).withValues(alpha: 0.10),
        splashColor: const Color(0xFF00F779).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(15),
        child: Container(
          constraints: const BoxConstraints(minHeight: 148),
          padding: const EdgeInsets.all(21),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: const Color(0xFF087B50)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F779).withValues(alpha: 0.13),
                  borderRadius: BorderRadius.circular(17),
                  border: Border.all(color: const Color(0xFF00F779)),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF00F779),
                  size: 43,
                ),
              ),
              const SizedBox(width: 17),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF7F7F2),
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 7),
                    Text(
                      description,
                      style: TextStyle(
                        color: const Color(0xFFF7F7F2).withValues(alpha: 0.72),
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFF7F7F2),
                size: 27,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _AdminLogo extends StatelessWidget {
  const _AdminLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 76,
      height: 76,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF075F46),
        border: Border.all(color: const Color(0xFF00F779), width: 2),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 6,
            child: Icon(Icons.eco, color: Color(0xFF9EFF75), size: 37),
          ),
          Positioned(
            bottom: 7,
            child: Text(
              'CS',
              style: TextStyle(
                color: Color(0xFF00F779),
                fontSize: 23,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
