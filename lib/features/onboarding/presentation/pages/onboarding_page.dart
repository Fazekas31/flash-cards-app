import 'package:flash_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  void _onIntroEnd(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isFirstLaunch', false);
    if (context.mounted) {
      context.go('/');
    }
  }

  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      pages: [
        PageViewModel(
          title: AppLocalizations.of(context)!.onboardingTitle1,
          body: AppLocalizations.of(context)!.onboardingBody1,
          image: const Center(
            child: Icon(Icons.flash_on, size: 100, color: Colors.blue),
          ),
        ),
        PageViewModel(
          title: AppLocalizations.of(context)!.onboardingTitle2,
          body: AppLocalizations.of(context)!.onboardingBody2,
          image: const Center(
            child: Icon(Icons.cloud_sync, size: 100, color: Colors.blue),
          ),
        ),
        PageViewModel(
          title: AppLocalizations.of(context)!.onboardingTitle3,
          body: AppLocalizations.of(context)!.onboardingBody3,
          image: const Center(
            child: Icon(Icons.psychology, size: 100, color: Colors.blue),
          ),
        ),
        PageViewModel(
          title: AppLocalizations.of(context)!.onboardingTitle4,
          body: AppLocalizations.of(context)!.onboardingBody4,
          image: const Center(
            child: Icon(Icons.school, size: 100, color: Colors.blue),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: Text(AppLocalizations.of(context)!.onboardingSkip),
      next: const Icon(Icons.arrow_forward),
      done: Text(
        AppLocalizations.of(context)!.onboardingDone,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      dotsDecorator: DotsDecorator(
        size: const Size.square(10.0),
        activeSize: const Size(20.0, 10.0),
        activeColor: Colors.blue,
        color: Colors.black26,
        spacing: const EdgeInsets.symmetric(horizontal: 3.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25.0),
        ),
      ),
    );
  }
}
