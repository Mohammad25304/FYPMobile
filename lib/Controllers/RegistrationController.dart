import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class RegistrationController extends GetxController {
  // Observable for current step
  var currentStep = 0.obs;

  // Step 1: Personal Info
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final dob = TextEditingController();
  final gender = ''.obs;
  final PlaceOfBirth = TextEditingController();
  final country = ''.obs;
  final city = TextEditingController();
  final phone = TextEditingController();
  final email = TextEditingController();

  // Step 2: Face Verification
  final faceSelfie = Rx<File?>(null);

  // Step 3: Identity Info
  final nationality = ''.obs;
  final idType = ''.obs;
  final idNumber = TextEditingController();
  final idFront = Rx<File?>(null);
  final idBack = Rx<File?>(null);

  // Step 4: Financial Info
  final sourceOfIncome = ''.obs;
  final fatherName = TextEditingController();
  final motherName = TextEditingController();

  // Step 5: Account Setup
  final password = TextEditingController();
  final confirmPassword = TextEditingController();
  final agreeTerms = false.obs;

  final ImagePicker _picker = ImagePicker();

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
      case 0: // Personal Info
        if (firstName.text.isEmpty) {
          _showError('Please enter your first name');
          return false;
        }
        if (lastName.text.isEmpty) {
          _showError('Please enter your last name');
          return false;
        }
        if (dob.text.isEmpty) {
          _showError('Please enter your date of birth');
          return false;
        }
        if (gender.value.isEmpty) {
          _showError('Please select your gender');
          return false;
        }
        if (PlaceOfBirth.text.isEmpty) {
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

      case 1: // Face Verification
        if (faceSelfie.value == null) {
          _showError('Please take a live selfie for verification');
          return false;
        }
        return true;

      case 2: // Identity Info
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

      case 3: // Financial Info
        if (sourceOfIncome.value.isEmpty) {
          _showError('Please select your source of income');
          return false;
        }
        if (fatherName.text.isEmpty) {
          _showError("Please enter your father's name");
          return false;
        }
        if (motherName.text.isEmpty) {
          _showError("Please enter your mother's name");
          return false;
        }
        return true;

      case 4: // Account Setup
        if (password.text.isEmpty || password.text.length < 8) {
          _showError('Password must be at least 8 characters');
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

  // Helper method to show error messages
  void _showError(String message) {
    Get.snackbar(
      'Error',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 3),
    );
  }

  // Helper method to show success messages
  void _showSuccess(String message) {
    Get.snackbar(
      'Success',
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 8,
      duration: const Duration(seconds: 2),
    );
  }

  // Pick image from gallery (for ID documents)
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

  // Capture image from camera (for live selfie)
  Future<void> captureImage(Rx<File?> imageFile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice:
            CameraDevice.front, // Use front camera for selfie
      );

      if (image != null) {
        imageFile.value = File(image.path);
        _showSuccess('Selfie captured successfully');
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  // Register user
  Future<void> registerUser() async {
    if (!validateCurrentStep()) return;

    try {
      // Show loading dialog
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
          ),
        ),
        barrierDismissible: false,
      );

      // TODO: Implement your registration API call here
      // Example API payload:
      final registrationData = {
        // Personal Info
        'firstName': firstName.text,
        'lastName': lastName.text,
        'dob': dob.text,
        'gender': gender.value,
        'placeOfBirth': PlaceOfBirth.text,
        'country': country.value,
        'city': city.text,
        'phone': phone.text,
        'email': email.text,

        // Identity Info
        'nationality': nationality.value,
        'idType': idType.value,
        'idNumber': idNumber.text,

        // Financial Info
        'sourceOfIncome': sourceOfIncome.value,
        'fatherName': fatherName.text,
        'motherName': motherName.text,

        // Account Setup
        'password': password.text,
      };

      // TODO: Upload images (idFront, idBack, faceSelfie) to your server
      // Example:
      // await ApiService.uploadImage('faceSelfie', faceSelfie.value);
      // await ApiService.uploadImage('idFront', idFront.value);
      // await ApiService.uploadImage('idBack', idBack.value);

      // TODO: Send registration data to your API
      // await ApiService.register(registrationData);

      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));

      // Close loading dialog
      Get.back();

      // Show success message
      Get.snackbar(
        'Success',
        'Account created successfully! Please check your email to verify your account.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(16),
        borderRadius: 8,
        duration: const Duration(seconds: 4),
      );

      // Navigate to login or home page after a short delay
      await Future.delayed(const Duration(seconds: 2));
      // Get.offAllNamed('/login');
    } catch (e) {
      // Close loading dialog
      Get.back();
      _showError('Registration failed: $e');
    }
  }

  @override
  void onClose() {
    // Dispose controllers
    firstName.dispose();
    lastName.dispose();
    dob.dispose();
    PlaceOfBirth.dispose();
    city.dispose();
    phone.dispose();
    email.dispose();
    idNumber.dispose();
    fatherName.dispose();
    motherName.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
