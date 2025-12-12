import 'package:dicoding_story/common/localizations.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_state.dart';
import 'package:dicoding_story/ui/auth/view_models/auth_view_model.dart';
import 'package:dicoding_story/ui/auth/widgets/auth_button.dart';
import 'package:dicoding_story/ui/auth/widgets/auth_fields.dart';
import 'package:dicoding_story/ui/auth/widgets/logo_widget.dart'
    show LogoWidget;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final Function()? goToRegister;
  final Function()? onLoginSuccess;
  const LoginScreen({super.key, this.goToRegister, this.onLoginSuccess});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TapGestureRecognizer _tapRecognizer;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _tapRecognizer = TapGestureRecognizer()
      ..onTap = () => widget.goToRegister!();
  }

  @override
  void dispose() {
    _tapRecognizer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(loginProvider);
    ref.listen(loginProvider.select((value) => value), ((previous, next) {
      // show snackbar on error
      if (next is Failure) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(next.exception.message)));
      } else if (next is Loaded) {
        widget.onLoginSuccess!();
      }
    }));
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo Placeholder
                  LogoWidget(maxWidth: 600),
                  const SizedBox(height: 24),

                  // Title
                  Text(
                    context.l10n.authGreeting,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
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

                            // Login Button
                            AuthButton(
                              key: const ValueKey('loginButton'),
                              label: context.l10n.authBtnLogin,
                              isLoading: isLoading,
                              onPressed: () {
                                if (_formKey.currentState!.validate()) {
                                  ref
                                      .read(loginProvider.notifier)
                                      .login(
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

                  // Register Link
                  Center(
                    child: RichText(
                      text: TextSpan(
                        text: context.l10n.authMsgNoAccount,
                        style: Theme.of(context).textTheme.titleSmall,
                        children: [
                          TextSpan(
                            text: context.l10n.authLinkRegisterNow,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                            recognizer: _tapRecognizer,
                            semanticsIdentifier: 'to_register_button',
                            semanticsLabel: 'Show Register',
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
