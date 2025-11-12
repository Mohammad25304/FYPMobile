import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/RegistrationController.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Registration extends GetView<RegistrationController> {
  const Registration({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          "Sign Up",
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        backgroundColor: const Color(0xFF1E88E5),
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      body: SafeArea(
        child: Obx(() {
          return Column(
            children: [
              _buildProgressIndicator(),
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: _buildStepContent(),
                  ),
                ),
              ),
              _buildNavigationButtons(),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(5, (index) {
          final isActive = controller.currentStep.value >= index;
          final isCompleted = controller.currentStep.value > index;

          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isActive
                              ? const Color(0xFF1E88E5)
                              : Colors.grey[300],
                          border: Border.all(
                            color: isActive
                                ? const Color(0xFF1E88E5)
                                : Colors.grey[400]!,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(
                                  Icons.check,
                                  color: Colors.white,
                                  size: 20,
                                )
                              : Text(
                                  '${index + 1}',
                                  style: TextStyle(
                                    color: isActive
                                        ? Colors.white
                                        : Colors.grey[600],
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _getStepTitle(index),
                        style: TextStyle(
                          fontSize: 10,
                          color: isActive ? Colors.black87 : Colors.grey[600],
                          fontWeight: isActive
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                if (index < 4)
                  Container(
                    height: 2,
                    width: 20,
                    color: controller.currentStep.value > index
                        ? const Color(0xFF1E88E5)
                        : Colors.grey[300],
                    margin: const EdgeInsets.only(bottom: 30),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  String _getStepTitle(int index) {
    switch (index) {
      case 0:
        return 'Personal';
      case 1:
        return 'Face Verify';
      case 2:
        return 'Identity';
      case 3:
        return 'Financial';
      case 4:
        return 'Account';
      default:
        return '';
    }
  }

  Widget _buildStepContent() {
    switch (controller.currentStep.value) {
      case 0:
        return _buildPersonalInfoStep();
      case 1:
        return _buildFaceVerificationStep();
      case 2:
        return _buildIdentityInfoStep();
      case 3:
        return _buildFinancialInfoStep();
      case 4:
        return _buildAccountSetupStep();
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildPersonalInfoStep() {
    return _StepCard(
      title: 'Personal Information',
      subtitle: 'Please provide your personal details',
      children: [
        _CustomTextField(
          controller: controller.firstName,
          label: 'First Name',
          icon: Icons.person_outline,
        ),
        _CustomTextField(
          controller: controller.lastName,
          label: 'Last Name',
          icon: Icons.person_outline,
        ),
        _CustomTextField(
          controller: controller.fatherName,
          label: 'Father Name',
          icon: Icons.person_2_outlined,
        ),

        _CustomTextField(
          controller: controller.motherFullName,
          label: 'Mother FullName',
          icon: Icons.person_2_outlined,
        ),

        _CustomTextField(
          controller: controller.dob,
          label: 'Date of Birth',
          icon: Icons.calendar_today_outlined,
          hint: 'DD/MM/YYYY',
        ),
        _CustomDropdown(
          value: controller.gender.value.isEmpty
              ? null
              : controller.gender.value,
          label: 'Gender',
          icon: Icons.wc_outlined,
          items: const ['Male', 'Female'],
          onChanged: (val) => controller.gender.value = val!,
        ),
        _CustomTextField(
          controller: controller.placeOfBirth,
          label: "Place Of Birth",
          icon: Icons.location_city_outlined,
        ),
        _CustomDropdown(
          value: controller.country.value.isEmpty
              ? null
              : controller.country.value,
          label: 'Country',
          icon: Icons.public_outlined,
          items: const ['USA', 'Lebanon', 'Other'],
          onChanged: (String? value) => controller.country.value = value!,
        ),
        _CustomTextField(
          controller: controller.city,
          label: 'City',
          icon: Icons.location_city_outlined,
        ),
        _CustomTextField(
          controller: controller.phone,
          label: 'Phone Number',
          icon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),
        _CustomTextField(
          controller: controller.email,
          label: 'Email Address',
          icon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
        ),
      ],
    );
  }

  Widget _buildIdentityInfoStep() {
    return _StepCard(
      title: 'Identity Verification',
      subtitle: 'Upload your identification documents',
      children: [
        Expanded(
          child: _CustomDropdown(
            value: controller.nationality.value.isEmpty
                ? null
                : controller.nationality.value,
            label: "Nationality",
            icon: Icons.flag_outlined,
            items: const [
              "Afghanistan",
              "Albania",
              "Algeria",
              "Andorra",
              "Angola",
              "Antigua and Barbuda",
              "Argentina",
              "Armenia",
              "Australia",
              "Austria",
              "Azerbaijan",
              "Bahamas",
              "Bahrain",
              "Bangladesh",
              "Barbados",
              "Belarus",
              "Belgium",
              "Belize",
              "Benin",
              "Bhutan",
              "Bolivia",
              "Bosnia and Herzegovina",
              "Botswana",
              "Brazil",
              "Brunei",
              "Bulgaria",
              "Burkina Faso",
              "Burundi",
              "Cabo Verde",
              "Cambodia",
              "Cameroon",
              "Canada",
              "Central African Republic",
              "Chad",
              "Chile",
              "China",
              "Colombia",
              "Comoros",
              "Congo",
              "Costa Rica",
              "Croatia",
              "Cuba",
              "Cyprus",
              "Czech Republic",
              "Denmark",
              "Djibouti",
              "Dominica",
              "Dominican Republic",
              "East Timor",
              "Ecuador",
              "Egypt",
              "El Salvador",
              "Equatorial Guinea",
              "Eritrea",
              "Estonia",
              "Eswatini",
              "Ethiopia",
              "Fiji",
              "Finland",
              "France",
              "Gabon",
              "Gambia",
              "Georgia",
              "Germany",
              "Ghana",
              "Greece",
              "Grenada",
              "Guatemala",
              "Guinea",
              "Guinea-Bissau",
              "Guyana",
              "Haiti",
              "Honduras",
              "Hungary",
              "Iceland",
              "India",
              "Indonesia",
              "Iran",
              "Iraq",
              "Ireland",
              "Israel",
              "Italy",
              "Jamaica",
              "Japan",
              "Jordan",
              "Kazakhstan",
              "Kenya",
              "Kiribati",
              "Kosovo",
              "Kuwait",
              "Kyrgyzstan",
              "Laos",
              "Latvia",
              "Lebanon",
              "Lesotho",
              "Liberia",
              "Libya",
              "Liechtenstein",
              "Lithuania",
              "Luxembourg",
              "Madagascar",
              "Malawi",
              "Malaysia",
              "Maldives",
              "Mali",
              "Malta",
              "Marshall Islands",
              "Mauritania",
              "Mauritius",
              "Mexico",
              "Micronesia",
              "Moldova",
              "Monaco",
              "Mongolia",
              "Montenegro",
              "Morocco",
              "Mozambique",
              "Myanmar",
              "Namibia",
              "Nauru",
              "Nepal",
              "Netherlands",
              "New Zealand",
              "Nicaragua",
              "Niger",
              "Nigeria",
              "North Korea",
              "North Macedonia",
              "Norway",
              "Oman",
              "Pakistan",
              "Palau",
              "Palestine",
              "Panama",
              "Papua New Guinea",
              "Paraguay",
              "Peru",
              "Philippines",
              "Poland",
              "Portugal",
              "Qatar",
              "Romania",
              "Russia",
              "Rwanda",
              "Saint Kitts and Nevis",
              "Saint Lucia",
              "Saint Vincent and the Grenadines",
              "Samoa",
              "San Marino",
              "Sao Tome and Principe",
              "Saudi Arabia",
              "Senegal",
              "Serbia",
              "Seychelles",
              "Sierra Leone",
              "Singapore",
              "Slovakia",
              "Slovenia",
              "Solomon Islands",
              "Somalia",
              "South Africa",
              "South Korea",
              "South Sudan",
              "Spain",
              "Sri Lanka",
              "Sudan",
              "Suriname",
              "Sweden",
              "Switzerland",
              "Syria",
              "Taiwan",
              "Tajikistan",
              "Tanzania",
              "Thailand",
              "Togo",
              "Tonga",
              "Trinidad and Tobago",
              "Tunisia",
              "Turkey",
              "Turkmenistan",
              "Tuvalu",
              "Uganda",
              "Ukraine",
              "United Arab Emirates",
              "United Kingdom",
              "United States",
              "Uruguay",
              "Uzbekistan",
              "Vanuatu",
              "Vatican City",
              "Venezuela",
              "Vietnam",
              "Yemen",
              "Zambia",
              "Zimbabwe",
            ],
            onChanged: (String? value) => controller.nationality.value = value!,
          ),
        ),
        _CustomDropdown(
          value: controller.idType.value.isEmpty
              ? null
              : controller.idType.value,
          label: 'ID Type',
          icon: Icons.badge_outlined,
          items: const ['National ID', 'Passport'],
          onChanged: (val) => controller.idType.value = val!,
        ),
        _CustomTextField(
          controller: controller.idNumber,
          label: 'ID Number',
          icon: Icons.numbers_outlined,
        ),
        const SizedBox(height: 10),
        _ImageUploadCard(
          title: 'ID Front',
          image: controller.idFront.value,
          onUpload: () => controller.pickImage(controller.idFront),
        ),
        const SizedBox(height: 16),
        _ImageUploadCard(
          title: 'ID Back',
          image: controller.idBack.value,
          onUpload: () => controller.pickImage(controller.idBack),
        ),
      ],
    );
  }

  Widget _buildFaceVerificationStep() {
    return _StepCard(
      title: 'Face Verification',
      subtitle: 'Take a live selfie to verify your identity',
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.blue[200]!),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue[700], size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Please ensure your face is clearly visible and well-lit',
                  style: TextStyle(color: Colors.blue[900], fontSize: 13),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _LivePhotoCapture(
          title: 'Your Selfie',
          image: controller.faceSelfie.value,
          onCapture: () => controller.captureImage(controller.faceSelfie),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(Icons.verified_user, color: Colors.green[700], size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'This helps us ensure account security and prevent identity theft',
                  style: TextStyle(color: Colors.green[900], fontSize: 12),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFinancialInfoStep() {
    return _StepCard(
      title: 'Financial Information',
      subtitle: 'Tell us about your financial background',
      children: [
        _CustomDropdown(
          value: controller.userType.value.isEmpty
              ? null
              : controller.userType.value,
          label: 'Account Type',
          icon: Icons.account_box,
          items: const [
            'Personal Account',
            'Business Account',
            'Company Account',
          ],
          onChanged: (val) => controller.userType.value = val!,
        ),
        _CustomDropdown(
          value: controller.sourceOfIncome.value.isEmpty
              ? null
              : controller.sourceOfIncome.value,
          label: 'Source of Income',
          icon: Icons.account_balance_wallet_outlined,
          items: const [
            'Salary',
            'Income from own Business',
            'Income from Investments',
            'Rent',
            'Retirement/Pension',
            'Inheritance',
            'Savings',
            'Loan',
            'Sale of Property',
            'Lottery/Gambling',
            'Other',
          ],
          onChanged: (val) => controller.sourceOfIncome.value = val!,
        ),
        _CustomDropdown(
          value: controller.martialStatus.value.isEmpty
              ? null
              : controller.martialStatus.value,
          label: 'Martial Status',
          icon: Icons.favorite,
          items: const ['Single', 'Married', 'Divorced', 'Widowed'],
          onChanged: (val) => controller.martialStatus.value = val!,
        ),
      ],
    );
  }

  Widget _buildAccountSetupStep() {
    return _StepCard(
      title: 'Account Setup',
      subtitle: 'Create your secure account credentials',
      children: [
        _CustomTextField(
          controller: controller.password,
          label: 'Password',
          icon: Icons.lock_outline,
          obscureText: true,
          keyboardType: TextInputType.numberWithOptions(),
        ),
        _CustomTextField(
          controller: controller.confirmPassword,
          label: 'Confirm Password',
          icon: Icons.lock_outline,
          obscureText: true,
          keyboardType: TextInputType.numberWithOptions(),
        ),
        const SizedBox(height: 10),
        Obx(
          () => Container(
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.blue[100]!),
            ),
            child: CheckboxListTile(
              value: controller.agreeTerms.value,
              onChanged: (val) => controller.agreeTerms.value = val ?? false,
              title: const Text(
                'I agree to the Terms & Conditions',
                style: TextStyle(fontSize: 14),
              ),
              activeColor: const Color(0xFF1E88E5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (controller.currentStep.value > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: controller.previousStep,
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: const BorderSide(color: Color(0xFF1E88E5)),
                ),
                child: const Text(
                  'Back',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          if (controller.currentStep.value > 0) const SizedBox(width: 12),
          Expanded(
            flex: controller.currentStep.value > 0 ? 1 : 1,
            child: ElevatedButton(
              onPressed: controller.currentStep.value == 4
                  ? controller.registerUser
                  : controller.nextStep,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E88E5),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                controller.currentStep.value == 4 ? 'Finish' : 'Next',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Reusable Widgets

class _StepCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _StepCard({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          const SizedBox(height: 24),
          ...children,
        ],
      ),
    );
  }
}

class _CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final String? hint;

  const _CustomTextField({
    required this.controller,
    required this.label,
    required this.icon,
    this.obscureText = false,
    this.keyboardType,
    this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}

class _CustomDropdown extends StatelessWidget {
  final String? value;
  final String label;
  final IconData icon;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  const _CustomDropdown({
    required this.value,
    required this.label,
    required this.icon,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        initialValue: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
      ),
    );
  }
}

class _ImageUploadCard extends StatelessWidget {
  final String title;
  final dynamic image;
  final VoidCallback onUpload;

  const _ImageUploadCard({
    required this.title,
    required this.image,
    required this.onUpload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          if (image == null)
            InkWell(
              onTap: onUpload,
              child: Container(
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF1E88E5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.cloud_upload_outlined,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Upload $title',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Tap to select image',
                        style: TextStyle(color: Colors.grey[400], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    image,
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onUpload,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Change Image'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _LivePhotoCapture extends StatelessWidget {
  final String title;
  final dynamic image;
  final VoidCallback onCapture;

  const _LivePhotoCapture({
    required this.title,
    required this.image,
    required this.onCapture,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          if (image == null)
            InkWell(
              onTap: onCapture,
              child: Container(
                height: 250,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: const Color(0xFF1E88E5),
                    width: 2,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue[50],
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          size: 64,
                          color: Colors.blue[700],
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Take Live Selfie',
                        style: TextStyle(
                          color: Colors.grey[700],
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tap to open camera',
                        style: TextStyle(color: Colors.grey[500], fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Column(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        image,
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 16,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Verified',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: onCapture,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Retake Photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E88E5),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
