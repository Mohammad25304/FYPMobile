import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/AddMoneyController.dart';

class AddMoney extends StatelessWidget {
  AddMoney({super.key});

  final controller = Get.put(AddMoneyController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text("Receive Money"),

        backgroundColor: const Color(0xFF1E88E5),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // QR SCAN BUTTON
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 15,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  const Text(
                    "Scan Transaction QR",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E88E5),
                      padding: const EdgeInsets.all(16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.qr_code_scanner_rounded),
                    label: const Text(
                      "Scan QR Code",
                      style: TextStyle(fontSize: 16),
                    ),
                    onPressed: () {
                      Get.toNamed('/qrScan');
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            const Text(
              "Or Enter Details Manually",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),

            _textField(
              label: "Transaction ID",
              icon: Icons.confirmation_number,
              onChanged: (v) => controller.transactionId.value = v,
              value: controller.transactionId,
            ),

            _textField(
              label: "Sender Name",
              icon: Icons.person,
              onChanged: (v) => controller.senderName.value = v,
              value: controller.senderName,
            ),

            _textField(
              label: "Your Phone Number",
              icon: Icons.phone,
              keyboard: TextInputType.phone,
              onChanged: (v) => controller.userPhone.value = v,
              value: controller.userPhone,
            ),

            _textField(
              label: "Amount (optional, or auto via QR)",
              icon: Icons.attach_money,
              keyboard: TextInputType.number,
              onChanged: (v) => controller.amount.value = v,
              value: controller.amount,
            ),

            const SizedBox(height: 20),

            Obx(
              () => ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  minimumSize: const Size(double.infinity, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: controller.isLoading.value
                    ? null
                    : controller.submitAddMoney,
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        "Add Money",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _textField({
    required String label,
    required IconData icon,
    required Function(String) onChanged,
    required RxString value,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Obx(
      () => Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 2),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: TextField(
          keyboardType: keyboard,
          decoration: InputDecoration(
            labelText: label,
            icon: Icon(icon, color: Color(0xFF1E88E5)),
            border: InputBorder.none,
          ),
          onChanged: onChanged,
          controller: TextEditingController(text: value.value)
            ..selection = TextSelection.collapsed(offset: value.value.length),
        ),
      ),
    );
  }
}
