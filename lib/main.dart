import 'package:flutter/material.dart';
import 'Authentication/splash_screen.dart';
import 'Home_Page/home_page.dart';
import 'services/dev_auth_session.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DevAuthSession.restore();
  runApp(MyApp(isLoggedIn: DevAuthSession.isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;

  const MyApp({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2773F2)),
        useMaterial3: true,
      ),
      home: isLoggedIn ? const HomePage() : const SplashScreen(),
    );
  }
}
