import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/state/app_state.dart';

/// Login screen with two modes:
///   1. **Quick-select panel** — click a role card and press Login instantly
///      (testing convenience, no typing required)
///   2. **Form login** — classic username/password form toggled via a tab
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;
  late TabController _tabController;

  // Quick-select state
  String? _quickRole; // 'manager' | 'logistics'

  static const _roles = [
    _RoleOption(
      role: 'manager',
      username: 'manager',
      password: 'manager123',
      label: 'Manager',
      subtitle: 'Dashboard · Records · Analytics',
      icon: Icons.manage_accounts_rounded,
      color: Color(0xFF0D5C8F),
    ),
    _RoleOption(
      role: 'logistics',
      username: 'logistics',
      password: 'logistics123',
      label: 'Logistics Staff',
      subtitle: 'Deliveries · Classification',
      icon: Icons.local_shipping_rounded,
      color: Color(0xFF1B8FA8),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  // ─── Actions ──────────────────────────────────────────────────────────────

  Future<void> _quickLogin() async {
    if (_quickRole == null) return;
    final option =
        _roles.firstWhere((r) => r.role == _quickRole);
    setState(() => _loading = true);
    await context.read<AppState>().login(
          username: option.username,
          password: option.password,
        );
    if (mounted) setState(() => _loading = false);
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

  // ─── Build ────────────────────────────────────────────────────────────────

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
                    _Header(scheme: scheme),
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
                      child: Column(
                        children: [
                          // Tab bar
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                            child: TabBar(
                              controller: _tabController,
                              dividerColor: Colors.transparent,
                              indicator: BoxDecoration(
                                color:
                                    scheme.primary.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              indicatorSize: TabBarIndicatorSize.tab,
                              labelStyle: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w600),
                              unselectedLabelStyle: GoogleFonts.inter(
                                  fontSize: 13, fontWeight: FontWeight.w400),
                              labelColor: scheme.primary,
                              unselectedLabelColor: scheme.onSurface
                                  .withValues(alpha: 0.5),
                              tabs: const [
                                Tab(
                                  icon: Icon(Icons.bolt_rounded, size: 16),
                                  text: 'Quick Login',
                                ),
                                Tab(
                                  icon: Icon(Icons.lock_outline, size: 16),
                                  text: 'Credentials',
                                ),
                              ],
                            ),
                          ),
                          // Tab content
                          SizedBox(
                            height: 320,
                            child: TabBarView(
                              controller: _tabController,
                              physics:
                                  const NeverScrollableScrollPhysics(),
                              children: [
                                _QuickLoginTab(
                                  roles: _roles,
                                  selected: _quickRole,
                                  loading: _loading,
                                  onSelect: (role) =>
                                      setState(() => _quickRole = role),
                                  onLogin: _quickLogin,
                                ),
                                _FormLoginTab(
                                  formKey: _formKey,
                                  usernameController:
                                      _usernameController,
                                  passwordController:
                                      _passwordController,
                                  loading: _loading,
                                  obscurePassword: _obscurePassword,
                                  authError: appState.authError,
                                  onToggleObscure: () => setState(
                                      () => _obscurePassword =
                                          !_obscurePassword),
                                  onSubmit: _formLogin,
                                ),
                              ],
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
        ],
      ),
    );
  }
}

// ─── Header widget ────────────────────────────────────────────────────────────

class _Header extends StatelessWidget {
  const _Header({required this.scheme});
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
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

// ─── Quick-login tab ──────────────────────────────────────────────────────────

class _QuickLoginTab extends StatelessWidget {
  const _QuickLoginTab({
    required this.roles,
    required this.selected,
    required this.loading,
    required this.onSelect,
    required this.onLogin,
  });

  final List<_RoleOption> roles;
  final String? selected;
  final bool loading;
  final ValueChanged<String> onSelect;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Select your role to sign in',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 12),
          ...roles.map((option) {
            final isSelected = selected == option.role;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _RoleCard(
                option: option,
                selected: isSelected,
                onTap: () => onSelect(option.role),
              ),
            );
          }),
          const Spacer(),
          SizedBox(
            height: 46,
            child: ElevatedButton.icon(
              key: const Key('quick_login_button'),
              onPressed: selected == null || loading ? null : onLogin,
              icon: loading
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.bolt_rounded, size: 18),
              label: Text(loading ? 'Signing in…' : 'Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: selected != null
                    ? (roles
                        .firstWhere((r) => r.role == selected)
                        .color)
                    : scheme.onSurface.withValues(alpha: 0.12),
                foregroundColor: selected != null
                    ? Colors.white
                    : scheme.onSurface.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  final _RoleOption option;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: selected
            ? option.color.withValues(alpha: 0.08)
            : Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selected
              ? option.color
              : Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
          width: selected ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: option.color.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(option.icon,
                      color: option.color, size: 20),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.label,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: selected
                              ? option.color
                              : Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.color,
                        ),
                      ),
                      Text(
                        option.subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (selected)
                  Icon(Icons.check_circle_rounded,
                      color: option.color, size: 20),
              ],
            ),
          ),
        ),
      ),
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
    required this.onToggleObscure,
    required this.onSubmit,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool loading;
  final bool obscurePassword;
  final String? authError;
  final VoidCallback onToggleObscure;
  final VoidCallback onSubmit;

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
            const Spacer(),
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

// ─── Data class ───────────────────────────────────────────────────────────────

class _RoleOption {
  const _RoleOption({
    required this.role,
    required this.username,
    required this.password,
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
  });

  final String role;
  final String username;
  final String password;
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
}
