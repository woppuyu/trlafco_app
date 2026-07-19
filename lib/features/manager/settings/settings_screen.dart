import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:trlafco_app/state/app_state.dart';
import 'package:go_router/go_router.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    final scheme = Theme.of(context).colorScheme;
    final isDark = appState.themeMode == ThemeMode.dark;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
        children: [
          // Header
          Text('Settings', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          Text('Preferences and account', style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 20),

          // ── Account section ──────────────────────────────────────────
          _SettingsSection(
            title: 'Account',
            children: [
              _SettingsTile(
                icon: Icons.person_rounded,
                iconColor: scheme.primary,
                title: appState.currentUsername ?? 'User',
                subtitle: appState.currentRole?.name.toUpperCase() ?? '',
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: scheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Active',
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
              _SettingsTile(
                icon: Icons.lock_outline_rounded,
                iconColor: scheme.primary,
                title: 'Change Password',
                subtitle: 'Update your login password',
                trailing: Icon(Icons.chevron_right_rounded, color: scheme.onSurface.withValues(alpha: 0.4)),
                onTap: () {
                  context.push('/change-password');
                },
              ),
            ],
          ),
          const SizedBox(height: 14),

          // ── Appearance section ────────────────────────────────────────
          _SettingsSection(
            title: 'Appearance',
            children: [
              _SettingsTile(
                icon: isDark
                    ? Icons.dark_mode_rounded
                    : Icons.light_mode_rounded,
                iconColor: isDark
                    ? const Color(0xFF8B5CF6)
                    : const Color(0xFFF59E0B),
                title: 'Dark Mode',
                subtitle: isDark ? 'Enabled' : 'Disabled',
                trailing: Switch(
                  value: isDark,
                  onChanged: (_) => appState.toggleTheme(),
                  activeThumbColor: scheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Logout ────────────────────────────────────────────────────
          SizedBox(
            height: 48,
            child: ElevatedButton.icon(
              onPressed: () async => appState.logout(),
              icon: const Icon(Icons.logout_rounded, size: 18),
              label: const Text('Sign Out'),
              style: ElevatedButton.styleFrom(
                backgroundColor: scheme.error.withValues(alpha: 0.1),
                foregroundColor: scheme.error,
                elevation: 0,
                side: BorderSide(color: scheme.error.withValues(alpha: 0.3)),
                textStyle: GoogleFonts.inter(
                    fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Settings section ─────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.children});
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  letterSpacing: 1.0,
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.45),
                ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardTheme.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: Theme.of(context)
                  .colorScheme
                  .outlineVariant
                  .withValues(alpha: 0.5),
            ),
          ),
          child: Column(
            children: List.generate(children.length, (i) {
              final divider = i < children.length - 1
                  ? Divider(
                      height: 1,
                      indent: 56,
                      color: Theme.of(context)
                          .colorScheme
                          .outlineVariant
                          .withValues(alpha: 0.4),
                    )
                  : const SizedBox.shrink();
              return Column(
                children: [children[i], divider],
              );
            }),
          ),
        ),
      ],
    );
  }
}

// ─── Settings tile ────────────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
      leading: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 16, color: iconColor),
      ),
      title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
      subtitle: subtitle != null
          ? Text(subtitle!, style: Theme.of(context).textTheme.bodySmall)
          : null,
      trailing: trailing,
    );
  }
}
