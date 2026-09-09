import 'package:flutter/material.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  static const Color _pageBackground = Color(0xFF0A2826);
  static const Color _background = Color(0xFF123D39);
  static const Color _card = Color(0xFF184B47);
  static const Color _darkCard = Color(0xFF102F2D);
  static const Color _border = Color(0xFF087B50);
  static const Color _green = Color(0xFF00F779);
  static const Color _white = Color(0xFFF7F7F2);

  bool _profileSelected = false;
  bool _contentVisible = false;
  bool _leaving = false;

  @override
  void initState() {
    super.initState();

    // O primeiro quadro ainda mostra a faixa sob HOME. No quadro seguinte,
    // a faixa desliza para PERFIL e o conteúdo surge em fade-in.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      setState(() {
        _profileSelected = true;
        _contentVisible = true;
      });
    });
  }

  void _showFutureMessage(String message) {
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(milliseconds: 1700),
          behavior: SnackBarBehavior.floating,
          backgroundColor: const Color(0xFF173F3C),
        ),
      );
  }

  Future<void> _returnToHome() async {
    if (_leaving) return;

    setState(() {
      _leaving = true;
      _contentVisible = false;
      _profileSelected = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 430));
    if (!mounted) return;
    Navigator.of(context).pop();
  }

  Future<void> _logout() async {
    if (_leaving) return;

    setState(() {
      _leaving = true;
      _contentVisible = false;
      _profileSelected = false;
    });

    await Future<void>.delayed(const Duration(milliseconds: 480));
    if (!mounted) return;

    // A primeira rota do protótipo é LoginPage. Esta ação remove Perfil,
    // Home e o Painel administrativo até retornar ao login.
    Navigator.of(context).popUntil((Route<dynamic> route) => route.isFirst);
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
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  _buildHeader(),
                  _buildTabs(),
                  _buildSlidingIndicator(),
                  AnimatedSlide(
                    offset: _contentVisible
                        ? Offset.zero
                        : const Offset(0, 0.035),
                    duration: const Duration(milliseconds: 440),
                    curve: Curves.easeOutCubic,
                    child: AnimatedOpacity(
                      opacity: _contentVisible ? 1 : 0,
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeOut,
                      child: _buildProfileContent(),
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
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 22, 20, 18),
      child: Row(
        children: <Widget>[
          const _ProfileLogo(),
          const SizedBox(width: 14),
          Expanded(
            child: Container(
              height: 92,
              alignment: Alignment.center,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: _darkCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _border),
              ),
              child: const Text(
                'Bem-vindo de volta!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _white,
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Row(
        children: <Widget>[
          Expanded(
            child: _ProfileTabButton(
              label: 'HOME',
              selected: !_profileSelected,
              onTap: _returnToHome,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _ProfileTabButton(
              label: 'PERFIL',
              selected: _profileSelected,
              onTap: () {
                _showFutureMessage('Você já está na tela de perfil.');
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlidingIndicator() {
    return Container(
      height: 6,
      margin: const EdgeInsets.only(top: 8),
      color: _border,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double indicatorWidth = constraints.maxWidth * 0.40;
          final double leftPosition = _profileSelected
              ? constraints.maxWidth * 0.55
              : constraints.maxWidth * 0.05;

          return Stack(
            children: <Widget>[
              AnimatedPositioned(
                duration: const Duration(milliseconds: 430),
                curve: Curves.easeInOutCubic,
                left: leftPosition,
                top: 0,
                width: indicatorWidth,
                height: 6,
                child: Container(
                  decoration: BoxDecoration(
                    color: _green,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: _green.withValues(alpha: 0.32),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildProfileContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(27, 31, 27, 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          const Text(
            'Meu perfil',
            style: TextStyle(
              color: _green,
              fontSize: 30,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 25, 20, 23),
            decoration: BoxDecoration(
              color: _card,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: _border),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 14,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: Column(
              children: <Widget>[
                Stack(
                  clipBehavior: Clip.none,
                  children: <Widget>[
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          _showFutureMessage(
                            'A edição da foto será configurada posteriormente.',
                          );
                        },
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 132,
                          height: 132,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _darkCard,
                            border: Border.all(color: _green, width: 3),
                          ),
                          child: const Icon(
                            Icons.person_outline_rounded,
                            color: _white,
                            size: 83,
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      right: -5,
                      bottom: 4,
                      child: Material(
                        color: _green,
                        shape: const CircleBorder(),
                        child: InkWell(
                          customBorder: const CircleBorder(),
                          onTap: () {
                            _showFutureMessage(
                              'A seleção de imagem será adicionada depois.',
                            );
                          },
                          child: Container(
                            width: 43,
                            height: 43,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(color: _white, width: 3),
                            ),
                            child: const Icon(
                              Icons.photo_camera_outlined,
                              color: Color(0xFF104B50),
                              size: 23,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 19),
                const Text(
                  'Administrador',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _white,
                    fontSize: 25,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Acesso demonstrativo do CodeSprout',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: _white.withValues(alpha: 0.70),
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 17),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: _darkCard,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _green.withValues(alpha: 0.38),
                    ),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Icon(
                        Icons.admin_panel_settings_outlined,
                        color: _green,
                        size: 21,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'Usuário: admin',
                        style: TextStyle(
                          color: _white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          _ProfileOptionCard(
            icon: Icons.settings_outlined,
            title: 'Configurações',
            description: 'Preferências da conta e do aplicativo.',
            onTap: () {
              _showFutureMessage(
                'As configurações serão implementadas posteriormente.',
              );
            },
          ),
          const SizedBox(height: 20),
          Material(
            color: const Color(0xFF7F2926),
            borderRadius: BorderRadius.circular(13),
            child: InkWell(
              onTap: _logout,
              hoverColor: Colors.white.withValues(alpha: 0.12),
              splashColor: Colors.white.withValues(alpha: 0.20),
              borderRadius: BorderRadius.circular(13),
              child: Container(
                height: 62,
                padding: const EdgeInsets.symmetric(horizontal: 18),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(13),
                  border: Border.all(color: const Color(0xFFFFB4AB), width: 1.5),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.logout_rounded, color: _white, size: 27),
                    SizedBox(width: 10),
                    Text(
                      'Deslogar',
                      style: TextStyle(
                        color: _white,
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileTabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ProfileTabButton({
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
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 330),
              curve: Curves.easeInOut,
              style: TextStyle(
                color: selected
                    ? const Color(0xFF00F779)
                    : const Color(0xFFEAF6F4),
                fontSize: 26,
                fontWeight: FontWeight.w900,
              ),
              child: Text(label),
            ),
          ),
        ),
      ),
    );
  }
}

class _ProfileOptionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _ProfileOptionCard({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF184B47),
      borderRadius: BorderRadius.circular(13),
      child: InkWell(
        onTap: onTap,
        hoverColor: const Color(0xFF00F779).withValues(alpha: 0.10),
        splashColor: const Color(0xFF00F779).withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(13),
        child: Container(
          constraints: const BoxConstraints(minHeight: 96),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: const Color(0xFF087B50)),
          ),
          child: Row(
            children: <Widget>[
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: const Color(0xFF00F779).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFF00F779)),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF00F779),
                  size: 33,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      title,
                      style: const TextStyle(
                        color: Color(0xFFF7F7F2),
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      description,
                      style: TextStyle(
                        color: const Color(0xFFF7F7F2).withValues(alpha: 0.70),
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: Color(0xFFF7F7F2),
                size: 25,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ProfileLogo extends StatelessWidget {
  const _ProfileLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF075F46),
        border: Border.all(color: const Color(0xFF00F779), width: 2),
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 8,
            child: Icon(Icons.eco, color: Color(0xFF9EFF75), size: 39),
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
