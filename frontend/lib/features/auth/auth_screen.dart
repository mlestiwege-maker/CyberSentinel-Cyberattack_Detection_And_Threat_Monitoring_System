import 'package:flutter/material.dart';

import '../../core/theme.dart';
import '../../services/access_control.dart';
import '../../services/app_config.dart';
import '../../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  final _registerNameController = TextEditingController();
  final _registerEmailController = TextEditingController();
  final _registerPasswordController = TextEditingController();

  bool _isLoading = false;
  bool _isLoginMode = true;
  String _selectedRole = 'Security Analyst';

  @override
  void dispose() {
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerNameController.dispose();
    _registerEmailController.dispose();
    _registerPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitLogin() async {
    if (_loginEmailController.text.trim().isEmpty || _loginPasswordController.text.isEmpty) {
      _showSnack('Enter email and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final loginResult = await AuthService.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );
      final token = loginResult['access_token']?.toString() ?? '';
      final me = await AuthService.me(token);

      AppConfig.instance.updateBackendSession(
        token: token,
        name: me['full_name']?.toString() ?? _loginEmailController.text.trim(),
        email: me['email']?.toString() ?? _loginEmailController.text.trim(),
        role: me['role']?.toString() ?? 'analyst',
      );
      _applyFrontendRole(me['role']?.toString() ?? 'analyst');
      _showSnack('Welcome back, ${AppConfig.instance.backendUserName}');
    } catch (e) {
      _showSnack('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _submitRegister() async {
    if (_registerNameController.text.trim().isEmpty ||
        _registerEmailController.text.trim().isEmpty ||
        _registerPasswordController.text.isEmpty) {
      _showSnack('Fill in name, email, and password');
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService.register(
        fullName: _registerNameController.text.trim(),
        email: _registerEmailController.text.trim(),
        password: _registerPasswordController.text,
        role: _selectedRole,
      );
      _showSnack('Account created. You can log in now.');
      setState(() => _isLoginMode = true);
    } catch (e) {
      _showSnack('Registration failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _applyFrontendRole(String backendRole) {
    final mappedRole = switch (backendRole) {
      'admin' => 'Admin',
      'analyst' => 'Security Analyst',
      _ => 'Threat Monitor',
    };
    AccessControl.instance.setRole(mappedRole);
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.primaryBlack,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 980),
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.secondaryBlack,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFF2A3050)),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final isWide = constraints.maxWidth > 760;
                  final hero = _buildHeroPanel();
                  final form = _buildAuthPanel();
                  return isWide
                      ? IntrinsicHeight(
                          child: Row(
                            children: [
                              Expanded(flex: 5, child: hero),
                              Expanded(flex: 4, child: form),
                            ],
                          ),
                        )
                      : Column(
                          children: [hero, form],
                        );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroPanel() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFF0C1630), Color(0xFF101A33)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(24)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('CyberSentinel', style: TextStyle(color: AppTheme.textWhite, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 10),
          const Text(
            'Secure team access for incident response, threat monitoring, reporting, and alerts.',
            style: TextStyle(color: AppTheme.textGrey, fontSize: 16),
          ),
          const SizedBox(height: 24),
          _bullet('Shared team login for all project members'),
          _bullet('Backend JWT authentication with saved session'),
          _bullet('Role-based access for Admin, Analyst, and Viewer'),
          _bullet('Immediate access to dashboard, incidents, reports, and alerts'),
          const SizedBox(height: 28),
          const Text('Backend users can register or sign in from the same screen.', style: TextStyle(color: AppTheme.accentBlue, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildAuthPanel() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ToggleButtons(
            isSelected: [_isLoginMode, !_isLoginMode],
            onPressed: (index) => setState(() => _isLoginMode = index == 0),
            borderRadius: BorderRadius.circular(12),
            selectedColor: Colors.white,
            fillColor: AppTheme.accentBlue,
            color: AppTheme.textGrey,
            constraints: const BoxConstraints(minHeight: 44, minWidth: 140),
            children: const [Text('Login'), Text('Register')],
          ),
          const SizedBox(height: 24),
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: _isLoginMode ? _buildLoginForm() : _buildRegisterForm(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return Column(
      key: const ValueKey('login'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Team Login', style: TextStyle(color: AppTheme.textWhite, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        TextField(
          controller: _loginEmailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: AppTheme.textGrey)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _loginPasswordController,
          obscureText: true,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: AppTheme.textGrey)),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitLogin,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          child: _isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Login'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => _isLoginMode = false),
          child: const Text('Need an account? Register here'),
        ),
      ],
    );
  }

  Widget _buildRegisterForm() {
    return Column(
      key: const ValueKey('register'),
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text('Create Team Account', style: TextStyle(color: AppTheme.textWhite, fontSize: 22, fontWeight: FontWeight.bold)),
        const SizedBox(height: 18),
        TextField(
          controller: _registerNameController,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(labelText: 'Full name', labelStyle: TextStyle(color: AppTheme.textGrey)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _registerEmailController,
          keyboardType: TextInputType.emailAddress,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(labelText: 'Email', labelStyle: TextStyle(color: AppTheme.textGrey)),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _registerPasswordController,
          obscureText: true,
          style: const TextStyle(color: AppTheme.textWhite),
          decoration: const InputDecoration(labelText: 'Password', labelStyle: TextStyle(color: AppTheme.textGrey)),
        ),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(
          initialValue: _selectedRole,
          dropdownColor: AppTheme.secondaryBlack,
          decoration: const InputDecoration(labelText: 'Role', labelStyle: TextStyle(color: AppTheme.textGrey)),
          items: AccessControl.instance.availableRoles.map((role) {
            return DropdownMenuItem(value: role, child: Text(role));
          }).toList(),
          onChanged: (value) {
            if (value != null) setState(() => _selectedRole = value);
          },
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _isLoading ? null : _submitRegister,
          style: ElevatedButton.styleFrom(backgroundColor: AppTheme.accentBlue, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14)),
          child: _isLoading ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Text('Register'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () => setState(() => _isLoginMode = true),
          child: const Text('Already have an account? Login'),
        ),
      ],
    );
  }

  Widget _bullet(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.verified_outlined, color: AppTheme.successGreen, size: 18),
          const SizedBox(width: 10),
          Expanded(child: Text(text, style: const TextStyle(color: AppTheme.textWhite, fontSize: 14))),
        ],
      ),
    );
  }
}