import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'weather_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _controller.forward();
  }

  void _initializeAnimations() {
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
      ),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.7, 1, curve: Curves.easeInOut),
      ),
    )..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          Get.off(() => const WeatherHomePage());
        }
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size.shortestSide * 0.5;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _buildFadeTransition(size),
            _buildScaleTransition(size),
          ],
        ),
      ),
    );
  }

  Widget _buildFadeTransition(double size) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Image.asset(
        'assets/pngbluelogo.png',
        width: size,
        height: size,
        fit: BoxFit.contain,
      ),
    );
  }

  Widget _buildScaleTransition(double size) {
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: Colors.blue[500],
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}
