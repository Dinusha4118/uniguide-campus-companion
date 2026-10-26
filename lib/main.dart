import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app_router.dart';
import 'application/providers/app_providers.dart';
import 'data/database/app_database.dart';
import 'data/services/notification_service.dart';
import 'presentation/theme/app_theme.dart';
import 'presentation/theme/app_colors.dart';
import 'l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred portrait orientation
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set system bar styles
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // Initialize offline local database
  try {
    await AppDatabase.database;
  } catch (e) {
    debugPrint('Database init notice: $e');
  }

  // Initialize offline local notifications
  try {
    await NotificationService().initialize();
  } catch (e) {
    debugPrint('Notification init notice: $e');
  }

  runApp(
    const ProviderScope(
      child: UniGuideApp(),
    ),
  );
}

class UniGuideApp extends ConsumerWidget {
  const UniGuideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);

    return MaterialApp.router(
      title: 'UniGuide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: settings.themeMode,
      routerConfig: appRouter,
      locale: Locale(settings.language),
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
