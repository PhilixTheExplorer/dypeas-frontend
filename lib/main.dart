import 'package:flutter/material.dart';
import 'screens/loading_screen.dart';

void main() {
  runApp(const WasteSortingMVP());
}

class WasteSortingMVP extends StatelessWidget {
  const WasteSortingMVP({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WasteWise',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // Primary colors from design system
        primaryColor: const Color(0xFF024F3B),

        // Color scheme
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF54AF75),
          primary: const Color(0xFF024F3B),
          secondary: const Color(0xFF5BA516),
        ),

        // Typography
        textTheme: const TextTheme(
          displayLarge: TextStyle(
            fontFamily: 'Kaisei Decol',
            fontSize: 54,
            fontWeight: FontWeight.w400,
            color: Color(0xFF024F3B),
          ),
          headlineLarge: TextStyle(
            fontFamily: 'Livvic',
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF024F3B),
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Livvic',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF024F3B),
          ),
          headlineSmall: TextStyle(
            fontFamily: 'Livvic',
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Color(0xFF024F3B),
          ),
          bodyLarge: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF024F3B),
          ),
          bodyMedium: TextStyle(
            fontFamily: 'Kanit',
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF024F3B),
          ),
        ),

        // Button theme
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF54AF75),
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            textStyle: const TextStyle(
              fontFamily: 'Kanit',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // Scaffold background
        scaffoldBackgroundColor: const Color(0xFF9BFFF2),

        useMaterial3: true,
      ),
      home: const LoadingScreen(),
    );
  }
}
