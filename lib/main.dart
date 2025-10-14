import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'dart:io';  
import 'core/theme/app_theme.dart';
import 'core/providers/locale_provider.dart';
import 'core/l10n/app_localizations.dart';
import 'features/initial/screens/initial_screen.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/business/home/screens/home_container.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Suppress OpenGL ES debug logs on Android
  if (Platform.isAndroid) {
    try {
      const platform = MethodChannel('co.nowshipping.nowshipping/opengl');
      await platform.invokeMethod('suppressOpenGLLogs');
    } catch (e) {
      // Ignore if method channel is not available
    }
  }
  
  // Configure system UI and performance settings
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );
  
  // Set app to portrait only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]).then((_) {
    runApp(
      ProviderScope(
        observers: [_ProviderObserver()],
        child: const LocalizedApp(),
      ),
    );
  });
}

// Custom provider observer to catch and handle provider errors
final class _ProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    // Log provider updates for debugging
    if (context.provider.runtimeType.toString().contains('StateProvider')) {
      // Handle state provider updates safely
    }
  }

  @override
  void didDisposeProvider(
    ProviderObserverContext context,
  ) {
    // Handle provider disposal safely
  }
}


class LocalizedApp extends ConsumerWidget {
  const LocalizedApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    
    return MyApp(key: ValueKey(locale.languageCode));
  }
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    

    
    return MaterialApp(
      title: 'Now Shipping',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme(context),
      darkTheme: AppTheme.darkTheme(context),
      themeMode: ThemeMode.light,
      locale: locale,
      // Performance optimizations and error handling
      builder: (context, child) {
        return MediaQuery(
          // Allow text scaling but with reasonable limits for better accessibility
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(
              MediaQuery.of(context).textScaler.scale(1.0).clamp(0.8, 1.3)
            ),
          ),
          child: Directionality(
            textDirection: locale.languageCode == 'ar' ? TextDirection.rtl : TextDirection.ltr,
            child: child!,
          ),
        );
      },
      localizationsDelegates: const [
        AppLocalizationsDelegate(),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'), // English
        Locale('ar'), // Arabic
      ],
      // Add error handling for widget lifecycle issues
      onGenerateRoute: (settings) {
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/login':
                return const LoginScreen();
              case '/signup':
                return const SignupScreen();
              case '/dashboard':
                return const HomeContainer();
              default:
                return const InitialScreen();
            }
          },
          settings: settings,
        );
      },
      home: const InitialScreen(),
    );
  }
}
