import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/common/theme.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/main/view_model/main_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({
    super.key,
    required this.onPop,
    required this.onLogout,
    required this.onLanguageDialogOpen,
  });

  final Function onPop;
  final Function onLogout;
  final Function onLanguageDialogOpen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final userAsync = ref.watch(fetchUserDataProvider);
    final versionAsync = ref.watch(versionProvider);

    return Dialog(
      backgroundColor: theme.colorScheme.surfaceContainer,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      insetPadding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Stack(
                alignment: Alignment.center,
                children: [
                  Text('User', style: theme.textTheme.labelLarge),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => onPop(),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Avatar
              userAsync.when(
                data: (name) {
                  final initial = name?.isNotEmpty == true
                      ? name![0].toUpperCase()
                      : 'U';
                  return CircleAvatar(
                    radius: 40,
                    backgroundColor: theme.colorScheme.primary,
                    child: Text(
                      initial,
                      style: TextStyle(
                        fontSize: 32,
                        color: theme.colorScheme.onPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                loading: () => CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary,
                  child: CircularProgressIndicator(
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
                error: (_, __) => CircleAvatar(
                  radius: 40,
                  backgroundColor: theme.colorScheme.primary,
                  child: Icon(Icons.error, color: Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // Name
              userAsync.when(
                data: (name) => Text(
                  'Halo, ${name ?? "User"}',
                  style: theme.textTheme.headlineLarge,
                  textAlign: TextAlign.center,
                ),
                loading: () => const Text('Halo, ...'),
                error: (_, __) => const Text('Halo, User'),
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.black12),
              const SizedBox(height: 24),

              // Theme Option
              _buildThemeOption(context, ref),

              const SizedBox(height: 16),

              // Language Option
              _buildLanguageOption(context, ref, onLanguageDialogOpen),

              const SizedBox(height: 16),

              // Logout Option
              _buildOptionItem(
                key: const ValueKey('logoutButton'),
                context: context,
                icon: Icons.logout,
                title: context.l10n.settingsBtnLogout,
                subtitle: context.l10n.settingsBtnLogoutPrompt,
                onTap: () async {
                  final success = await ref.read(logoutProvider.future);
                  if (context.mounted) {
                    if (success) {
                      onLogout();
                    }
                  }
                },
              ),

              const SizedBox(height: 24),

              // Version
              Text(
                context.l10n.settingsTextVersion('${versionAsync.value}'),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeOption(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currentTheme = ref.watch(appThemeProvider);

    String getThemeLabel(ThemeMode mode) {
      switch (mode) {
        case ThemeMode.light:
          return context.l10n.settingsBtnThemeLight;
        case ThemeMode.dark:
          return context.l10n.settingsBtnThemeDark;
        case ThemeMode.system:
          return context.l10n.settingsBtnDefault;
      }
    }

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        child: Row(
          children: [
            Icon(Icons.brightness_6, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.settingsBtnTheme,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurface,
                    ),
                  ),
                  Text(
                    context.l10n.settingsBtnThemePrompt,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            DropdownButton<ThemeMode>(
              key: const Key('theme_dropdown'),
              value: currentTheme,
              underline: const SizedBox(),
              items: ThemeMode.values.map((theme) {
                return DropdownMenuItem(
                  value: theme,
                  child: Text(getThemeLabel(theme)),
                );
              }).toList(),
              onChanged: (ThemeMode? newTheme) {
                if (newTheme != null) {
                  ref.read(appThemeProvider.notifier).changeTheme(newTheme);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(BuildContext context, WidgetRef ref, Function onLanguageDialogOpen) {
    final currentLocale = ref.watch(appLanguageProvider);

    String getLanguageLabel(Locale? locale) {
      if (locale == null) return 'Sistem';
      return locale.languageCode == 'en' ? 'English' : 'Indonesia';
    }

    return _buildOptionItem(
      key: const Key('language'),
      context: context,
      icon: Icons.language,
      title: context.l10n.settingsBtnLanguage,
      subtitle: getLanguageLabel(currentLocale),
      onTap: () => onLanguageDialogOpen(),
    );
  }

  Widget _buildOptionItem({
    Key? key,
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Theme.of(
              context,
            ).colorScheme.surface.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        key: key,
        leading: Icon(icon, color: Theme.of(context).colorScheme.onSurface),
        title: Text(title, style: Theme.of(context).textTheme.bodyLarge),
        subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface,
        ),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}

class LanguageDialog extends ConsumerWidget {
  const LanguageDialog({super.key, required this.onPop});

  final Function onPop;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(appLanguageProvider);
    return AlertDialog(
      title: Text(context.l10n.settingsBtnLanguagePrompt),
      content: RadioGroup<Locale?>(
        groupValue: currentLocale,
        onChanged: (value) {
          ref.read(appLanguageProvider.notifier).changeLanguage(value);
          onPop();
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<Locale?>(
              title: Text(context.l10n.settingsBtnDefault),
              value: null,
            ),
            RadioListTile<Locale?>(
              title: Text(context.l10n.settingsBtnLanguageEN),
              value: const Locale('en'),
            ),
            RadioListTile<Locale?>(
              title: Text(context.l10n.settingsBtnLanguageID),
              value: const Locale('id'),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => onPop(),
          child: Text(context.l10n.settingsBtnCancel),
        ),
      ],
    );
  }
}
