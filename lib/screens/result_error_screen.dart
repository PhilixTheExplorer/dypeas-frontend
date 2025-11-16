import 'package:flutter/material.dart';
import 'dart:io';

class ResultErrorScreen extends StatelessWidget {
  final String imagePath;

  const ResultErrorScreen({super.key, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF9BFFF2).withValues(alpha: 0.3),
      body: SafeArea(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Spacer(),
                  const Text(
                    'Trash-Scanner',
                    style: TextStyle(
                      fontFamily: 'Livvic',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF024F3B),
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close, size: 28),
                    color: const Color(0xFF024F3B),
                  ),
                ],
              ),
            ),

            // Scanned image
            Container(
              height: 200,
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Result card
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32),
                    topRight: Radius.circular(32),
                  ),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      const SizedBox(height: 24),

                      // "Object Not Identified" header
                      const Text(
                        'Object Not Identified',
                        style: TextStyle(
                          fontFamily: 'Livvic',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFC70000),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Error icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC70000).withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.help_outline,
                            size: 70,
                            color: Color(0xFFC70000),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),

                      // Error message
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 40.0),
                        child: Column(
                          children: const [
                            Text(
                              'We couldn\'t identify this object',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF024F3B),
                              ),
                            ),
                            SizedBox(height: 12),
                            Text(
                              'please try again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 16,
                                color: Color(0xFF484C52),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 48),

                      // Retry button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFC70000),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Retry',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
