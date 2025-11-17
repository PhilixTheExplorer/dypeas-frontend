import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import './result_success_screen.dart';
import './result_error_screen.dart';
import '../services/roboflow_service.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final ImagePicker _picker = ImagePicker();
  CameraController? _cameraController;
  List<CameraDescription>? _cameras;
  bool _isCameraInitialized = false;
  late final RoboflowService _roboflowService;
  bool _isClassifying = false;
  bool _isProcessingCapture = false;

  @override
  void initState() {
    super.initState();
    _roboflowService = RoboflowService();
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
      debugPrint('Error initializing camera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _roboflowService.dispose();
    super.dispose();
  }

  Future<RoboflowClassificationResult?> _identifyTrash(String imagePath) async {
    if (mounted) {
      setState(() {
        _isClassifying = true;
      });
    }

    try {
      final result = await _roboflowService.classifyImage(imagePath);
      return result;
    } on MissingRoboflowConfigException catch (e) {
      _showError(e.message);
    } on RoboflowException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError('Failed to classify waste. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _isClassifying = false;
        });
      }
    }
    return null;
  }

  Future<void> _captureImage() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) {
      return;
    }

    if (_isProcessingCapture) {
      return;
    }

    setState(() {
      _isProcessingCapture = true;
    });

    try {
      await _cameraController?.pausePreview();
      final XFile photo = await _cameraController!.takePicture();

      // Run the Roboflow model against the captured image
      final classification = await _identifyTrash(photo.path);

      if (!mounted) {
        return;
      }

      if (classification != null) {
        // Success - show result
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultSuccessScreen(
              imagePath: photo.path,
              wasteType: classification.wasteType ?? classification.label,
              predictedLabel: classification.label,
              confidence: classification.confidence,
            ),
          ),
        );
      } else {
        // Error - couldn't identify
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultErrorScreen(imagePath: photo.path),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error capturing image: $e');
    } finally {
      await _cameraController?.resumePreview();
      if (mounted) {
        setState(() {
          _isProcessingCapture = false;
        });
      } else {
        _isProcessingCapture = false;
      }
    }
  }

  Future<void> _pickFromGallery() async {
    if (_isProcessingCapture || _isClassifying) {
      return;
    }

    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
      );

      if (image == null) {
        debugPrint('No image selected');
        return;
      }

      debugPrint('Image picked: ${image.path}');

      if (mounted) {
        setState(() {
          _isProcessingCapture = true;
        });
      } else {
        _isProcessingCapture = true;
      }

      await _cameraController?.pausePreview();

      // Run the Roboflow model against the gallery image
      final classification = await _identifyTrash(image.path);

      if (!mounted) {
        return;
      }

      if (classification != null) {
        // Success - show result
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultSuccessScreen(
              imagePath: image.path,
              wasteType: classification.wasteType ?? classification.label,
              predictedLabel: classification.label,
              confidence: classification.confidence,
            ),
          ),
        );
      } else {
        // Error - couldn't identify
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ResultErrorScreen(imagePath: image.path),
          ),
        );
      }
    } catch (e) {
      debugPrint('Error picking image: $e');

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
    } finally {
      if (_isProcessingCapture) {
        try {
          await _cameraController?.resumePreview();
        } catch (e) {
          debugPrint('Error resuming preview after gallery pick: $e');
        }

        if (mounted) {
          setState(() {
            _isProcessingCapture = false;
          });
        } else {
          _isProcessingCapture = false;
        }
      }
    }
  }

  void _showError(String message) {
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(fontFamily: 'Kanit')),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
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
                          color: const Color(0xFF484C52).withValues(alpha: 0.3),
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
                                  _isCameraInitialized &&
                                      _cameraController != null
                                  ? CameraPreview(_cameraController!)
                                  : Container(
                                      color: Colors.black.withValues(
                                        alpha: 0.1,
                                      ),
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
                                  color: Colors.white.withValues(alpha: 0.95),
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
                        icon: const Icon(
                          Icons.photo_library_outlined,
                          size: 24,
                        ),
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
          if (_isClassifying)
            Positioned.fill(
              child: AbsorbPointer(
                absorbing: true,
                child: Container(
                  color: Colors.black54,
                  child: const Center(
                    child: CircularProgressIndicator(color: Color(0xFF54AF75)),
                  ),
                ),
              ),
            ),
        ],
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
    this.isTopLeft = false,
    this.isTopRight = false,
    this.isBottomLeft = false,
    this.isBottomRight = false,
  });

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
