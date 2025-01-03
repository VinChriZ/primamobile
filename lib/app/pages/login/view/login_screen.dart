import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages/login/bloc/login_bloc.dart';
import 'package:primamobile/app/pages/login/view/login_painter.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isButtonPressed = false;

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return BlocListener<AuthenticationBloc, AuthenticationState>(
      listener: (context, authState) {
        if (authState is AuthenticationFailure) {
          setState(() {
            isButtonPressed = false; // Re-enable inputs if login fails
          });
          context.read<LoginBloc>().add(LoginReset());
        } else if (authState is AuthenticationAuthenticated) {
          setState(() {
            isButtonPressed =
                false; // Ensure inputs stay disabled after success
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            // Header at the top
            CustomPaint(
              painter: HeaderPainter(),
              child: SizedBox(
                width: MediaQuery.of(context).size.width,
                height: 200,
              ),
            ),
            // Footer at the bottom, hidden when keyboard is visible
            if (!isKeyboardVisible)
              Align(
                alignment: Alignment.bottomCenter,
                child: CustomPaint(
                  painter: FooterPainter(),
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width,
                    height: 100,
                  ),
                ),
              ),
            // Main Content
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 150),
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Pri',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.red.shade700,
                          ),
                        ),
                        TextSpan(
                          text: 'Mo',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      final isDisabled = isButtonPressed ||
                          state.status == LoginStatus.loading ||
                          state.status == LoginStatus.success;
                      return TextField(
                        onChanged: isDisabled
                            ? null
                            : (username) => context
                                .read<LoginBloc>()
                                .add(LoginUsernameFilled(username)),
                        decoration: InputDecoration(
                          labelText: 'Username',
                          hintText: 'Enter your username...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                        ),
                        enabled: !isDisabled,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      final isDisabled = isButtonPressed ||
                          state.status == LoginStatus.loading ||
                          state.status == LoginStatus.success;
                      return TextField(
                        onChanged: isDisabled
                            ? null
                            : (password) => context
                                .read<LoginBloc>()
                                .add(LoginPasswordFilled(password)),
                        obscureText: !state.isPasswordVisible,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Enter your password...',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.grey,
                              width: 1.5,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: const BorderSide(
                              color: Colors.blue,
                              width: 2.0,
                            ),
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              state.isPasswordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                            ),
                            onPressed: isDisabled
                                ? null
                                : () => context
                                    .read<LoginBloc>()
                                    .add(LoginPasswordVisibilityPressed()),
                          ),
                        ),
                        enabled: !isDisabled,
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      final isDisabled = isButtonPressed ||
                          state.status == LoginStatus.loading ||
                          state.status == LoginStatus.success;
                      return Row(
                        children: [
                          Checkbox(
                            value: state.isAgreedToTerms,
                            onChanged: isDisabled
                                ? null
                                : (value) => context.read<LoginBloc>().add(
                                      LoginTermsChecked(agreeToTerms: value!),
                                    ),
                          ),
                          Flexible(
                            child: GestureDetector(
                              onTap: isDisabled
                                  ? null
                                  : () => _showTermsDialog(context),
                              child: Text(
                                'I agree to the Terms & Conditions.',
                                style: TextStyle(
                                  decoration: TextDecoration.underline,
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  BlocBuilder<LoginBloc, LoginState>(
                    builder: (context, state) {
                      final isLoading = state.status == LoginStatus.loading;
                      final isFilled = state.username.isNotEmpty &&
                          state.password.isNotEmpty &&
                          state.isAgreedToTerms;

                      return ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                                if (isFilled) {
                                  setState(() {
                                    isButtonPressed =
                                        true; // Disable inputs immediately
                                  });
                                  context.read<LoginBloc>().add(LoginPressed());
                                  context.read<AuthenticationBloc>().add(
                                        LoginButtonPressed(
                                          username: state.username,
                                          password: state.password,
                                        ),
                                      );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text(
                                          'Please fill all fields and agree to terms.'),
                                    ),
                                  );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isFilled && !isLoading
                              ? Colors.blue.shade700
                              : Colors.grey,
                          minimumSize: const Size(double.infinity, 50),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                        ),
                        child: isLoading
                            ? const CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : const Text(
                                'Login',
                                style: TextStyle(
                                    fontSize: 18, color: Colors.white),
                              ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTermsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Terms & Conditions'),
          content: const SingleChildScrollView(
            child: Text(
              'Lorem ipsum dolor sit amet, consectetur adipiscing elit. '
              'Nulla interdum, metus in scelerisque auctor, nunc massa '
              'facilisis ligula, nec facilisis tortor arcu ut mauris. '
              'Pellentesque habitant morbi tristique senectus et netus '
              'et malesuada fames ac turpis egestas. Curabitur venenatis '
              'mattis libero, vel varius felis finibus vel.',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
