import 'package:flutter/material.dart';
import 'package:the_movie_data_base/ui/screens/screens.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool showSignInScreen = true;

  void toggleScreens() {
    setState(() {
      showSignInScreen = !showSignInScreen;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSignInScreen) {
      return SignInScreen(showSignUpScreen: toggleScreens);
    } else {
      return SignUpScreen(showSignInScreen: toggleScreens);
    }
  }
}
