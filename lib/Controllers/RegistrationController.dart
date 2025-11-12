import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

class RegistrationController extends GetxController {
  // Observable for current step
  var currentStep = 0.obs;

  // Step 1: Personal Info
  final firstName = TextEditingController();
  final lastName = TextEditingController();
  final fatherName = TextEditingController();
  final motherFullName = TextEditingController();
  final dob = TextEditingController();
  final gender = ''.obs;
  final placeOfBirth = TextEditingController();
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
  final userType = ''.obs;
  final sourceOfIncome = ''.obs;
  final martialStatus = ''.obs;

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
        if (dob.text.isEmpty) {
          _showError('Please enter your date of birth');
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
        if (faceSelfie.value == null) {
          _showError('Please take a live selfie for verification');
          return false;
        }
        return true;

      case 2:
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
      duration: const Duration(seconds: 3),
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
      duration: const Duration(seconds: 2),
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

  // Capture selfie
  Future<void> captureImage(Rx<File?> imageFile) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
        preferredCameraDevice: CameraDevice.front,
      );
      if (image != null) {
        imageFile.value = File(image.path);
        _showSuccess('Selfie captured successfully');
      }
    } catch (e) {
      _showError('Failed to capture image: $e');
    }
  }

  // 🔗 Laravel API Integration
  Future<void> registerUser() async {
    if (!validateCurrentStep()) return;

    try {
      // Show loading
      Get.dialog(
        const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF1E88E5)),
          ),
        ),
        barrierDismissible: false,
      );

      final url = Uri.parse(
        "http://192.168.1.65:8000/api/register",
      ); // Adjust for your setup
      var request = http.MultipartRequest('POST', url);

      request.fields.addAll({
        'firstName': firstName.text,
        'lastName': lastName.text,
        'date_of_birth': dob.text,
        'gender': gender.value.toLowerCase(),
        'place_of_birth': placeOfBirth.text,
        'country': country.value,
        'city': city.text,
        'phone_number': phone.text,
        'email': email.text,
        'Nationality': nationality.value,
        'id_type': idType.value,
        'id_number': idNumber.text,
        'father_name': fatherName.text,
        'mother_name': motherFullName.text,
        'income_source': sourceOfIncome.value,
        'user_type': 'individual',
        'password': password.text,
        'password_confirmation': confirmPassword.text,
      });

      print("📡 Sending registration request to Laravel...");
      print("➡️ URL: $url");
      print("📦 Data: ${request.fields}");

      // Attach images
      if (faceSelfie.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_photo',
            faceSelfie.value!.path,
          ),
        );
      }
      if (idFront.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('id_front', idFront.value!.path),
        );
      }
      if (idBack.value != null) {
        request.files.add(
          await http.MultipartFile.fromPath('id_back', idBack.value!.path),
        );
      }

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();
      var data = json.decode(responseBody);

      Get.back(); // close loading

      if (response.statusCode == 201) {
        Get.snackbar(
          'Success',
          data['message'] ??
              'User registered successfully! Please verify your account via OTP.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
          margin: const EdgeInsets.all(16),
          borderRadius: 8,
          duration: const Duration(seconds: 4),
        );

        // Navigate to OTP verification page (optional)
        // Get.toNamed('/verify-otp', arguments: email.text);
      } else {
        Get.snackbar(
          'Error',
          data['message'] ?? 'Registration failed!',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.back();
      _showError('Failed to connect to the server: $e');
    }
  }

  @override
  void onClose() {
    firstName.dispose();
    lastName.dispose();
    dob.dispose();
    placeOfBirth.dispose();
    city.dispose();
    phone.dispose();
    email.dispose();
    idNumber.dispose();
    fatherName.dispose();
    motherFullName.dispose();
    password.dispose();
    confirmPassword.dispose();
    super.onClose();
  }
}
