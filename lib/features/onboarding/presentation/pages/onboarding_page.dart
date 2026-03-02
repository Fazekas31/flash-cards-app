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
          title: "Bem-vindo ao Flashcards",
          body:
              "Aprenda qualquer coisa de forma rápida e eficiente utilizando repetição espaçada.",
          image: const Center(
            child: Icon(Icons.flash_on, size: 100, color: Colors.blue),
          ),
        ),
        PageViewModel(
          title: "Offline First",
          body:
              "Estude em qualquer lugar, a qualquer momento. Seu progresso será sincronizado assim que reconectar.",
          image: const Center(
            child: Icon(Icons.cloud_sync, size: 100, color: Colors.blue),
          ),
        ),
        PageViewModel(
          title: "Automação Inteligente",
          body:
              "Você não escolhe as datas! O algoritmo repete os cartões automaticamente baseado no seu feedback (Fácil, Bom, Difícil).",
          image: const Center(
            child: Icon(Icons.psychology, size: 100, color: Colors.blue),
          ),
        ),
        PageViewModel(
          title: "Vamos Começar!",
          body: "Crie seus decks, adicione cartões e domine seus estudos.",
          image: const Center(
            child: Icon(Icons.school, size: 100, color: Colors.blue),
          ),
        ),
      ],
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context),
      showSkipButton: true,
      skip: const Text("PULAR"),
      next: const Icon(Icons.arrow_forward),
      done: const Text("PRONTO", style: TextStyle(fontWeight: FontWeight.w600)),
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
