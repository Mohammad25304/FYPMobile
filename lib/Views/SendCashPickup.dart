import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/CashPickupController.dart';

class SendCashPickup extends GetView<CashPickupController> {
  const SendCashPickup({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: _appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _infoBanner(),
              const SizedBox(height: 20),

              _receiverSection(),
              const SizedBox(height: 20),

              _transferSection(),
              const SizedBox(height: 20),

              _noteSection(),
              const SizedBox(height: 25),

              _summarySection(),
              const SizedBox(height: 30),

              _sendButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ================= APP BAR =================
  AppBar _appBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      toolbarHeight: 80,
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
          ),
        ),
      ),
      title: const Text(
        "Send Cash (Pickup)",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      centerTitle: true,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: const Icon(Icons.arrow_back, color: Colors.white),
      ),
    );
  }

  // ================= INFO =================
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
          SizedBox(width: 12),
          Expanded(
            child: Text(
              "Receiver can collect cash from a CashPilot location using phone number and a valid ID.",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ================= RECEIVER =================
  Widget _receiverSection() {
    return _sectionCard(
      title: "Receiver Information",
      child: Column(
        children: [
          _inputField(
            controller.receiverNameController,
            "Full Name",
            Icons.person_outline,
          ),
          const SizedBox(height: 12),
          _inputField(
            controller.receiverPhoneController,
            "Phone Number",
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _inputField(
            controller.receiverEmailController,
            "Email (Optional)",
            Icons.email_outlined,
            keyboard: TextInputType.emailAddress,
          ),
        ],
      ),
    );
  }

  // ================= TRANSFER =================
  Widget _transferSection() {
    return _sectionCard(
      title: "Transfer Details",
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _currencySelector(),
          const SizedBox(height: 16),

          Row(
            children: [
              Obx(
                () => Text(
                  controller.currencySymbol,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: TextInputType.number,
                  onChanged: controller.updateAmount,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: const InputDecoration(
                    hintText: "0.00",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          Obx(() {
            if (controller.isFeeLoading.value) {
              return const LinearProgressIndicator(minHeight: 3);
            }

            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available: ${controller.currencySymbol}${controller.availableBalance.toStringAsFixed(2)}",
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (controller.amount.value > 0 &&
                    controller.total.value <= controller.availableBalance)
                  _badge("Valid ✓", Colors.green),
                if (controller.amount.value > 0 &&
                    controller.total.value > controller.availableBalance)
                  _badge("Insufficient", Colors.red),
              ],
            );
          }),
        ],
      ),
    );
  }

  // ================= NOTE =================
  Widget _noteSection() {
    return _sectionCard(
      title: "Note (Optional)",
      child: TextField(
        controller: controller.noteController,
        maxLines: 3,
        decoration: _inputDecoration("Write a note..."),
      ),
    );
  }

  // ================= SUMMARY =================
  Widget _summarySection() {
    return Obx(() {
      if (controller.amount.value == 0) return const SizedBox.shrink();

      return _sectionCard(
        gradient: true,
        child: Column(
          children: [
            _summaryRow("Amount", controller.amount.value),
            const SizedBox(height: 12),
            _summaryRow("Service Fee", controller.fee.value),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white54),
            ),
            _summaryRow("Total to Pay", controller.total.value, bold: true),
          ],
        ),
      );
    });
  }

  Widget _summaryRow(String title, double amount, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: bold ? 17 : 14,
            fontWeight: bold ? FontWeight.bold : FontWeight.w600,
            color: bold ? Colors.white : Colors.white70,
          ),
        ),
        Obx(
          () => Text(
            "${controller.currencySymbol}${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: bold ? 20 : 15,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ================= SEND BUTTON =================
  Widget _sendButton() {
    return Obx(
      () => GestureDetector(
        onTap: controller.canSend ? controller.sendCashPickup : null,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: controller.canSend
                ? const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  )
                : null,
            color: controller.canSend ? null : Colors.grey[300],
            borderRadius: BorderRadius.circular(18),
          ),
          child: controller.isSending.value
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : const Center(
                  child: Text(
                    "Send Cash",
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  // ================= HELPERS =================
  Widget _currencySelector() {
    return Obx(
      () => Row(
        children: [
          _currencyBox("USD"),
          _currencyBox("EUR"),
          _currencyBox("LBP"),
        ],
      ),
    );
  }

  Widget _currencyBox(String code) {
    final selected = controller.selectedCurrency.value == code;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectCurrency(code),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 5),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            gradient: selected
                ? const LinearGradient(
                    colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                  )
                : null,
            color: selected ? null : Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected ? Colors.transparent : Colors.grey.shade300,
              width: 2,
            ),
          ),
          child: Center(
            child: Text(
              code,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: selected ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _sectionCard({
    String? title,
    required Widget child,
    bool gradient = false,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient
            ? const LinearGradient(
                colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
              )
            : null,
        color: gradient ? null : Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(
              title,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 16),
          ],
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
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
      decoration: _inputDecoration(
        hint,
      ).copyWith(prefixIcon: Icon(icon, color: const Color(0xFF1E88E5))),
    );
  }

  Widget _badge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
        ),
      ),
    );
  }
}
