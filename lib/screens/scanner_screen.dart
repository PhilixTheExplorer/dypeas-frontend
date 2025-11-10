import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import './result_success_screen.dart';
import './result_error_screen.dart';
import 'dart:math';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({Key? key}) : super(key: key);

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  String? _cameraError;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      if (_cameras != null && _cameras!.isNotEmpty) {
        _cameraController = CameraController(
          _cameras![0], // Use back camera
          ResolutionPreset.high,
          enableAudio: false,
        );

        await _cameraController!.initialize();

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      print('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  // Future<String?> _identifyTrash(String imagePath) async {
  //   // This is where you'll integrate your AI model
  //   // For testing, you can randomly return types or null
  //   await Future.delayed(const Duration(seconds: 1));

  //   // Simulate identification (replace with real AI later)
  //   return 'compostable'; // or return null for error
  // }

  Future<String?> _identifyTrash(String imagePath) async {
    await Future.delayed(const Duration(seconds: 1));
  
    // 70% success rate, 30% error rate
    if (Random().nextInt(100) < 30) {
      return null; // Error - 30% chance
    }
  
  // Success - randomly return different waste types
  List<String> wasteTypes = ['compostable', 'recyclable', 'general', 'hazardous'];
  return wasteTypes[Random().nextInt(wasteTypes.length)];
}

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      final XFile photo = await _cameraController!.takePicture();

      // TODO: Call your AI/ML model to identify the trash
      // For now, let's simulate:
      String? identifiedType = await _identifyTrash(photo.path);

      if (identifiedType != null) {
        // Success - show result
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultSuccessScreen(
              imagePath: photo.path,
              wasteType: identifiedType,
            ),
          ),
        );
      } else {
        // Error - couldn't identify
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultErrorScreen(imagePath: photo.path),
          ),
        );
      }
    } catch (e) {
      print('Error capturing image: $e');
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image != null) {
        print('Image picked: ${image.path}');

        // TODO: Call your AI/ML model to identify the trash
        String? identifiedType = await _identifyTrash(image.path);

        if (identifiedType != null) {
          // Success - show result
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultSuccessScreen(
                imagePath: image.path,
                wasteType: identifiedType,
              ),
            ),
          );
        } else {
          // Error - couldn't identify
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ResultErrorScreen(imagePath: image.path),
            ),
          );
        }
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');

      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to pick image: ${e.toString()}',
              style: const TextStyle(fontFamily: 'Kanit'),
            ),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
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
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Text(
                      'Trash-Scanner',
                      style: TextStyle(
                        fontFamily: 'Livvic',
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF024F3B),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Camera viewfinder area
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    decoration: BoxDecoration(
                      color: const Color(0xFF484C52).withOpacity(0.3),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF54AF75),
                        width: 3,
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Camera preview
                        ClipRRect(
                          borderRadius: BorderRadius.circular(17),
                          child:
                              _isCameraInitialized && _cameraController != null
                              ? CameraPreview(_cameraController!)
                              : Container(
                                  color: Colors.black.withOpacity(0.1),
                                  child: const Center(
                                    child: CircularProgressIndicator(
                                      color: Color(0xFF54AF75),
                                    ),
                                  ),
                                ),
                        ),

                        // Corner markers
                        Positioned(
                          top: 20,
                          left: 20,
                          child: _CornerMarker(isTopLeft: true),
                        ),
                        Positioned(
                          top: 20,
                          right: 20,
                          child: _CornerMarker(isTopRight: true),
                        ),
                        Positioned(
                          bottom: 20,
                          left: 20,
                          child: _CornerMarker(isBottomLeft: true),
                        ),
                        Positioned(
                          bottom: 20,
                          right: 20,
                          child: _CornerMarker(isBottomRight: true),
                        ),

                        // Instruction text
                        Positioned(
                          bottom: 60,
                          left: 30,
                          right: 30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.95),
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: const Text(
                              'Point your camera at the trash and capture it.',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Kanit',
                                fontSize: 14,
                                color: Color(0xFF024F3B),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),

              // Upload from gallery button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _pickFromGallery,
                    icon: const Icon(Icons.photo_library_outlined, size: 24),
                    label: const Text(
                      'Upload From Gallery',
                      style: TextStyle(
                        fontFamily: 'Kanit',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF54AF75),
                      foregroundColor: Colors.white,
                      elevation: 2,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // Capture button
              GestureDetector(
                onTap: _captureImage,
                child: Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    border: Border.all(
                      color: const Color(0xFF54AF75),
                      width: 4,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF54AF75),
                      ),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

// Corner marker widget for camera frame
class _CornerMarker extends StatelessWidget {
  final bool isTopLeft;
  final bool isTopRight;
  final bool isBottomLeft;
  final bool isBottomRight;

  const _CornerMarker({
    Key? key,
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(
        border: Border(
          top: (isTopLeft || isTopRight)
              ? const BorderSide(color: Color(0xFF54AF75), width: 4)
              : BorderSide.none,
          left: (isTopLeft || isBottomLeft)
              ? const BorderSide(color: Color(0xFF54AF75), width: 4)
              : BorderSide.none,
          right: (isTopRight || isBottomRight)
              ? const BorderSide(color: Color(0xFF54AF75), width: 4)
              : BorderSide.none,
          bottom: (isBottomLeft || isBottomRight)
              ? const BorderSide(color: Color(0xFF54AF75), width: 4)
              : BorderSide.none,
        ),
      ),
    );
  }
}
