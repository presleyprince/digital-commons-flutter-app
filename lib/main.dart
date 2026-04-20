import 'package:digital_shores/app/presentation/provider/add_information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/administration_notifier.dart';
import 'package:digital_shores/app/presentation/provider/auth_notifier.dart';
import 'package:digital_shores/app/presentation/provider/delete_account_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_history_notifier.dart';
import 'package:digital_shores/app/presentation/provider/finance_notifier.dart';
import 'package:digital_shores/app/presentation/provider/information_notifier.dart';
import 'package:digital_shores/app/presentation/provider/onboarding_notifier.dart';
import 'package:digital_shores/app/presentation/provider/otp_notifier.dart';
import 'package:digital_shores/app/presentation/provider/weather_notifier.dart';
import 'package:digital_shores/core/constants.dart';
import 'package:digital_shores/core/theme.dart';
import 'package:digital_shores/firebase_options.dart';
import 'package:digital_shores/router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'injection_container.dart' as di;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Intl.defaultLocale = 'id_ID';
  await di.init();

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  try {
    await dotenv.load(fileName: "assets/env", mergeWith: {});
  } catch (e) {
    // no .env file, continue anyway even if .env was missing
  }
  await initializeDateFormatting('id_ID', null).then((_) => runApp(const App()));
}

class App extends StatefulWidget {
  const App({super.key});

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => di.sl<OnboardingNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<AuthNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<FinanceNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<FinanceHistoryNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<AdministrationNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<InformationNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<AddInformationNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<OtpNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<DeleteAccountNotifier>()),
        ChangeNotifierProvider(create: (_) => di.sl<WeatherNotifier>()),
      ],
      child: MaterialApp.router(
        title: kAppName,
        theme: AppTheme().theme,
        debugShowCheckedModeBanner: false,
        localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        ],
        routerConfig: router,
      ),
    );
  }
}
