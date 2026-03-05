import 'package:flash_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/constants/app_constants.dart';

import 'core/routes/app_router.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/presentation/bloc/auth_event.dart';
import 'features/decks/data/repositories/deck_repository_impl.dart';
import 'features/decks/domain/repositories/deck_repository.dart';
import 'features/study/data/repositories/flashcard_repository_impl.dart';
import 'features/study/domain/repositories/flashcard_repository.dart';
import 'features/decks/presentation/bloc/deck_bloc.dart';
import 'features/study/presentation/bloc/flashcard_bloc.dart';

import 'core/localization/locale_cubit.dart';
import 'core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  try {
    final notificationService = NotificationService();
    await notificationService.init();
    await notificationService.requestPermissions();
    await notificationService.scheduleDailyReminder(); // <--- Opção 1 ligada!
  } catch (e) {
    debugPrint("Failed to initialize notifications: $e");
  }

  final authRepository = AuthRepositoryImpl(Supabase.instance.client);
  final deckRepository = DeckRepositoryImpl(Supabase.instance.client);
  final flashcardRepository = FlashcardRepositoryImpl(Supabase.instance.client);

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<DeckRepository>.value(value: deckRepository),
        RepositoryProvider<FlashcardRepository>.value(
          value: flashcardRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<LocaleCubit>(create: (context) => LocaleCubit()),
          BlocProvider<AuthBloc>(
            create: (context) =>
                AuthBloc(authRepository)..add(AuthCheckRequested()),
          ),
          BlocProvider<DeckBloc>(create: (context) => DeckBloc(deckRepository)),
          BlocProvider<FlashcardBloc>(
            create: (context) => FlashcardBloc(flashcardRepository),
          ),
        ],
        child: MyApp(isFirstLaunch: isFirstLaunch),
      ),
    ),
  );
}

class MyApp extends StatelessWidget {
  final bool isFirstLaunch;

  const MyApp({super.key, required this.isFirstLaunch});

  @override
  Widget build(BuildContext context) {
    final authBloc = context.read<AuthBloc>();
    final appRouter = createRouter(isFirstLaunch, authBloc);

    return BlocBuilder<LocaleCubit, Locale?>(
      builder: (context, locale) {
        return MaterialApp.router(
          locale: locale,
          onGenerateTitle: (context) => AppLocalizations.of(context)!.appTitle,
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('en', ''), Locale('pt', '')],
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF76E0A3), // Primary Green
              primary: const Color(0xFF76E0A3),
              onPrimary: const Color(0xFF0B194C), // Deep Blue Dark Text
              surface: Colors.white,
              onSurface: const Color(0xFF0B194C),
            ),
            useMaterial3: true,
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0B194C),
              elevation: 0,
              centerTitle: true,
              titleTextStyle: GoogleFonts.outfit(
                color: const Color(0xFF0B194C),
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
              iconTheme: const IconThemeData(color: Color(0xFF0B194C)),
              actionsIconTheme: const IconThemeData(color: Color(0xFF0B194C)),
            ),
            floatingActionButtonTheme: const FloatingActionButtonThemeData(
              backgroundColor: Color(0xFF76E0A3),
              foregroundColor: Color(0xFF0B194C),
            ),
            elevatedButtonTheme: ElevatedButtonThemeData(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF76E0A3),
                foregroundColor: const Color(0xFF0B194C),
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
            cardTheme: CardThemeData(
              color: Colors.white,
              elevation: 12,
              shadowColor: Colors.black.withValues(alpha: 0.25),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: Colors.grey.shade200, width: 1),
              ),
            ),
            textTheme: GoogleFonts.interTextTheme().copyWith(
              titleLarge: GoogleFonts.outfit(
                color: const Color(0xFF0B194C),
                fontWeight: FontWeight.bold,
              ),
              bodyLarge: GoogleFonts.inter(color: const Color(0xFF0B194C)),
              bodyMedium: GoogleFonts.inter(color: const Color(0xFF0B194C)),
            ),
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}
