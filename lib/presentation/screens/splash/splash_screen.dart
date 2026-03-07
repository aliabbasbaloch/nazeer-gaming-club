import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../main_navigation.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final AnimationController _titleCtrl;
  late final AnimationController _bylineCtrl;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _titleOpacity;
  late final Animation<double> _bylineOpacity;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900));
    _logoScale = Tween<double>(begin: 0.3, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: Curves.elasticOut));
    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _logoCtrl, curve: const Interval(0.0, 0.45, curve: Curves.easeIn)));
    _titleCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _titleCtrl, curve: Curves.easeIn));
    _bylineCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 400));
    _bylineOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: _bylineCtrl, curve: Curves.easeIn));
    _logoCtrl.forward();
    Future.delayed(const Duration(milliseconds: 400), () { if (mounted) _titleCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 600), () { if (mounted) _bylineCtrl.forward(); });
    Future.delayed(const Duration(milliseconds: 2800), () {
      if (!mounted) return;
      Navigator.of(context).pushReplacement(PageRouteBuilder(
        pageBuilder: (_, __, ___) => const MainNavigation(),
        transitionsBuilder: (_, animation, __, child) => FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 400),
      ));
    });
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    _titleCtrl.dispose();
    _bylineCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPage,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _logoCtrl,
              builder: (context, _) => Opacity(
                opacity: _logoOpacity.value,
                child: Transform.scale(
                  scale: _logoScale.value,
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withValues(alpha: 0.3),
                          blurRadius: 60,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                    child: Hero(
                      tag: 'logo',
                      child: Image.asset('assets/logo.png', width: 160, height: 160),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 28),
            FadeTransition(
              opacity: _titleOpacity,
              child: const Text(
                'Nazeer Gaming Club',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.primary),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: _bylineOpacity,
              child: const Text(
                'by Ali Abbas',
                style: TextStyle(fontSize: 13, fontStyle: FontStyle.italic, color: AppColors.textMuted),
              ),
            ),
          ],
        ),
      ),
    );
  }
}