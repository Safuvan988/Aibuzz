import 'package:aibuzz/authentication/loginpage.dart';
import 'package:aibuzz/provider/bookmark_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;
  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode = _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final bookmarkProvider = BookmarkProvider();
  

  final prefs = await SharedPreferences.getInstance();
  final userEmail = prefs.getString('email');
  if (userEmail != null) {
    await bookmarkProvider.setCurrentUser(userEmail);
  }
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: bookmarkProvider),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.light(),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color(0xFF6C63FF),
        scaffoldBackgroundColor: Color(0xFF181A20),
        cardColor: Color(0xFF23262F),
        appBarTheme: AppBarTheme(
          backgroundColor: Color(0xFF23262F),
          foregroundColor: Colors.white,
          iconTheme: IconThemeData(color: Colors.white),
        ),
        colorScheme: ColorScheme.dark(
          primary: Color(0xFF6C63FF),
          secondary: Color(0xFF4CAF50),
          surface: Color(0xFF23262F),
          background: Color(0xFF181A20),
          error: Color(0xFFFF6B6B),
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white,
          onBackground: Colors.white,
          onError: Colors.white,
          brightness: Brightness.dark,
        ),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.white70),
          titleLarge: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Color(0xFF23262F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white24),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Colors.white24),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: Color(0xFF6C63FF), width: 2),
          ),
          hintStyle: TextStyle(color: Colors.white54),
        ),
        iconTheme: IconThemeData(color: Colors.white70),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: Color(0xFF23262F),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        tabBarTheme: TabBarTheme(
          labelColor: Color(0xFF6C63FF),
          unselectedLabelColor: Colors.white54,
        ),
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          backgroundColor: Color(0xFF6C63FF),
          foregroundColor: Colors.white,
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: HomeScreen(),
    );
  }
}