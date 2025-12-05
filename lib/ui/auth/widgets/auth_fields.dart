import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/utils/validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NameWidget extends StatelessWidget {
  const NameWidget({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  final TextEditingController controller;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.authFieldFullNameLabel),
        const SizedBox(height: 8),
        TextFormField(
          key: const ValueKey('nameField'),
          controller: controller,
          enabled: !isLoading,
          validator: (value) => Validators.required(context, value),
          decoration: InputDecoration(
            hintText: context.l10n.authFieldFullNameHint,
            prefixIcon: const Icon(Icons.person_outline),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

class EmailWidget extends StatelessWidget {
  const EmailWidget({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  final TextEditingController controller;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.authFieldEmailLabel),
        const SizedBox(height: 8),
        TextFormField(
          key: const ValueKey('emailField'),
          controller: controller,
          enabled: !isLoading,
          validator: (value) => Validators.email(context, value),
          decoration: InputDecoration(
            hintText: context.l10n.authFieldEmailHint,
            prefixIcon: const Icon(Icons.email_outlined),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}

class PasswordWidget extends ConsumerWidget {
  const PasswordWidget({
    super.key,
    required this.controller,
    required this.isLoading,
  });

  final TextEditingController controller;
  final bool isLoading;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final obscurePassword = ref.watch(obscurePasswordProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(context.l10n.authFieldPasswordLabel),
        const SizedBox(height: 8),
        TextFormField(
          key: const ValueKey('passwordField'),
          controller: controller,
          obscureText: obscurePassword,
          enabled: !isLoading,
          validator: (value) => Validators.minLength(context, value, 8),
          decoration: InputDecoration(
            hintText: context.l10n.authFieldPasswordHint,
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(
                obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () {
                ref.read(obscurePasswordProvider.notifier).toggle();
              },
            ),
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(8)),
            ),
          ),
        ),
      ],
    );
  }
}
