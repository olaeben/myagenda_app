import 'package:flutter/material.dart';
import '../pages/homepage.dart';
import 'package:rive_animated_icon/rive_animated_icon.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../widgets/custom_text.dart';

class SplashScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;

  const SplashScreen({super.key, required this.onToggleTheme});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool isHovered = false;
  String _buttonText = 'Let\'s begin';
  bool _isFirstLaunch = true;

  @override
  void initState() {
    super.initState();
    _checkFirstLaunch();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
  }

  Future<void> _checkFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool hasLaunched = prefs.getBool('hasLaunched') ?? false;

    if (mounted) {
      setState(() {
        if (hasLaunched) {
          _buttonText = 'Welcome back';
          _isFirstLaunch = false;
        } else {
          _buttonText = 'Let\'s begin';
          _isFirstLaunch = true;
        }
      });
    }
  }

  Future<void> _markFirstLaunch() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('hasLaunched', true);
  }

  void _handleTap() {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MouseRegion(
              onEnter: (_) => setState(() => isHovered = true),
              onExit: (_) => setState(() => isHovered = false),
              child: GestureDetector(
                onTap: _handleTap,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: isHovered ? 220 : 200,
                  height: isHovered ? 220 : 200,
                  child: RiveAnimatedIcon(
                    riveIcon: RiveIcon.copy,
                    width: isHovered ? 90 : 60,
                    height: isHovered ? 90 : 60,
                    color: Colors.grey.shade500,
                    strokeWidth: 2,
                    loopAnimation: true,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 32),
            CustomText(
              'A G E N D I F Y  N O W',
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: colorScheme.onSurface,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: CustomText2(
                'Simplify your life, one task at a time.',
                color: colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 60),
            ElevatedButton.icon(
              onPressed: () {
                if (_isFirstLaunch) {
                  _markFirstLaunch();
                }
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => HomePage(
                      onToggleTheme: widget.onToggleTheme,
                    ),
                  ),
                );
              },
              icon: Icon(
                Icons.arrow_forward,
                color: colorScheme.brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
              ),
              label: CustomText2(
                _buttonText,
                color: colorScheme.brightness == Brightness.light
                    ? Colors.white
                    : Colors.black,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: colorScheme.brightness == Brightness.light
                    ? Colors.black
                    : Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 40,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
