import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:primamobile/app/authentication/bloc/authentication_bloc.dart';
import 'package:primamobile/app/pages/login/bloc/login_bloc.dart';
import 'package:primamobile/app/pages/login/view/login_painter.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isKeyboardVisible = MediaQuery.of(context).viewInsets.bottom > 0;

    return SafeArea(
      child: BlocListener<AuthenticationBloc, AuthenticationState>(
        listener: (context, authState) {
          if (authState is AuthenticationFailure) {
            context.read<LoginBloc>().add(LoginReset());
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
                      builder: (loginContext, loginState) {
                        final isDisabled =
                            loginState.status == LoginStatus.loading ||
                                loginState.status == LoginStatus.success;
                        return TextField(
                          onChanged: isDisabled
                              ? null
                              : (username) => loginContext
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
                      builder: (loginContext, loginState) {
                        final isDisabled =
                            loginState.status == LoginStatus.loading ||
                                loginState.status == LoginStatus.success;
                        return TextField(
                          onChanged: isDisabled
                              ? null
                              : (password) => loginContext
                                  .read<LoginBloc>()
                                  .add(LoginPasswordFilled(password)),
                          obscureText: !loginState.isPasswordVisible,
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
                                loginState.isPasswordVisible
                                    ? Icons.visibility
                                    : Icons.visibility_off,
                              ),
                              onPressed: isDisabled
                                  ? null
                                  : () => loginContext
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
                      builder: (loginContext, loginState) {
                        final isDisabled =
                            loginState.status == LoginStatus.loading ||
                                loginState.status == LoginStatus.success;
                        return Row(
                          children: [
                            Checkbox(
                              value: loginState.isAgreedToTerms,
                              onChanged: isDisabled
                                  ? null
                                  : (value) => loginContext
                                      .read<LoginBloc>()
                                      .add(
                                        LoginTermsChecked(agreeToTerms: value!),
                                      ),
                            ),
                            Flexible(
                              child: GestureDetector(
                                onTap: isDisabled
                                    ? null
                                    : () => _showTermsDialog(loginContext),
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
                      builder: (loginContext, loginState) {
                        final isLoading =
                            loginState.status == LoginStatus.loading;
                        final isFilled = loginState.username.isNotEmpty &&
                            loginState.password.isNotEmpty &&
                            loginState.isAgreedToTerms;

                        return ElevatedButton(
                          onPressed: isLoading
                              ? null
                              : () {
                                  if (isFilled) {
                                    loginContext
                                        .read<LoginBloc>()
                                        .add(LoginPressed());
                                    loginContext.read<AuthenticationBloc>().add(
                                          LoginButtonPressed(
                                            username: loginState.username,
                                            password: loginState.password,
                                          ),
                                        );
                                  } else {
                                    ScaffoldMessenger.of(loginContext)
                                        .showSnackBar(
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
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
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
