import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import './main_navigation.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  void initState() {
    super.initState();
    // Auto navigate after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const MainNavigation()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loading_screen_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(flex: 2),

              // Logo
              Center(
                child: SvgPicture.asset(
                  'assets/icons/logos/wastewise_logo.svg',
                  width: 140,
                  height: 140,
                ),
              ),

              const SizedBox(height: 24),

              // App Name
              const Text(
                'WasteWise',
                style: TextStyle(
                  fontFamily: 'Kaisei Decol',
                  fontSize: 54,
                  color: Color(0xFF024F3B),
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 8),

              // Tagline
              const Text(
                'Sort Smarter. Live Greener.',
                style: TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                  color: Color(0xFF5BA516),
                  fontWeight: FontWeight.w600,
                ),
              ),

              const Spacer(flex: 3),

              // Loading text
              const Padding(
                padding: EdgeInsets.only(bottom: 12.0),
                child: Text(
                  'Loading...',
                  style: TextStyle(
                    fontFamily: 'Kanit',
                    fontSize: 18,
                    color: Color(0xFF5BA516),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),

              // Loading bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    minHeight: 8,
                    backgroundColor: Colors.white.withValues(alpha: 0.3),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      Color(0xFF54AF75),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }
}
