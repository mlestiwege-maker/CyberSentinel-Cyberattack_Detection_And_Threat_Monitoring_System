import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/access_control.dart';
import '../../services/app_state.dart';
import '../../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController(text: 'mlestiwege@gmail.com');
  final _passwordController = TextEditingController(text: 'ChangeMe123!');
  bool _isLoading = false;
  String? _error;
  bool _isLoginTab = true;
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => _error = 'Enter email and password');
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final session = await AuthService.login(email: email, password: password);
      if (!mounted) return;

      AppState.instance.setAuthenticatedUser(
        token: session.accessToken,
        name: session.fullName,
        email: session.email,
        role: session.role,
      );
      AccessControl.instance.setRoleFromBackend(session.role);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildLeftPanel() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 42, vertical: 50),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0B1224), Color(0xFF18213A), Color(0xFF22304A)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(28),
          bottomLeft: Radius.circular(28),
        ),
        border: Border.all(color: const Color(0xFF4B6391).withValues(alpha: 0.22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.32),
            blurRadius: 24,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Logo row
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F8BFF), Color(0xFF2563EB), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.28),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(12),
                child: const Icon(
                  Icons.shield_rounded,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'CyberSentinel',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 6),
                  Text(
                    'Enterprise Threat Intelligence',
                    style: TextStyle(
                      color: Color(0xFFB7C4DC),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.07),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: const Text(
              '24/7 security operations · Role-aware access · Instant alerts',
              style: TextStyle(
                color: Color(0xFFD7E3F7),
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 22),
          // Description
          const Text(
            'Advanced cybersecurity platform for real-time threat detection, incident response, and security operations center management.',
            style: TextStyle(
              color: Color(0xFFD2DAE8),
              fontSize: 13.5,
              height: 1.7,
              fontWeight: FontWeight.w400,
            ),
          ),
          const SizedBox(height: 24),
          // Features
          _featureRowWithIcon('Real-time threat detection and analysis', Icons.warning_amber_rounded),
          const SizedBox(height: 14),
          _featureRowWithIcon('AI-powered anomaly detection', Icons.psychology_rounded),
          const SizedBox(height: 14),
          _featureRowWithIcon('Automated incident response workflows', Icons.autorenew_rounded),
          const SizedBox(height: 14),
          _featureRowWithIcon('Role-based access control and audit trails', Icons.shield_rounded),
          const SizedBox(height: 24),
          // Footer
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: const Color(0xFF8BA2CC).withValues(alpha: 0.16)),
              ),
            ),
            child: const Text(
              '© 2026 CyberSentinel Security Platform. All rights reserved.',
              style: TextStyle(
                color: Color(0xFF9FB0C8),
                fontSize: 11,
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _featureRowWithIcon(String text, IconData icon) {
    return Row(
      children: [
        Container(
          width: 26,
          height: 26,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF20C997), Color(0xFF0EA5A8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF20C997).withValues(alpha: 0.18),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 15,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              color: Color(0xFFF0F5FC),
              fontSize: 13.2,
              height: 1.55,
              fontWeight: FontWeight.w400,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRightPanel(BoxConstraints constraints) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 44),
      decoration: BoxDecoration(
        color: const Color(0xFF0B1326),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(28),
          bottomRight: Radius.circular(28),
        ),
        border: Border.all(color: const Color(0xFF6D84B1).withValues(alpha: 0.14)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF4F8BFF), Color(0xFF1D4ED8)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF3B82F6).withValues(alpha: 0.25),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Icon(Icons.shield_rounded, color: Colors.white, size: 28),
              ),
            ),
            const SizedBox(height: 12),
            // Header
            Container(
              margin: const EdgeInsets.only(bottom: 18),
              child: const Column(
                children: [
                  Text(
                    'Secure Access',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Sign in to your CyberSentinel account',
                    style: TextStyle(
                      color: Color(0xFFB7C4DC),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            // Tabs
            _buildAuthTabs(),
            const SizedBox(height: 26),
            // Form
            _buildAuthForm(),
          ],
        ),
      ),
    );
  }

  Widget _buildAuthTabs() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF111C33),
        border: Border.all(color: const Color(0xFF3E537A).withValues(alpha: 0.22)),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginTab = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  gradient: _isLoginTab
                      ? const LinearGradient(
                          colors: [Color(0xFF4F8BFF), Color(0xFF2563EB)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        )
                      : null,
                  color: _isLoginTab ? null : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    color: _isLoginTab ? Colors.white : const Color(0xFF9FB0C8),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  child: const Text(
                    'Login',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _isLoginTab = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15),
                decoration: BoxDecoration(
                  color: !_isLoginTab
                      ? const Color(0xFF17233B)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  style: TextStyle(
                    color: !_isLoginTab ? Colors.white : const Color(0xFF9FB0C8),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                  ),
                  child: const Text(
                    'Register',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthForm() {
    return _isLoginTab ? _buildLoginForm() : _buildRegisterForm();
  }

  Widget _buildLoginForm() {
    return Column(
      children: [
        // Email field
        _buildTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 18),
        // Password field
        _buildPasswordField(),
        const SizedBox(height: 22),
        // Remember me and forgot password
        Row(
          children: [
            Row(
              children: [
                Checkbox(
                  value: _rememberMe,
                  activeColor: const Color(0xFF3B82F6),
                  onChanged: (value) =>
                      setState(() => _rememberMe = value ?? false),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Remember me',
                  style: TextStyle(
                    color: Color(0xFF94A3B8),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            const Expanded(child: SizedBox()),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  color: Color(0xFF3B82F6),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 32),
        // Login button
        _buildAuthButton(
          text: 'Sign In',
          onPressed: _isLoading ? null : _login,
          isLoading: _isLoading,
        ),
        const SizedBox(height: 14),
        const Text(
          'Secure access protected by role-based authentication.',
          style: TextStyle(
            color: Color(0xFF9FB0C8),
            fontSize: 11.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 16),
        // Error message
        if (_error != null) ...[
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withValues(alpha: 0.09),
              border: Border.all(color: const Color(0xFFDC2626).withValues(alpha: 0.25)),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              _error!,
              style: const TextStyle(
                color: Color(0xFFDC2626),
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
        const SizedBox(height: 8),
        const Text(
          'Tip: Use your assigned admin or team account to access dashboards instantly.',
          style: TextStyle(
            color: Color(0xFF7286A8),
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      children: [
        _buildTextField(
          label: 'Full Name',
          hint: 'Enter your full name',
          icon: Icons.person_outline,
          controller: TextEditingController(),
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Email Address',
          hint: 'Enter your email',
          icon: Icons.email_outlined,
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Phone Number',
          hint: 'Enter your phone number',
          icon: Icons.phone_outlined,
          controller: TextEditingController(),
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        _buildPasswordField(),
        const SizedBox(height: 16),
        _buildTextField(
          label: 'Confirm Password',
          hint: 'Confirm your password',
          icon: Icons.lock_outline,
          controller: TextEditingController(),
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_off
                  : Icons.visibility,
              color: const Color(0xFF64748B),
              size: 20,
            ),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 20),
        _buildAuthButton(
          text: 'Create Account',
          onPressed: () {},
          isLoading: false,
        ),
        const SizedBox(height: 16),
        const Text(
          'By creating an account, you agree to our Terms of Service and Privacy Policy.',
          style: TextStyle(
            color: Color(0xFF94A3B8),
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    List<TextInputFormatter>? inputFormatters,
    Widget? suffixIcon,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFEAF0FA),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15213A),
            border: Border.all(color: const Color(0xFF3E537A).withValues(alpha: 0.28)),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            obscureText: obscureText,
            inputFormatters: inputFormatters,
            cursorColor: const Color(0xFF4F8BFF),
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                color: Color(0xFF8594AE),
                fontSize: 13.5,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2941),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: const Color(0xFF9AB1D1),
                  size: 20,
                ),
              ),
              suffixIcon: suffixIcon != null
                  ? Padding(
                      padding: const EdgeInsets.all(12),
                      child: suffixIcon,
                    )
                  : null,
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF4F8BFF),
                  width: 1.8,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password',
          style: TextStyle(
            color: Color(0xFFEAF0FA),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF15213A),
            border: Border.all(color: const Color(0xFF3E537A).withValues(alpha: 0.28)),
            borderRadius: BorderRadius.circular(15),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: TextField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            cursorColor: const Color(0xFF4F8BFF),
            style: const TextStyle(
              color: Color(0xFFF4F8FF),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              hintText: 'Enter your password',
              hintStyle: const TextStyle(
                color: Color(0xFF8594AE),
                fontSize: 13.5,
              ),
              prefixIcon: Container(
                margin: const EdgeInsets.fromLTRB(12, 12, 10, 12),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF1B2941),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_outline,
                  color: Color(0xFF9AB1D1),
                  size: 20,
                ),
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off
                      : Icons.visibility,
                  color: const Color(0xFF8FA1BE),
                  size: 20,
                ),
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
              ),
              filled: true,
              fillColor: Colors.transparent,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: const BorderSide(
                  color: Color(0xFF4F8BFF),
                  width: 1.8,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAuthButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF4F8BFF),
          disabledBackgroundColor: const Color(0xFF4F8BFF).withValues(alpha: 0.45),
          foregroundColor: Colors.white,
          elevation: 7,
          shadowColor: const Color(0xFF4F8BFF).withValues(alpha: 0.35),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.25,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF020617),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF020617),
              Color(0xFF0F172A),
            ],
          ),
        ),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: 980,
              maxHeight: 700,
            ),
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(32),
                border: Border.all(color: const Color(0xFF486086).withValues(alpha: 0.22)),
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withValues(alpha: 0.50),
                      blurRadius: 52,
                      offset: const Offset(0, 22),
                  ),
                ],
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isNarrow = constraints.maxWidth < 600;
                  return Stack(
                    children: [
                      if (!isNarrow)
                        Positioned(
                          top: -72,
                          left: -62,
                          child: IgnorePointer(
                            child: Container(
                              width: 180,
                              height: 180,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF4F8BFF).withValues(alpha: 0.20),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      if (!isNarrow)
                        Positioned(
                          bottom: -86,
                          right: -72,
                          child: IgnorePointer(
                            child: Container(
                              width: 220,
                              height: 220,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    const Color(0xFF20C997).withValues(alpha: 0.14),
                                    Colors.transparent,
                                  ],
                                  stops: const [0.0, 1.0],
                                ),
                              ),
                            ),
                          ),
                        ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Left info panel
                          if (!isNarrow)
                            Flexible(
                              flex: 3,
                              child: SizedBox(
                                width: constraints.maxWidth * 0.55,
                                child: _buildLeftPanel(),
                              ),
                            ),
                          // divider
                          if (!isNarrow) const SizedBox(width: 20),
                          if (!isNarrow)
                            Container(
                              width: 1,
                              height: 430,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF88A0C8).withValues(alpha: 0.04),
                                    const Color(0xFF88A0C8).withValues(alpha: 0.22),
                                    const Color(0xFF88A0C8).withValues(alpha: 0.04),
                                  ],
                                ),
                              ),
                            ),
                          if (!isNarrow) const SizedBox(width: 20),
                          // Right auth panel
                          Flexible(
                            flex: 2,
                            child: SizedBox(
                              width:
                                  isNarrow ? constraints.maxWidth : constraints.maxWidth * 0.45,
                              child: _buildRightPanel(constraints),
                            ),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }
}