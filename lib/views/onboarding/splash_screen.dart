import 'dart:async';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pfe_test/services/Auth/auth_provider.dart';
import 'package:pfe_test/services/Data/data_provider.dart';
import 'package:pfe_test/services/update/update_manager.dart';
import 'package:pfe_test/theme/app_theme.dart';
import 'package:pfe_test/views/auth/login_screen.dart';
import 'package:pfe_test/views/dashboard/dashboard_screen.dart';
import 'package:pfe_test/views/onboarding/onboarding_screen.dart';
import 'package:provider/provider.dart';

// Vos 5 assets découpés
const String assetLogoC = 'assets/icon/logo_c.png';
const String assetLogoChevrons = 'assets/icon/logo_chevrons.png';
const String assetLogoBigChevron = 'assets/icon/logo_big_chevron.png';
const String assetLogoPoint = 'assets/icon/logo_point.png';
const String assetLogoText = 'assets/icon/logo_text.png';

class AnimatedCodingoSplashScreen extends StatefulWidget {
  const AnimatedCodingoSplashScreen({super.key});

  @override
  State<AnimatedCodingoSplashScreen> createState() =>
      _AnimatedCodingoSplashScreenState();
}

class _AnimatedCodingoSplashScreenState
    extends State<AnimatedCodingoSplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _mainController;

  late Animation<double> _cScaleAndOpacity;
  late Animation<double> _typingChevrons;
  late Animation<Offset> _textSlideAndOpacity;
  late Animation<double> _loaderOpacity;
  late Animation<double> _sloganOpacity;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );

    // 1. Apparition de l'icône (C, grand chevron, point)
    _cScaleAndOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 30),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));

    // 2. Apparition des petits chevrons centraux
    _typingChevrons = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 30),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.linear));

    // 3. Glissement du texte (Slogan inclus dans l'image)
    _textSlideAndOpacity = TweenSequence<Offset>([
      TweenSequenceItem(
          tween: ConstantTween(const Offset(0, 0.35)), weight: 50),
      TweenSequenceItem(
          tween: Tween(begin: const Offset(0, 0.35), end: Offset.zero),
          weight: 20),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeOut));

    // 4. Apparition du Loader
    _loaderOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 80),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));
    _sloganOpacity = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween(0.0), weight: 70),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 20),
    ]).animate(CurvedAnimation(parent: _mainController, curve: Curves.easeIn));
    _mainController.forward().then((_) {
      if (mounted) {
        _decideRouteAfterAnimation();
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      UpdateManager.checkForUpdate(context);

    });
  }

  Future<void> _decideRouteAfterAnimation() async {
    if (!mounted) return;
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    await authProvider.initialized;

    if (!mounted) return;

    if (authProvider.status == AuthStatus.unauthenticated) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
      return;
    }
    if (dataProvider.isLoading) {
      await _waitForDataProvider(dataProvider);
    }
    if (!mounted) return;
    _navigateAfterLoad(context, dataProvider);
  }

  Future<void> _waitForDataProvider(DataProvider dataProvider) {
    final completer = Completer<void>();

    void listener() {
      if (!dataProvider.isLoading) {
        dataProvider.removeListener(listener);

        if (!completer.isCompleted) completer.complete();
      }
    }

    dataProvider.addListener(listener);

    if (!dataProvider.isLoading && !completer.isCompleted) {
      dataProvider.removeListener(listener);

      completer.complete();
    }

    return completer.future;
  }

  void _navigateAfterLoad(BuildContext context, DataProvider dataProvider) {
    if (dataProvider.isFirstLogin) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const OnboardingScreen()),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const DashboardScreen()),
      );
    }
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. L'icône reconstruite avec des positions resserrées
                SizedBox(
                  width: 180, // Largeur de la "boîte" du logo
                  height: 160, // Hauteur de la "boîte" du logo
                  child: Stack(
                    clipBehavior: Clip
                        .none, // Permet aux images de déborder un peu si besoin
                    children: [
                      // Le C Bleu (point d'ancrage à gauche)
                      Positioned(
                        left: 0,
                        top: 25,
                        child: FadeTransition(
                          opacity: _cScaleAndOpacity,
                          child: ScaleTransition(
                            scale: _cScaleAndOpacity,
                            child: Image.asset(assetLogoC, width: 170),
                          ),
                        ),
                      ),
                      // Les petits chevrons bleus/oranges (</>) au centre du C
                      Positioned(
                        left: 15, // Rapproché vers la gauche
                        top: 33, // Remonté vers le centre
                        child: FadeTransition(
                          opacity: _typingChevrons,
                          child: Image.asset(assetLogoChevrons, width: 150),
                        ),
                      ),
                      // Le Grand Chevron foncé (>) emboîté à droite
                      Positioned(
                        left: 20, // Fortement rapproché vers la gauche
                        top: 30,
                        child: FadeTransition(
                          opacity: _typingChevrons,
                          child: ScaleTransition(
                            scale: _typingChevrons,
                            child: Image.asset(assetLogoBigChevron, width: 150),
                          ),
                        ),
                      ),
                      // Le Point orange au-dessus du grand chevron
                      Positioned(
                        left: 80, // Aligné avec le haut du grand chevron
                        top: 40,
                        child: FadeTransition(
                          opacity: _typingChevrons,
                          child: ScaleTransition(
                            scale: _typingChevrons,
                            child: Image.asset(assetLogoPoint, width: 90),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // 2. Texte "codingo" glissant
                Transform.translate(
                  offset: const Offset(
                      0, -90), // Ajusté pour ne pas chevaucher le bas du logo
                  child: FadeTransition(
                    opacity: _mainController.drive(Tween(begin: 0.0, end: 1.0)
                        .chain(CurveTween(curve: const Interval(0.5, 0.7)))),
                    child: SlideTransition(
                      position: _textSlideAndOpacity,
                      child: Image.asset(
                        assetLogoText,
                        width: 260,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // 3. Slogan
                FadeTransition(
                  opacity: _sloganOpacity,
                  child: const Text(
                    'LEARN • CODE • GROW',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),

          // 3. Loader en bas (Corrigé pour ne plus être coupé)
          Positioned(
            bottom: 80, // Augmenté de 48 à 80 pour éviter la bordure de l'écran
            left: 0,
            right: 0,
            child: Center(
              child: FadeTransition(
                  opacity: _loaderOpacity,
                  child: LoadingAnimationWidget.staggeredDotsWave(
                      color: Colors.white, size: 50)),
            ),
          ),
        ],
      ),
    );
  }
}
