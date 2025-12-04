import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class SettingsDialog extends ConsumerWidget {
  const SettingsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(fetchUserDataProvider);

    return Dialog(
      backgroundColor: const Color(0xFFFFF0F0), // Light pinkish background
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
                  const Text(
                    'User',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
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
                    backgroundColor: const Color(
                      0xFF8D4F4F,
                    ), // Dark reddish-brown
                    child: Text(
                      initial,
                      style: const TextStyle(
                        fontSize: 32,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                },
                loading: () => const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF8D4F4F),
                  child: CircularProgressIndicator(color: Colors.white),
                ),
                error: (_, __) => const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF8D4F4F),
                  child: Icon(Icons.error, color: Colors.white),
                ),
              ),

              const SizedBox(height: 16),

              // Name
              userAsync.when(
                data: (name) => Text(
                  'Halo, ${name ?? "User"}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                loading: () => const Text('Halo, ...'),
                error: (_, __) => const Text('Halo, User'),
              ),

              const SizedBox(height: 24),
              const Divider(color: Colors.black12),
              const SizedBox(height: 24),

              // Language Option
              _buildOptionItem(
                key: const Key('language'),
                icon: Icons.language,
                title: 'Bahasa',
                subtitle: 'Indonesia',
                onTap: () {
                  // TODO: Implement language change
                },
              ),

              const SizedBox(height: 16),

              // Logout Option
              _buildOptionItem(
                key: const Key('logout'),
                icon: Icons.logout,
                title: 'Keluar',
                subtitle: 'Logout dari aplikasi',
                onTap: () async {
                  final success = await ref.read(logoutProvider.future);
                  if (context.mounted) {
                    if (success) {
                      context.goNamed('login');
                    } else {
                      Navigator.pop(context);
                    }
                  }
                },
              ),

              const SizedBox(height: 24),

              // Version
              const Text(
                'versi 1.0',
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOptionItem({
    Key? key,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        key: key,
        leading: Icon(icon, color: Colors.black87),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black87),
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
