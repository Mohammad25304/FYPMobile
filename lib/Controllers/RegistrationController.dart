import 'package:flutter/foundation.dart';
import 'package:get/get.dart' hide FormData, MultipartFile;
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:cashpilot/Core/Network/DioClient.dart';

class RegistrationController extends GetxController {
  // Observable for current step
  var currentStep = 0.obs;

  // Step 1: Personal Info
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final fatherName = TextEditingController();
  final motherFullName = TextEditingController();
  final age = TextEditingController();
  final gender = ''.obs;
  final placeOfBirth = TextEditingController();
  final country = ''.obs;
  final city = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();

  // Step 2: Face Verification
  final faceSelfie = Rx<File?>(null);

  // ML Kit Face Detection
  CameraController? cameraController;
  final faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableLandmarks: true,
      enableContours: true,
      enableClassification: true,
      minFaceSize: 0.15,
    ),
  );
  var isFaceDetected = false.obs;
  var faceDetectionMessage = 'Position your face in the frame'.obs;
  var isCameraInitialized = false.obs;
  var isDetecting = false;
  var isCapturing = false.obs;

  // Step 3: Identity Info
  final nationality = ''.obs;
  final idType = ''.obs;
  final idNumber = TextEditingController();
  final idFront = Rx<File?>(null);
  final idBack = Rx<File?>(null);

  // Step 4: Financial Info
  final userType = ''.obs;
  final sourceOfIncome = ''.obs;
  final martialStatus = ''.obs;

  // Step 5: Account Setup
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final agreeTerms = false.obs;

  final ImagePicker _picker = ImagePicker();

  // Initialize camera for face detection
  Future<void> initializeCamera() async {
    try {
      // Request camera permission
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        _showError('Camera permission is required for face verification');
        return;
      }

      final cameras = await availableCameras();
      final frontCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => cameras.first,
      );

      cameraController = CameraController(
        frontCamera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await cameraController!.initialize();
      isCameraInitialized.value = true;

      // Start image stream for face detection
      await cameraController!.startImageStream((CameraImage image) async {
        if (!isDetecting && !isCapturing.value) {
          isDetecting = true;
          await detectFaceInImage(image);
          isDetecting = false;
        }
      });
    } catch (e) {
      _showError('Camera initialization failed: $e');
      print('Camera error: $e');
    }
  }

  // Get proper image rotation based on device orientation
  InputImageRotation _getImageRotation(CameraImage image) {
    if (cameraController == null) return InputImageRotation.rotation0deg;

    final camera = cameraController!.description;
    final sensorOrientation = camera.sensorOrientation;

    // For front camera, we need to adjust rotation
    InputImageRotation rotation;

    if (Platform.isIOS) {
      rotation = InputImageRotation.values[(sensorOrientation ~/ 90) % 4];
    } else {
      // Android
      final rotationCompensation = sensorOrientation;
      rotation = InputImageRotation.values[rotationCompensation ~/ 90];
    }

    return rotation;
  }

  // Detect face in camera stream
  Future<void> detectFaceInImage(CameraImage image) async {
    try {
      final WriteBuffer allBytes = WriteBuffer();
      for (Plane plane in image.planes) {
        allBytes.putUint8List(plane.bytes);
      }
      final bytes = allBytes.done().buffer.asUint8List();

      final inputImage = InputImage.fromBytes(
        bytes: bytes,
        metadata: InputImageMetadata(
          size: Size(image.width.toDouble(), image.height.toDouble()),
          rotation: _getImageRotation(image),
          format: Platform.isAndroid
              ? InputImageFormat.nv21
              : InputImageFormat.bgra8888,
          bytesPerRow: image.planes[0].bytesPerRow,
        ),
      );

      final List<Face> faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        isFaceDetected.value = false;
        faceDetectionMessage.value =
            'No face detected - please position yourself';
      } else if (faces.length > 1) {
        isFaceDetected.value = false;
        faceDetectionMessage.value =
            'Multiple faces detected - ensure only you are visible';
      } else {
        final face = faces.first;

        // Check face quality
        if (_isFaceQualityGood(face)) {
          isFaceDetected.value = true;
          faceDetectionMessage.value = '✓ Face detected! Ready to capture';
        } else {
          isFaceDetected.value = false;
          faceDetectionMessage.value = _getFaceQualityMessage(face);
        }
      }
    } catch (e) {
      print('Face detection error: $e');
    }
  }

  // Check if face quality is good
  bool _isFaceQualityGood(Face face) {
    // Check if face is centered and large enough
    final boundingBox = face.boundingBox;
    final faceArea = boundingBox.width * boundingBox.height;
    final imageArea = 640.0 * 480.0; // approximate camera resolution
    final faceRatio = faceArea / imageArea;

    // Face should occupy 15-60% of the frame
    if (faceRatio < 0.15 || faceRatio > 0.60) {
      return false;
    }

    // Check head rotation (should be relatively frontal)
    final headEulerAngleY = face.headEulerAngleY; // Horizontal rotation
    final headEulerAngleZ = face.headEulerAngleZ; // Tilt

    // FIXED: Check if null OR value exceeds threshold
    if (headEulerAngleY == null || headEulerAngleY!.abs() > 20) {
      return false;
    }

    if (headEulerAngleZ == null || headEulerAngleZ!.abs() > 15) {
      return false;
    }

    // Check if eyes are open (if classification is available)
    final leftEyeOpenProbability = face.leftEyeOpenProbability;
    final rightEyeOpenProbability = face.rightEyeOpenProbability;

    if (leftEyeOpenProbability == null || leftEyeOpenProbability! < 0.5) {
      return false;
    }

    if (rightEyeOpenProbability == null || rightEyeOpenProbability! < 0.5) {
      return false;
    }

    return true;
  }

  // Get specific face quality message
  String _getFaceQualityMessage(Face face) {
    final boundingBox = face.boundingBox;
    final faceArea = boundingBox.width * boundingBox.height;
    final imageArea = 640.0 * 480.0;
    final faceRatio = faceArea / imageArea;

    if (faceRatio < 0.15) {
      return 'Move closer to the camera';
    }
    if (faceRatio > 0.60) {
      return 'Move back from the camera';
    }

    final headEulerAngleY = face.headEulerAngleY;
    if (headEulerAngleY == null || headEulerAngleY!.abs() > 20) {
      return 'Look straight at the camera';
    }

    final headEulerAngleZ = face.headEulerAngleZ;
    if (headEulerAngleZ == null || headEulerAngleZ!.abs() > 15) {
      return 'Keep your head straight';
    }

    final leftEyeOpenProbability = face.leftEyeOpenProbability;
    final rightEyeOpenProbability = face.rightEyeOpenProbability;

    if (leftEyeOpenProbability == null ||
        rightEyeOpenProbability == null ||
        leftEyeOpenProbability! < 0.5 ||
        rightEyeOpenProbability! < 0.5) {
      return 'Please keep both eyes open';
    }

    return 'Adjust your position';
  }

  // Capture photo with face validation
  Future<void> captureFacePhoto() async {
    if (!isFaceDetected.value) {
      _showError('Please wait for face detection to complete');
      return;
    }

    if (isCapturing.value) {
      return; // Already capturing
    }

    try {
      isCapturing.value = true;

      if (cameraController == null || !cameraController!.value.isInitialized) {
        _showError('Camera not initialized');
        isCapturing.value = false;
        return;
      }

      // Stop the image stream and wait for it to complete
      if (cameraController!.value.isStreamingImages) {
        await cameraController!.stopImageStream();
        // Wait a bit for the stream to fully stop
        await Future.delayed(const Duration(milliseconds: 300));
      }

      // Capture the image
      final XFile image = await cameraController!.takePicture();

      // Validate the captured image has a face
      final inputImage = InputImage.fromFilePath(image.path);
      final faces = await faceDetector.processImage(inputImage);

      if (faces.isEmpty) {
        _showError('No face detected in captured photo. Please try again.');
        isCapturing.value = false;
        // Restart image stream
        await cameraController!.startImageStream((CameraImage img) async {
          if (!isDetecting && !isCapturing.value) {
            isDetecting = true;
            await detectFaceInImage(img);
            isDetecting = false;
          }
        });
        return;
      }

      faceSelfie.value = File(image.path);
      _showSuccess('Face verified and captured successfully!');

      // Dispose camera after successful capture
      await disposeCamera();
    } catch (e) {
      _showError('Failed to capture photo: $e');
      print('Capture error: $e');
      isCapturing.value = false;
    } finally {
      isCapturing.value = false;
    }
  }

  // Dispose camera resources
  Future<void> disposeCamera() async {
    if (cameraController != null) {
      try {
        if (cameraController!.value.isStreamingImages) {
          await cameraController!.stopImageStream();
        }
        await cameraController!.dispose();
      } catch (e) {
        print('Error disposing camera: $e');
      } finally {
        cameraController = null;
        isCameraInitialized.value = false;
        isCapturing.value = false;
      }
    }
  }

  // Retake photo
  Future<void> retakeFacePhoto() async {
    faceSelfie.value = null;
    isFaceDetected.value = false;
    isCapturing.value = false;
    await initializeCamera();
  }

  // Navigation methods
  void nextStep() {
    if (currentStep.value < 4) {
      if (validateCurrentStep()) {
        currentStep.value++;
      }
    }
  }

  void previousStep() {
    if (currentStep.value > 0) {
      currentStep.value--;
    }
  }

  // Validation for current step
  bool validateCurrentStep() {
    switch (currentStep.value) {
      case 0:
        if (firstName.text.isEmpty) {
          _showError('Please enter your first name');
          return false;
        }
        if (lastName.text.isEmpty) {
          _showError('Please enter your last name');
          return false;
        }
        if (fatherName.text.isEmpty) {
          _showError("Please enter your father name");
          return false;
        }
        if (motherFullName.text.isEmpty) {
          _showError("Please enter your mother name");
          return false;
        }
        if (age.text.isEmpty) {
          _showError('Please enter your age');
          return false;
        }
        // Check if age is valid number and >= 18
        final ageValue = int.tryParse(age.text);
        if (ageValue == null || ageValue < 18) {
          _showError('Sorry, you must be 18 or older to create an account');
          return false;
        }
        if (gender.value.isEmpty) {
          _showError('Please select your gender');
          return false;
        }
        if (placeOfBirth.text.isEmpty) {
          _showError('Please enter your place of birth');
          return false;
        }
        if (country.value.isEmpty) {
          _showError('Please select your country');
          return false;
        }
        if (city.text.isEmpty) {
          _showError('Please enter your city');
          return false;
        }
        if (phone.text.isEmpty) {
          _showError('Please enter your phone number');
          return false;
        }
        if (email.text.isEmpty || !GetUtils.isEmail(email.text)) {
          _showError('Please enter a valid email address');
          return false;
        }
        return true;

      case 1:
        if (nationality.value.isEmpty) {
          _showError('Please select your nationality');
          return false;
        }
        if (idType.value.isEmpty) {
          _showError('Please select an ID type');
          return false;
        }
        if (idNumber.text.isEmpty) {
          _showError('Please enter your ID number');
          return false;
        }
        if (idFront.value == null || idBack.value == null) {
          _showError('Please upload both front and back of your ID');
          return false;
        }
        return true;

      case 2:
        if (faceSelfie.value == null) {
          _showError('Please take a live selfie for verification');
          return false;
        }
        return true;

      case 3:
        if (userType.value.isEmpty) {
          _showError('Please select your account type');
          return false;
        }
        if (sourceOfIncome.value.isEmpty) {
          _showError('Please select your source of income');
          return false;
        }

        if (martialStatus.value.isEmpty) {
          _showError('Please enter your martial status');
          return false;
        }
        return true;

      case 4:
        if (password.text.isEmpty ||
            password.text.length != 4 ||
            !RegExp(r'^\d+$').hasMatch(password.text)) {
          _showError('Password must be exactly 4 numbers');
          return false;
        }
        if (password.text != confirmPassword.text) {
          _showError('Passwords do not match');
          return false;
        }
        if (!agreeTerms.value) {
          _showError('Please agree to the Terms & Conditions');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  // Helper messages
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 1),
    );
  }

  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 1),
    );
  }

  // Pick image from gallery
  Future<void> pickImage(Rx<File?> imageFile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        imageFile.value = File(image.path);
        _showSuccess('Image uploaded successfully');
      }
    } catch (e) {
      _showError('Failed to pick image: $e');
    }
  }

  // Legacy capture method (keep for ID photos)
  Future<void> captureImage(Rx<File?> imageFile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image != null) {
        imageFile.value = File(image.path);
        _showSuccess('Image captured successfully');
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  // 🔗 Laravel API Integration
  Future<void> registerUser() async {
    if (!validateCurrentStep()) return;

    try {
      // Show loading dialog
      Get.dialog(
        const Center(child: CircularProgressIndicator()),
        barrierDismissible: false,
      );

      final dio = DioClient().getInstance();

      // PREPARE FORM DATA
      FormData formData = FormData.fromMap({
        "first_name": firstName.text,
        "last_name": lastName.text,
        "father_name": fatherName.text,
        "mother_full_name": motherFullName.text,
        "age": age.text,
        "gender": gender.value,
        "place_of_birth": placeOfBirth.text,
        "country": country.value,
        "city": city.text,
        "phone": phone.text,
        "email": email.text,

        "nationality": nationality.value,
        "id_type": idType.value,
        "id_number": idNumber.text,

        "user_type": userType.value,
        "source_of_income": sourceOfIncome.value,
        "marital_status": martialStatus.value,

        "password": password.text,
        "password_confirmation": confirmPassword.text,
        "agree_terms": agreeTerms.value ? "1" : "0",

        // FILES
        "id_front": await MultipartFile.fromFile(
          idFront.value!.path,
          filename: "id_front.jpg",
        ),

        "id_back": await MultipartFile.fromFile(
          idBack.value!.path,
          filename: "id_back.jpg",
        ),

        "face_selfie": await MultipartFile.fromFile(
          faceSelfie.value!.path,
          filename: "face_selfie.jpg",
        ),
      });

      // SEND REQUEST
      final response = await dio.post(
        "register",
        data: formData,
        options: Options(contentType: "multipart/form-data"),
      );

      Get.back(); // Close loading

      // SUCCESS
      Get.snackbar(
        "Success",
        "Registration complete! OTP sent to your email.",
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
      await Future.delayed(const Duration(milliseconds: 500));

      // 🚀 Navigate to OTP screen
      Get.toNamed(
        "/otp",
        arguments: {"email": email.text, "phone": phone.text},
      );
    } catch (e) {
      Get.back();

      if (e is DioException) {
        print("❌ Dio Error: ${e.response?.data}");
        Get.snackbar(
          "Error",
          e.response?.data["message"] ??
              e.response?.data.toString() ??
              "Unexpected error",
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      } else {
        Get.snackbar(
          "Error",
          e.toString(),
          backgroundColor: Colors.red,
          colorText: Colors.white,
          duration: const Duration(seconds: 1),
        );
      }
    }
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    age.dispose();
    placeOfBirth.dispose();
    city.dispose();
    phone.dispose();
    email.dispose();
    idNumber.dispose();
    fatherName.dispose();
    motherFullName.dispose();
    password.dispose();
    confirmPassword.dispose();
    faceDetector.close();
    disposeCamera();
    super.onClose();
  }
}
