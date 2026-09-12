import 'package:flutter/material.dart';

import 'admin_page.dart';

class LoginPage extends StatefulWidget {
  final WidgetBuilder homeBuilder;

  const LoginPage({
    super.key,
    required this.homeBuilder,
  });

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  static const String demoUser = 'admin';
  static const String demoPassword = 'codesprout123';

  static const Color _pageBackground = Color(0xFF0A2826);
  static const Color _background = Color(0xFF123D39);
  static const Color _panel = Color(0xFF184B47);
  static const Color _green = Color(0xFF00F779);
  static const Color _white = Color(0xFFF7F7F2);

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _sproutController;

  bool _hidePassword = true;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _sproutController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2100),
    );
  }

  @override
  void dispose() {
    _sproutController.dispose();
    _userController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final String user = _userController.text.trim().toLowerCase();
    final String password = _passwordController.text;

    if (user != demoUser || password != demoPassword) {
      ScaffoldMessenger.of(context)
        ..clearSnackBars()
        ..showSnackBar(
          const SnackBar(
            content: Text('Usuário ou senha incorretos.'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: Color(0xFF8C2E2A),
          ),
        );
      return;
    }

    setState(() => _loading = true);
    await _sproutController.forward(from: 0);
    await Future<void>.delayed(const Duration(milliseconds: 250));

    if (!mounted) return;

    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) => AdminPage(
          homeBuilder: widget.homeBuilder,
        ),
      ),
    );

    if (!mounted) return;
    _sproutController.reset();
    setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBackground,
      body: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 520),
          color: _background,
          child: Stack(
            children: <Widget>[
              SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(26, 36, 26, 32),
                  child: _buildLoginForm(),
                ),
              ),
              _buildLoadingOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: <Widget>[
          const _LoginLogo(),
          const SizedBox(height: 20),
          const Text(
            'CodeSprout',
            style: TextStyle(
              color: _green,
              fontSize: 34,
              fontWeight: FontWeight.w900,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            'Cultivando a lógica, exercício por exercício',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: _white.withValues(alpha: 0.74),
              fontSize: 15,
            ),
          ),
          const SizedBox(height: 34),
          Container(
            padding: const EdgeInsets.fromLTRB(22, 25, 22, 24),
            decoration: BoxDecoration(
              color: _panel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF087B50)),
              boxShadow: const <BoxShadow>[
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 18,
                  offset: Offset(0, 7),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                TextFormField(
                  controller: _userController,
                  textInputAction: TextInputAction.next,
                  autofillHints: const <String>[AutofillHints.username],
                  style: const TextStyle(color: _white),
                  decoration: _fieldDecoration(
                    label: 'Usuário',
                    icon: Icons.person_outline_rounded,
                  ),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Informe o usuário.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _passwordController,
                  obscureText: _hidePassword,
                  textInputAction: TextInputAction.done,
                  autofillHints: const <String>[AutofillHints.password],
                  onFieldSubmitted: (_) => _login(),
                  style: const TextStyle(color: _white),
                  decoration: _fieldDecoration(
                    label: 'Senha',
                    icon: Icons.lock_outline_rounded,
                    suffix: IconButton(
                      tooltip: _hidePassword ? 'Mostrar senha' : 'Ocultar senha',
                      onPressed: () {
                        setState(() => _hidePassword = !_hidePassword);
                      },
                      icon: Icon(
                        _hidePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: _white,
                      ),
                    ),
                  ),
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Informe a senha.';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 22),
                SizedBox(
                  height: 58,
                  child: _LoginButton(onPressed: _login),
                ),
                const SizedBox(height: 18),
                Container(
                  padding: const EdgeInsets.all(13),
                  decoration: BoxDecoration(
                    color: const Color(0xFF123D39),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: _green.withValues(alpha: 0.45),
                    ),
                  ),
                  child: const Column(
                    children: <Widget>[
                      SelectableText(
                        'Usuário: admin  •  Senha: codesprout123',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: _white, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String label,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFFBFD8D4)),
      prefixIcon: Icon(icon, color: _green),
      suffixIcon: suffix,
      filled: true,
      fillColor: const Color(0xFF123D39),
      errorStyle: const TextStyle(color: Color(0xFFFFB4AB)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFF087B50)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: _green, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFFF6B61)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(11),
        borderSide: const BorderSide(color: Color(0xFFFF6B61), width: 2),
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return IgnorePointer(
      ignoring: !_loading,
      child: AnimatedOpacity(
        opacity: _loading ? 1 : 0,
        duration: const Duration(milliseconds: 280),
        child: Container(
          color: Colors.black.withValues(alpha: 0.76),
          alignment: Alignment.center,
          padding: const EdgeInsets.all(24),
          child: AnimatedScale(
            scale: _loading ? 1 : 0.88,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOutBack,
            child: Container(
              width: 360,
              padding: const EdgeInsets.fromLTRB(24, 25, 24, 23),
              decoration: BoxDecoration(
                color: const Color(0xFF104B50),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: _white, width: 1.5),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: _green.withValues(alpha: 0.22),
                    blurRadius: 28,
                    spreadRadius: 3,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  SizedBox(
                    width: 190,
                    height: 210,
                    child: AnimatedBuilder(
                      animation: _sproutController,
                      builder: (BuildContext context, Widget? child) {
                        return CustomPaint(
                          painter: _SproutPhonePainter(
                            progress: _sproutController.value,
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Preparando seu ambiente...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _white,
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 7),
                  Text(
                    'Um novo conhecimento está brotando.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: _white.withValues(alpha: 0.75),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 18),
                  AnimatedBuilder(
                    animation: _sproutController,
                    builder: (BuildContext context, Widget? child) {
                      return ClipRRect(
                        borderRadius: BorderRadius.circular(99),
                        child: LinearProgressIndicator(
                          value: _sproutController.value,
                          minHeight: 10,
                          backgroundColor: const Color(0xFF243B39),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            _green,
                          ),
                        ),
                      );
                    },
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

class _LoginButton extends StatelessWidget {
  final VoidCallback onPressed;

  const _LoginButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFF00F779),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onPressed,
        hoverColor: Colors.white.withValues(alpha: 0.17),
        splashColor: Colors.white.withValues(alpha: 0.28),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFFF7F7F2), width: 4),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.login_rounded,
                color: Color(0xFF104B50),
                size: 28,
              ),
              SizedBox(width: 9),
              Text(
                'Entrar',
                style: TextStyle(
                  color: Color(0xFF104B50),
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LoginLogo extends StatelessWidget {
  const _LoginLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 112,
      height: 112,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFF075F46),
        border: Border.all(color: const Color(0xFF00F779), width: 3),
        boxShadow: const <BoxShadow>[
          BoxShadow(color: Colors.black26, blurRadius: 16, offset: Offset(0, 6)),
        ],
      ),
      child: const Stack(
        alignment: Alignment.center,
        children: <Widget>[
          Positioned(
            top: 11,
            child: Icon(Icons.eco, color: Color(0xFF9EFF75), size: 54),
          ),
          Positioned(
            bottom: 11,
            child: Text(
              'CS',
              style: TextStyle(
                color: Color(0xFF00F779),
                fontSize: 31,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SproutPhonePainter extends CustomPainter {
  final double progress;

  const _SproutPhonePainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    const Color white = Color(0xFFF7F7F2);
    const Color green = Color(0xFF00F779);
    const Color leafGreen = Color(0xFF84EB69);
    const Color dark = Color(0xFF123D39);

    final double phoneOpacity =
    (progress / 0.22).clamp(0.0, 1.0).toDouble();
    final Paint phoneFill = Paint()
      ..color = dark.withValues(alpha: phoneOpacity)
      ..style = PaintingStyle.fill;
    final Paint phoneBorder = Paint()
      ..color = white.withValues(alpha: phoneOpacity)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5;

    final Rect phoneRect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height * 0.72),
      width: 92,
      height: 118,
    );
    final RRect phone = RRect.fromRectAndRadius(
      phoneRect,
      const Radius.circular(14),
    );

    canvas
      ..drawRRect(phone, phoneFill)
      ..drawRRect(phone, phoneBorder);

    final Rect screen = Rect.fromLTWH(
      phoneRect.left + 10,
      phoneRect.top + 12,
      phoneRect.width - 20,
      phoneRect.height - 33,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(screen, const Radius.circular(7)),
      Paint()..color = green.withValues(alpha: phoneOpacity * 0.20),
    );
    canvas.drawCircle(
      Offset(size.width / 2, phoneRect.bottom - 10),
      3.5,
      Paint()..color = white.withValues(alpha: phoneOpacity),
    );

    final double stemProgress = Curves.easeOutCubic.transform(
      ((progress - 0.18) / 0.64).clamp(0.0, 1.0).toDouble(),
    );
    final Offset stemBottom = Offset(size.width / 2, phoneRect.top + 4);
    const double fullStemHeight = 112;
    final Offset stemTop = Offset(
      size.width / 2,
      stemBottom.dy - (fullStemHeight * stemProgress),
    );

    final Paint stemPaint = Paint()
      ..color = leafGreen
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(stemBottom, stemTop, stemPaint);

    _drawLeaf(
      canvas,
      center: Offset(size.width / 2 - 15, stemBottom.dy - 34),
      angle: -0.72,
      appearance:
      ((progress - 0.38) / 0.18).clamp(0.0, 1.0).toDouble(),
      color: leafGreen,
    );
    _drawLeaf(
      canvas,
      center: Offset(size.width / 2 + 15, stemBottom.dy - 61),
      angle: 0.72,
      appearance:
      ((progress - 0.54) / 0.18).clamp(0.0, 1.0).toDouble(),
      color: leafGreen,
    );
    _drawLeaf(
      canvas,
      center: Offset(size.width / 2 - 13, stemBottom.dy - 87),
      angle: -0.62,
      appearance:
      ((progress - 0.68) / 0.18).clamp(0.0, 1.0).toDouble(),
      color: green,
    );

    final double topLeaf =
    ((progress - 0.80) / 0.20).clamp(0.0, 1.0).toDouble();
    _drawLeaf(
      canvas,
      center: Offset(stemTop.dx - 8, stemTop.dy + 2),
      angle: -0.30,
      appearance: topLeaf,
      color: green,
    );
    _drawLeaf(
      canvas,
      center: Offset(stemTop.dx + 8, stemTop.dy + 2),
      angle: 0.30,
      appearance: topLeaf,
      color: green,
    );
  }

  void _drawLeaf(
      Canvas canvas, {
        required Offset center,
        required double angle,
        required double appearance,
        required Color color,
      }) {
    if (appearance <= 0) return;

    canvas.save();
    canvas
      ..translate(center.dx, center.dy)
      ..rotate(angle)
      ..scale(appearance, appearance);

    final Path leaf = Path()
      ..moveTo(0, 0)
      ..quadraticBezierTo(-18, -18, 0, -33)
      ..quadraticBezierTo(19, -18, 0, 0)
      ..close();

    canvas.drawPath(
      leaf,
      Paint()
        ..color = color.withValues(alpha: appearance)
        ..style = PaintingStyle.fill,
    );
    canvas.drawPath(
      leaf,
      Paint()
        ..color = const Color(0xFFF7F7F2).withValues(alpha: appearance)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _SproutPhonePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
