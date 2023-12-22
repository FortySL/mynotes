import 'package:flutter/material.dart';

import 'package:mynotes/constants/routs.dart';
import 'package:mynotes/services/auth/auth_exceptions.dart';
import 'package:mynotes/services/auth/auth_services.dart';

import '../utilities/show_error_dialog.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late final TextEditingController _email;
  late final TextEditingController _password;

  @override
  void initState() {
    _email = TextEditingController();
    _password = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _email,
            autocorrect: false,
            enableSuggestions: false,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(hintText: 'Enter email here'),
          ),
          TextField(
            controller: _password,
            obscureText: true,
            enableSuggestions: false,
            autocorrect: false,
            decoration: const InputDecoration(hintText: 'Enter password here'),
          ),
          TextButton(
            onPressed: () async {
              final email = _email.text;
              final password = _password.text;
              try {
                await AuthService.firebase()
                    .loginIn(email: email, password: password);
                final user = AuthService.firebase().currentUser;

                if (user?.isEmailVerified ?? false) {
                  //user's email is verified
                  if (context.mounted) {
                    await Navigator.of(context).pushNamedAndRemoveUntil(
                      notesRoute,
                      (route) => false,
                    );
                  }
                } else {
                  //user's email is not verified
                  if (context.mounted) {
                    Navigator.of(context).pushNamed(verifyEmailRoute);
                  }
                }
              } on UserNotFoundAuthException {
                if (context.mounted) {
                  await showErrorDialog(context, 'User not found');
                }
              } on WrongPasswordAuthException {
                if (context.mounted) {
                  await showErrorDialog(context, 'Wrong password');
                }
              } on InvalidCredentialAuthException {
                if (context.mounted) {
                  await showErrorDialog(context, 'Invalid credentials');
                }
              } on GenericAuthException {
                if (context.mounted) {
                  await showErrorDialog(
                      context, 'Error: Authentication error}');
                }
              } catch (e) {
                if (context.mounted) {
                  await showErrorDialog(
                      context, 'Error: Authentication error}');
                }
              }
            },
            child: const Text('Login'),
          ),
          TextButton(
              onPressed: () {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  registerRoute,
                  (route) => false,
                );
              },
              child: const Text('Not registered yet? Register here!'))
        ],
      ),
    );
  }
}
