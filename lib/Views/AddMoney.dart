import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/AddMoneyController.dart';

class ReceiveCashPickupPage extends GetView<ReceiveCashPickupController> {
  const ReceiveCashPickupPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _appBar(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _infoBanner(),
            const SizedBox(height: 20),

            _inputField(
              controller.pickupCodeController,
              "Pickup Code",
              Icons.qr_code_rounded,
            ),
            const SizedBox(height: 12),

            _inputField(
              controller.receiverPhoneController,
              "Receiver Phone Number",
              Icons.phone,
              keyboard: TextInputType.phone,
            ),
            const SizedBox(height: 30),

            _receiveButton(),
          ],
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      backgroundColor: const Color(0xFF1E88E5),
      title: const Text("Receive Cash"),
      centerTitle: true,
    );
  }

  Widget _infoBanner() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: const [
          Icon(Icons.info_outline, color: Color(0xFF1E88E5)),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              "Enter the pickup code and phone number to receive the cash.",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputField(
    TextEditingController c,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: c,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _receiveButton() {
    return Obx(
      () => ElevatedButton(
        onPressed: controller.canReceive ? controller.receiveCashPickup : null,
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 56),
          backgroundColor: Colors.green,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: controller.isLoading.value
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                "Receive Money",
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
