import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_state.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/auth/widgets/auth_button.dart';
import 'package:dicoding_story/ui/auth/widgets/auth_fields.dart';
import 'package:dicoding_story/ui/auth/widgets/logo_widget.dart';
import 'package:dicoding_story/utils/logger_mixin.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final Function()? onRegisterSuccess;
  final Function()? goToLogin;
  const RegisterScreen({super.key, this.onRegisterSuccess, this.goToLogin});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> with LogMixin {
  late TapGestureRecognizer _tapRecognizer;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    log.info('RegisterScreen initialized');
    _tapRecognizer = TapGestureRecognizer()
      ..onTap = () {
        log.info('Navigating to login screen');
        widget.goToLogin!();
      };
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerProvider);
    final scaffold = ScaffoldMessenger.of(context);
    ref.listen(registerProvider.select((value) => value), ((previous, next) {
      if (next is Failure) {
        log.warning('Registration failed: ${next.exception.message}');
        scaffold.showSnackBar(SnackBar(content: Text(next.exception.message)));
      } else if (next is Loaded) {
        log.info('Registration successful, navigating to home');
        widget.onRegisterSuccess!();
      }
    }));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LogoWidget(maxWidth: 600),
                  // Title
                  Text(
                    context.l10n.authRegisterTitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 32),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isLoading = state is Loading;
                      return Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Name Input
                            NameWidget(
                              controller: _nameController,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 16),

                            // Email Input
                            EmailWidget(
                              controller: _emailController,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 16),

                            // Password Input
                            PasswordWidget(
                              controller: _passwordController,
                              isLoading: isLoading,
                            ),
                            const SizedBox(height: 32),

                            // Register Button
                            AuthButton(
                              key: const ValueKey('registerButton'),
                              label: context.l10n.authBtnRegister,
                              isLoading: isLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  log.info(
                                    'Register button pressed, attempting registration',
                                  );
                                  ref
                                      .read(registerProvider.notifier)
                                      .register(
                                        name: _nameController.text,
                                        email: _emailController.text,
                                        password: _passwordController.text,
                                      );
                                }
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: context.l10n.authMsgHaveAccount,
                        style: Theme.of(context).textTheme.titleMedium,
                        children: [
                          TextSpan(
                            text: context.l10n.authLinkLoginNow,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: _tapRecognizer,
                          ),
                        ],
                      ),
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
}
