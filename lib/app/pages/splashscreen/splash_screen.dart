import 'dart:async';
import 'package:flutter/material.dart';
import 'package:primamobile/repository/user_session_repository.dart';
import 'package:primamobile/app/models/user_session/user_session.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    // Simulate a delay to mimic splash screen
    await Future.delayed(const Duration(seconds: 3));

    // Fetch the user session
    UserSession userSession = await UserSessionRepository().getUserSession();

    // Navigate to the appropriate screen based on the user session
    _navigateToNext(userSession);
  }

  void _navigateToNext(UserSession userSession) {
    String nextRoute = userSession.isLogin ? '/home' : '/login';
    Navigator.pushReplacementNamed(context, nextRoute);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Spacer(),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 250,
                  height: 250,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.blue,
                      width: 15,
                    ),
                  ),
                ),
                RichText(
                  text: const TextSpan(
                    children: [
                      TextSpan(
                        text: "Pri",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.red,
                        ),
                      ),
                      TextSpan(
                        text: "Mo",
                        style: TextStyle(
                          fontSize: 50,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Spacer(),
            Column(
              children: [
                CircularProgressIndicator(
                  valueColor: _animationController.drive(
                    ColorTween(begin: Colors.red, end: Colors.red),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  "Getting Started...",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
