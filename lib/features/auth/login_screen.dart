import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/state/app_state.dart';

/// Login screen with classic credentials form.
/// Tapping the logo 5 times reveals hidden developer autofill shortcuts at the bottom.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  // Secret Dev Mode triggers
  int _logoTaps = 0;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _formLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);
    await context.read<AppState>().login(
          username: _usernameController.text.trim(),
          password: _passwordController.text.trim(),
        );
    if (mounted) setState(() => _loading = false);
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Stack(
        children: [
          // Background gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    scheme.primary.withValues(alpha: 0.12),
                    scheme.secondary.withValues(alpha: 0.06),
                    Theme.of(context).scaffoldBackgroundColor,
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
            ),
          ),
          // Content
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 480),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ── Header ──────────────────────────────────────────
                    _Header(
                      scheme: scheme,
                      onLogoTap: () {
                        _logoTaps++;
                        if (_logoTaps >= 5) {
                          context.read<AppState>().toggleDevAutofill();
                          _logoTaps = 0;
                        }
                      },
                    ),
                    const SizedBox(height: 32),
                    // ── Card ────────────────────────────────────────────
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardTheme.color,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: scheme.outlineVariant.withValues(alpha: 0.5),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.06),
                            blurRadius: 24,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: _FormLoginTab(
                        formKey: _formKey,
                        usernameController: _usernameController,
                        passwordController: _passwordController,
                        loading: _loading,
                        obscurePassword: _obscurePassword,
                        authError: appState.authError,
                        showDevAutofill: appState.showDevAutofill,
                        onToggleObscure: () => setState(() => _obscurePassword = !_obscurePassword),
                        onSubmit: _formLogin,
                        onAutofillManager: () {
                          _usernameController.text = 'manager';
                          _passwordController.text = appState.managerPassword;
                        },
                        onAutofillLogistics: () {
                          _usernameController.text = 'logistics';
                          _passwordController.text = appState.logisticsPassword;
                        },
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

// ─── Header widget ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.scheme, required this.onLogoTap});
  final ColorScheme scheme;
  final VoidCallback onLogoTap;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          key: const Key('logo_gesture'),
          onTap: onLogoTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: scheme.primary.withValues(alpha: 0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: const Icon(Icons.local_drink_rounded,
                size: 28, color: Colors.white),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'TRLAFCO',
          style: GoogleFonts.inter(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: scheme.primary,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Dairy Cooperative Operations Portal',
          style: GoogleFonts.inter(
            fontSize: 13,
            color: scheme.onSurface.withValues(alpha: 0.55),
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}

// ─── Form-login tab ───────────────────────────────────────────────────────────

class _FormLoginTab extends StatelessWidget {
  const _FormLoginTab({
    required this.formKey,
    required this.usernameController,
    required this.passwordController,
    required this.loading,
    required this.obscurePassword,
    required this.authError,
    required this.showDevAutofill,
    required this.onToggleObscure,
    required this.onSubmit,
    required this.onAutofillManager,
    required this.onAutofillLogistics,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool loading;
  final bool obscurePassword;
  final String? authError;
  final bool showDevAutofill;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;
  final VoidCallback onAutofillManager;
  final VoidCallback onAutofillLogistics;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Form(
        key: formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              key: const Key('username_field'),
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                prefixIcon: Icon(Icons.person_outline, size: 18),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Username is required';
                }
                return null;
              },
              textInputAction: TextInputAction.next,
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('password_field'),
              controller: passwordController,
              obscureText: obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                prefixIcon: const Icon(Icons.lock_outline, size: 18),
                suffixIcon: IconButton(
                  icon: Icon(
                    obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    size: 18,
                  ),
                  onPressed: onToggleObscure,
                ),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Password is required';
                }
                return null;
              },
              onFieldSubmitted: (_) => onSubmit(),
            ),
            if (authError != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Theme.of(context)
                      .colorScheme
                      .error
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: Theme.of(context)
                        .colorScheme
                        .error
                        .withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.error_outline,
                        color: Theme.of(context).colorScheme.error,
                        size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        authError!,
                        key: const Key('auth_error_text'),
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (showDevAutofill) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('autofill_manager_btn'),
                      onPressed: onAutofillManager,
                      icon: const Icon(Icons.manage_accounts_rounded, size: 16),
                      label: const Text('Manager'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      key: const Key('autofill_logistics_btn'),
                      onPressed: onAutofillLogistics,
                      icon: const Icon(Icons.local_shipping_rounded, size: 16),
                      label: const Text('Logistics'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 24),
            SizedBox(
              height: 46,
              child: ElevatedButton.icon(
                key: const Key('login_button'),
                onPressed: loading ? null : onSubmit,
                icon: loading
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : const Icon(Icons.login_rounded, size: 18),
                label: Text(loading ? 'Signing in…' : 'Sign In'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
