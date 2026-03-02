import 'package:flash_cards/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'core/constants/app_constants.dart';
import 'core/services/local_db_service.dart';
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
import 'core/services/sync_service.dart';
import 'core/localization/locale_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Supabase.initialize(
    url: AppConstants.supabaseUrl,
    anonKey: AppConstants.supabaseAnonKey,
  );

  final localDbService = LocalDbService();
  await localDbService.init();

  final prefs = await SharedPreferences.getInstance();
  final isFirstLaunch = prefs.getBool('isFirstLaunch') ?? true;

  final authRepository = AuthRepositoryImpl(Supabase.instance.client);
  final deckRepository = DeckRepositoryImpl(localDbService);
  final flashcardRepository = FlashcardRepositoryImpl(localDbService);
  final syncService = SyncService(
    Supabase.instance.client,
    deckRepository,
    flashcardRepository,
  );

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<LocalDbService>.value(value: localDbService),
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<DeckRepository>.value(value: deckRepository),
        RepositoryProvider<FlashcardRepository>.value(
          value: flashcardRepository,
        ),
        RepositoryProvider<SyncService>.value(value: syncService),
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
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          routerConfig: appRouter,
        );
      },
    );
  }
}
