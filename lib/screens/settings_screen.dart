import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

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
                  'Settings',
                  style: TextStyle(
                    fontFamily: 'Livvic',
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF024F3B),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // Settings options
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    // Language setting
                    _SettingTile(
                      icon: Icons.language,
                      title: 'Language',
                      onTap: () {
                        // Navigate to language selection
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LanguageScreen(),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 16),

                    // Location setting
                    _SettingTile(
                      icon: Icons.location_on_outlined,
                      title: 'Location',
                      onTap: () {
                        // Navigate to location selection or show location picker
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Location feature coming soon!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: const Color(0xFF5BA516),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.white, size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Kanit',
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.white, size: 28),
          ],
        ),
      ),
    );
  }
}

// Language selection screen
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  String _selectedLanguage = 'English'; // Default language

  final List<Map<String, dynamic>> _languages = [
    {'name': 'English', 'flag': '🇬🇧', 'code': 'en'},
    {'name': 'Thai', 'flag': '🇹🇭', 'code': 'th'},
    {'name': 'German', 'flag': '🇩🇪', 'code': 'de'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/loading_screen_bg.png'),
            fit: BoxFit.cover,
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Back button
              Positioned(
                top: 16,
                left: 16,
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back,
                    color: Color(0xFF024F3B),
                    size: 28,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),

              // Settings title
              Positioned(
                top: 24,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    'Settings',
                    style: TextStyle(
                      fontFamily: 'Livvic',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF024F3B),
                    ),
                  ),
                ),
              ),

              // Language options
              Padding(
                padding: const EdgeInsets.only(top: 80, left: 24, right: 24),
                child: Column(
                  children: _languages.map((language) {
                    bool isSelected = _selectedLanguage == language['name'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12.0),
                      child: InkWell(
                        onTap: () {
                          setState(() {
                            _selectedLanguage = language['name'];
                          });
                          // TODO: Implement language change logic
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'Language changed to ${language['name']}',
                              ),
                              duration: const Duration(seconds: 1),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 18,
                          ),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF54AF75)
                                : const Color(0xFF5BA516),
                            borderRadius: BorderRadius.circular(12),
                            border: isSelected
                                ? Border.all(color: Colors.white, width: 3)
                                : null,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Row(
                            children: [
                              Text(
                                language['flag'],
                                style: const TextStyle(fontSize: 32),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Text(
                                  language['name'],
                                  style: const TextStyle(
                                    fontFamily: 'Kanit',
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              if (isSelected)
                                const Icon(
                                  Icons.check_circle,
                                  color: Colors.white,
                                  size: 28,
                                ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
