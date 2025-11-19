import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ResultSuccessScreen extends StatelessWidget {
  final String imagePath;
  final String wasteType; // 'compostable', 'recyclable', 'general', 'hazardous'
  final String predictedLabel;
  final double? confidence;

  static const Map<String, String> _labelWarnings = {
    'fruit':
        'Detected fruit. Please ensure it is removed from any plastic packaging before disposing in the bin.',
    'bread':
        'Remove plastic wrap or twist ties before composting bread to avoid contamination.',
    'bulb':
        'Wrap bulbs to prevent breakage and bring them to a hazardous waste collection site.',
    'e_waste': 'Electronics contain hazardous components.',
    'nailpolishbottle':
        'Nail polish bottles contain chemicals. Keep them sealed and dispose of them via hazardous waste programs.',
    'glass':
        'Rinse glass items and remove lids or caps before recycling. Handle carefully to avoid injury.',
    'glass_bottle':
        'Rinse glass bottles and remove caps or labels before recycling.',
    'glass_jars':
        'Clean glass jars thoroughly and recycle them with lids removed.',
    'cardboard':
        'Flatten cardboard boxes and keep them dry so they can be recycled properly.',
    'carton':
        'Rinse cartons and fold them flat before recycling to save space.',
    'paper':
        'Keep paper clean and dry. Remove any plastic windows or tape when possible.',
    'paper_container':
        'Empty and wipe paper containers. Remove plastic linings or lids if possible.',
    'paper_cup':
        'Empty liquids, remove the plastic lid, and place only the cup in the correct bin.',
    'metal':
        'Rinse metal cans to remove food residue and flatten sharp edges before recycling.',
    'styrofoam':
        'Styrofoam is rarely recycled. Break it down and place it in general waste unless local programs accept it.',
    'trash':
        'This item belongs in general waste. Double-check if parts can be recycled separately first.',
  };

  static const Map<String, String> _wasteTypeWarnings = {
    'hazardous':
        'Handle hazardous waste with care. Keep it sealed and take it to an approved hazardous waste facility.',
    'recyclable':
        'Make sure recyclables are empty, clean, and dry to prevent contaminating the recycling stream.',
    'compostable':
        'Remove any stickers, rubber bands, or packaging before composting this item.',
    'general':
        'If possible, look for ways to reuse or recycle parts of this item before sending it to landfill.',
  };

  const ResultSuccessScreen({
    super.key,
    required this.imagePath,
    required this.wasteType,
    required this.predictedLabel,
    this.confidence,
  });

  // Get bin color based on waste type
  Color _getBinColor() {
    switch (wasteType.toLowerCase()) {
      case 'compostable':
        return const Color(0xFF397800); // Green
      case 'recyclable':
        return const Color(0xFFFFAE00); // Yellow
      case 'general':
        return const Color(0xFF0070AB); // Blue
      case 'hazardous':
        return const Color(0xFFC70000); // Red
      default:
        return const Color(0xFF0070AB);
    }
  }

  // Get bin name
  String _getBinName() {
    switch (wasteType.toLowerCase()) {
      case 'compostable':
        return 'Compostable Waste';
      case 'recyclable':
        return 'Recyclable Waste';
      case 'general':
        return 'General Waste';
      case 'hazardous':
        return 'Hazardous Waste';
      default:
        return 'General Waste';
    }
  }

  // Get bin icon asset path
  String _getBinIcon() {
    switch (wasteType.toLowerCase()) {
      case 'compostable':
        return 'assets/icons/bins/green_bin.svg';
      case 'recyclable':
        return 'assets/icons/bins/orange_bin.svg'; // Yellow bin
      case 'general':
        return 'assets/icons/bins/blue_bin.svg';
      case 'hazardous':
        return 'assets/icons/bins/red_bin.svg';
      default:
        return 'assets/icons/bins/blue_bin.svg';
    }
  }

  String _formatLabel(String raw) {
    final cleaned = raw.replaceAll('_', ' ').trim();
    if (cleaned.isEmpty) {
      return 'Unknown item';
    }

    final words = cleaned.split(RegExp(r'\s+')).map((word) {
      if (word.isEmpty) {
        return word;
      }
      final lower = word.toLowerCase();
      return '${lower[0].toUpperCase()}${lower.substring(1)}';
    }).toList();

    return words.join(' ');
  }

  String _formatPredictedLabel() => _formatLabel(predictedLabel);

  String? _confidenceDescription() => _confidencePercentage(confidence);

  String? _confidencePercentage(double? value) {
    if (value == null) {
      return null;
    }

    final percentage = (value.clamp(0, 1) * 100).toStringAsFixed(1);
    return '$percentage%';
  }

  String? _specialHandlingMessage() {
    final normalizedLabel = predictedLabel.trim().toLowerCase();
    final labelWarning = _labelWarnings[normalizedLabel];
    if (labelWarning != null) {
      return labelWarning;
    }

    // Keyword-based fallback for compound labels (e.g., "fruit_in_plastic")
    if (normalizedLabel.contains('fruit')) {
      return _labelWarnings['fruit'];
    }

    return _wasteTypeWarnings[wasteType.toLowerCase()];
  }

  @override
  Widget build(BuildContext context) {
    final confidenceText = _confidenceDescription();
    final specialHandlingMessage = _specialHandlingMessage();

    return Scaffold(
      backgroundColor: const Color(0xFF9BFFF2).withValues(alpha: 0.3),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
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

            const SizedBox(height: 24),

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
                      const SizedBox(height: 8),

                      // "Trash Identified" header
                      const Text(
                        'Trash Identified',
                        style: TextStyle(
                          fontFamily: 'Livvic',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF024F3B),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Result container with bin icon
                      Container(
                        margin: const EdgeInsets.symmetric(horizontal: 32),
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFEFDC3).withValues(alpha: 0.5),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: _getBinColor().withValues(alpha: 0.3),
                            width: 2,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Text instruction
                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 16,
                                  color: Color(0xFF024F3B),
                                  height: 1.4,
                                ),
                                children: [
                                  const TextSpan(text: 'Please throw in the\n'),
                                  TextSpan(
                                    text: '${_getBinName()} bin!',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: _getBinColor(),
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              '${_formatPredictedLabel()} Detected',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 15,
                                color: Color(0xFF024F3B),
                                fontWeight: FontWeight.w600,
                              ),
                            ),

                            if (confidenceText != null) ...[
                              const SizedBox(height: 6),
                              Text(
                                'The system is $confidenceText sure.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontFamily: 'Kanit',
                                  fontSize: 13,
                                  color: Color(0xFF5BA516),
                                ),
                              ),
                            ],

                            if (specialHandlingMessage != null) ...[
                              const SizedBox(height: 8),
                              Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFFFF4E5),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: const Color(0xFFFFB74D),
                                    width: 1.2,
                                  ),
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Icon(
                                      Icons.warning_amber_rounded,
                                      color: Color(0xFFE65100),
                                      size: 24,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        specialHandlingMessage,
                                        style: const TextStyle(
                                          fontFamily: 'Kanit',
                                          fontSize: 13,
                                          color: Color(0xFF5D4037),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            const SizedBox(height: 6),

                            // Bin icon with animation effect
                            Container(
                              width: 120,
                              height: 120,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: _getBinColor().withValues(
                                      alpha: 0.2,
                                    ),
                                    blurRadius: 15,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  _getBinIcon(),
                                  width: 70,
                                  height: 70,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // More info link
                      TextButton(
                        onPressed: () {
                          // Navigate to info page
                        },
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text(
                              'For more detailed information please click here',
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 13,
                                color: Color(0xFF5BA516),
                                decoration: TextDecoration.underline,
                              ),
                            ),
                            SizedBox(width: 4),
                            Icon(
                              Icons.info_outline,
                              size: 16,
                              color: Color(0xFF5BA516),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Scan Again button
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: () => Navigator.pop(context),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF54AF75),
                              foregroundColor: Colors.white,
                              elevation: 2,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            child: const Text(
                              'Scan Again',
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
