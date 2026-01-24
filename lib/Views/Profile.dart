import 'dart:ui';

import 'package:cashpilot/Controllers/ProfileController.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class Profile extends GetView<ProfileController> {
  const Profile({super.key});

  // Modern Color Palette
  static const Color primaryBlue = Color(0xFF1E88E5);
  static const Color secondaryBlue = Color(0xFF1E88E5);
  static const Color backgroundGray = Color(0xFFF8FAFC);
  static const Color textDark = Color(0xFF0F172A);
  static const Color textLight = Color(0xFF64748B);
  static const Color successGreen = Color(0xFF10B981);
  static const Color warningOrange = Color(0xFFF59E0B);
  static const Color errorRed = Color(0xFFEF4444);
  static const Color borderGray = Color(0xFFE2E8F0);

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return successGreen;
      case 'rejected':
      case 'deactivated':
        return errorRed;
      case 'pending':
      default:
        return warningOrange;
    }
  }

  String _statusLabel(String status) {
    switch (status.toLowerCase()) {
      case 'active':
      case 'approved':
        return 'Activated';
      case 'rejected':
        return 'Rejected';
      case 'deactivated':
        return 'Deactivated';
      case 'pending':
      default:
        return 'Pending Review';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundGray,
      appBar: AppBar(
        backgroundColor: primaryBlue, // ✅ blue like Wallet
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'My Profile',
          style: TextStyle(
            color: Colors.white, // ✅ white text
            fontWeight: FontWeight.w800,
            fontSize: 20,
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white, // ✅ white back icon
            size: 20,
          ),
          onPressed: () => Get.back(),
        ),
      ),

      body: SafeArea(
        child: Obx(
          () => controller.isLoading.value
              ? const Center(
                  child: CircularProgressIndicator(color: primaryBlue),
                )
              : RefreshIndicator(
                  onRefresh: () => controller.fetchProfile(),
                  color: primaryBlue,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Account Details'),
                        _buildAccountInfo(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Security & Privacy'),
                        _buildSecuritySection(),
                        const SizedBox(height: 24),
                        _buildSectionTitle('Verification Documents'),
                        _buildDocumentsSection(),
                        const SizedBox(height: 32),
                        _buildDangerZone(),
                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: textLight,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [primaryBlue, secondaryBlue],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  radius: 45,
                  backgroundColor: backgroundGray,
                  backgroundImage: controller.avatarUrl.value.isNotEmpty
                      ? NetworkImage(controller.avatarUrl.value)
                      : null,
                  child: controller.avatarUrl.value.isEmpty
                      ? Text(
                          controller.name.value.isNotEmpty
                              ? controller.name.value[0].toUpperCase()
                              : 'U',
                          style: const TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: primaryBlue,
                          ),
                        )
                      : null,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.verified_rounded,
                    size: 22,
                    color: _statusColor(controller.status.value),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            controller.name.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            controller.email.value,
            style: TextStyle(
              color: Colors.white.withOpacity(0.8),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(30),
              border: Border.all(color: Colors.white.withOpacity(0.2)),
            ),
            child: Text(
              _statusLabel(controller.status.value).toUpperCase(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAccountInfo() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray),
      ),
      child: Column(
        children: [
          _infoTile(
            icon: Icons.person_rounded,
            label: 'Full Name',
            value: controller.name.value,
          ),
          _divider(),
          _infoTile(
            icon: Icons.alternate_email_rounded,
            label: 'Email Address',
            value: controller.email.value,
          ),
          _divider(),
          _infoTile(
            icon: Icons.phone_iphone_rounded,
            label: 'Phone Number',
            value: controller.phone.value.isEmpty
                ? 'Not provided'
                : controller.phone.value,
          ),
          _divider(),
          _infoTile(
            icon: Icons.badge_rounded,
            label: 'Account Type',
            value: controller.accountType.value.capitalizeFirst ?? 'Basic',
            isLast: true,
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => _showEditProfileSheet(),
                style: TextButton.styleFrom(
                  backgroundColor: primaryBlue.withOpacity(0.08),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Edit Profile Information',
                  style: TextStyle(
                    color: primaryBlue,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: backgroundGray,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: primaryBlue),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    color: textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: textDark,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _divider() =>
      const Divider(height: 1, indent: 60, endIndent: 20, color: borderGray);

  Widget _buildSecuritySection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: borderGray),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showChangePasswordSheet(),
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFEEF2FF),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.lock_reset_rounded,
                    size: 22,
                    color: Color(0xFF1E88E5),
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Change Password',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: textDark,
                        ),
                      ),
                      Text(
                        'Keep your account secure',
                        style: TextStyle(fontSize: 12, color: textLight),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDocumentsSection() {
    return Column(
      children: [
        _documentCard(
          'Identity Card (Front)',
          controller.idFrontUrl.value,
          Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _documentCard(
          'Identity Card (Back)',
          controller.idBackUrl.value,
          Icons.badge_outlined,
        ),
        const SizedBox(height: 12),
        _documentCard(
          'Selfie Verification',
          controller.selfieUrl.value,
          Icons.face_retouching_natural_rounded,
        ),
      ],
    );
  }

  Widget _documentCard(String title, String url, IconData icon) {
    final bool hasDoc = url.isNotEmpty;
    final RxBool reveal = false.obs;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderGray),
      ),
      child: Row(
        children: [
          // IMAGE + BLUR
          Obx(
            () => GestureDetector(
              onLongPressStart: hasDoc ? (_) => reveal.value = true : null,
              onLongPressEnd: hasDoc ? (_) => reveal.value = false : null,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: backgroundGray,
                        image: hasDoc
                            ? DecorationImage(
                                image: NetworkImage(url),
                                fit: BoxFit.cover,
                              )
                            : null,
                      ),
                      child: !hasDoc
                          ? Icon(icon, color: textLight.withOpacity(0.5))
                          : null,
                    ),

                    // 🔒 BLUR LAYER
                    if (hasDoc && !reveal.value)
                      Positioned.fill(
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
                          child: Container(
                            color: Colors.black.withOpacity(0.15),
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.lock_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // TEXT
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDoc ? 'Hold to view securely' : 'Not uploaded yet',
                  style: TextStyle(
                    fontSize: 12,
                    color: hasDoc ? successGreen : warningOrange,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            hasDoc ? Icons.verified_rounded : Icons.error_outline_rounded,
            color: hasDoc ? successGreen : warningOrange,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.warning_amber_rounded, color: errorRed, size: 20),
              SizedBox(width: 8),
              Text(
                'Danger Zone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF991B1B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Deactivating your account will restrict access to all features. This action can only be reversed by contacting support.',
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFFB91C1C),
              height: 1.4,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _confirmDeleteAccount,
              style: ElevatedButton.styleFrom(
                backgroundColor: errorRed,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: Obx(
                () => controller.isDeleting.value
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Deactivate My Account',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Sheets and Dialogs (Maintained logic, improved UI)
  void _showEditProfileSheet() {
    final firstNameCtrl = TextEditingController(
      text: controller.firstName.value,
    );
    final lastNameCtrl = TextEditingController(text: controller.lastName.value);
    final phoneCtrl = TextEditingController(text: controller.phone.value);

    Get.bottomSheet(
      _buildSheetWrapper(
        title: 'Edit Profile',
        child: Column(
          children: [
            _buildTextField(
              controller: firstNameCtrl,
              label: 'First Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: lastNameCtrl,
              label: 'Last Name',
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: phoneCtrl,
              label: 'Phone Number',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 32),
            _buildPrimaryButton(
              onPressed: () => controller.updateProfile(
                newFirstName: firstNameCtrl.text,
                newLastName: lastNameCtrl.text,
                newPhone: phoneCtrl.text,
              ),
              label: 'Save Changes',
              isLoading: controller.isSavingProfile,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  void _showChangePasswordSheet() {
    final currentCtrl = TextEditingController();
    final newCtrl = TextEditingController();
    final confirmCtrl = TextEditingController();

    Get.bottomSheet(
      _buildSheetWrapper(
        title: 'Change Password',
        child: Column(
          children: [
            _buildTextField(
              controller: currentCtrl,
              label: 'Current Password',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: newCtrl,
              label: 'New Password',
              icon: Icons.lock_reset_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: confirmCtrl,
              label: 'Confirm New Password',
              icon: Icons.lock_reset_rounded,
              isPassword: true,
            ),
            const SizedBox(height: 32),
            _buildPrimaryButton(
              onPressed: () => controller.changePassword(
                currentPassword: currentCtrl.text,
                newPassword: newCtrl.text,
                confirmPassword: confirmCtrl.text,
              ),
              label: 'Update Password',
              isLoading: controller.isChangingPassword,
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

  Widget _buildSheetWrapper({required String title, required Widget child}) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        Get.mediaQuery.viewInsets.bottom + 32,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: borderGray,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: textDark,
              ),
            ),
            const SizedBox(height: 24),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool isPassword = false,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword,
      keyboardType: keyboardType,
      style: const TextStyle(fontWeight: FontWeight.w600, color: textDark),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, size: 20, color: primaryBlue),
        labelStyle: const TextStyle(
          color: textLight,
          fontWeight: FontWeight.w500,
        ),
        filled: true,
        fillColor: backgroundGray,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildPrimaryButton({
    required VoidCallback onPressed,
    required String label,
    required RxBool isLoading,
  }) {
    return SizedBox(
      width: double.infinity,
      child: Obx(
        () => ElevatedButton(
          onPressed: isLoading.value ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: primaryBlue,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: isLoading.value
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                )
              : Text(
                  label,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
        ),
      ),
    );
  }

  void _confirmDeleteAccount() {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text(
          'Deactivate Account?',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text(
          'This will log you out and disable your access. Are you sure you want to proceed?',
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: textLight, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: controller.isDeleting.value
                ? null
                : () {
                    Get.back();
                    _showDeleteAccountSheet();
                  },

            style: ElevatedButton.styleFrom(
              backgroundColor: errorRed,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Obx(
              () => controller.isDeleting.value
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'Deactivate',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountSheet() {
    final passwordCtrl = TextEditingController();
    final confirm = false.obs;

    Get.bottomSheet(
      _buildSheetWrapper(
        title: 'Confirm Account Deletion',
        child: Column(
          children: [
            _buildTextField(
              controller: passwordCtrl,
              label: 'Password',
              icon: Icons.lock_outline,
              isPassword: true,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Obx(
                  () => Checkbox(
                    value: confirm.value,
                    onChanged: (v) => confirm.value = v ?? false,
                    activeColor: errorRed,
                  ),
                ),
                const Expanded(
                  child: Text(
                    'I understand this action is permanent',
                    style: TextStyle(fontSize: 13),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: Obx(
                () => ElevatedButton(
                  onPressed:
                      controller.isDeletingAccount.value || !confirm.value
                      ? null
                      : () {
                          controller.deleteAccount(password: passwordCtrl.text);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: errorRed,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: controller.isDeletingAccount.value
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          'Delete My Account',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                ),
              ),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }
}
