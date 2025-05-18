import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:habit_tracker/screens/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigateToHome();
  }

  Future<void> _navigateToHome() async {
    await Future.delayed(const Duration(milliseconds: 3000));
    if (!mounted) return;

    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Center(
        child: Container(
          width: 350,
          height: 350,
          child: Image.asset(
            'assets/trackmotive.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading splash image: $error');
              return Container(
                color: Colors.transparent,
                child: Icon(
                  Icons.track_changes_rounded,
                  size: 150,
                  color: Theme.of(context).colorScheme.primary,
                ),
              );
            },
          ),
        )
            .animate()
            .scale(duration: 600.ms, curve: Curves.easeOut)
            .then()
            .fade(duration: 300.ms),
      ),
    );
  }
}
