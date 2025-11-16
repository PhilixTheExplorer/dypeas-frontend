import 'package:flutter/material.dart';

class InfoScreen extends StatelessWidget {
  const InfoScreen({super.key});

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
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Information',
                  style: TextStyle(
                    fontFamily: 'Livvic',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF024F3B),
                  ),
                ),
              ),

              // Scrollable waste categories
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: const [
                      SizedBox(height: 8),

                      // Compostable Waste
                      _WasteInfoCard(
                        icon: Icons.delete_outline,
                        title: 'Compostable Waste',
                        titleColor: Color(0xFF397800),
                        backgroundColor: Color(0xFF397800),
                        items: [
                          'Food scraps, vegetable and fruit waste, garden waste.',
                          'Use green or clear plastic bags. Avoid plastic wrapping.',
                          'This waste is turned into compost or fertilizer.',
                        ],
                      ),

                      SizedBox(height: 16),

                      // Recyclable Waste
                      _WasteInfoCard(
                        icon: Icons.delete_outline,
                        title: 'Recyclable Waste',
                        titleColor: Color(0xFFFFAE00),
                        backgroundColor: Color(0xFFFFAE00),
                        items: [
                          'Clean paper, cardboard, plastic bottles, glass, metal cans.',
                          'Use yellow bags. Items should be clean and dry before recycling.',
                        ],
                      ),

                      SizedBox(height: 16),

                      // General Waste
                      _WasteInfoCard(
                        icon: Icons.delete_outline,
                        title: 'General Waste',
                        titleColor: Color(0xFF0070AB),
                        backgroundColor: Color(0xFF0070AB),
                        items: [
                          'Non-recyclable waste such as dirty plastics, foam, rubber, and other household trash.',
                          'Use blue bags. This waste is usually sent to landfill or incineration.',
                        ],
                      ),

                      SizedBox(height: 16),

                      // Hazardous Waste
                      _WasteInfoCard(
                        icon: Icons.delete_outline,
                        title: 'Hazardous Waste',
                        titleColor: Color(0xFFC70000),
                        backgroundColor: Color(0xFFC70000),
                        items: [
                          'Batteries, chemicals, fluorescent lamps, and spray cans.',
                          'Use orange or red bags.',
                          'Must be disposed of separately at designated points.',
                        ],
                      ),

                      SizedBox(height: 100), // Extra space for bottom nav
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WasteInfoCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Color titleColor;
  final Color backgroundColor;
  final List<String> items;

  const _WasteInfoCard({
    required this.icon,
    required this.title,
    required this.titleColor,
    required this.backgroundColor,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with icon and title
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.15),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: backgroundColor.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: backgroundColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Livvic',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: titleColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Content
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: backgroundColor.withValues(alpha: 0.95),
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(16),
                bottomRight: Radius.circular(16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.map((item) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontFamily: 'Kanit',
                      fontSize: 14,
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
