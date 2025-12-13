import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cashpilot/Controllers/SendMoneyController.dart';

class SendMoney extends GetView<SendMoneyController> {
  const SendMoney({super.key});

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
              _currencySelector(),
              const SizedBox(height: 20),

              _amountInput(),
              const SizedBox(height: 20),

              _recipientSection(),
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

  // APP BAR ----------------------------------------------------
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
        "Send Money",
        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
      ),
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.only(left: 10),
        child: IconButton(
          onPressed: () => Get.back(),
          icon: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.white),
          ),
        ),
      ),
    );
  }

  // CURRENCY SELECTOR -----------------------------------------
  Widget _currencySelector() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Choose Currency"),
          const SizedBox(height: 16),

          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _currencyBox("USD", "\$", controller.usdBalance),
                _currencyBox("EUR", "€", controller.eurBalance),
                _currencyBox("LBP", "LL", controller.lbpBalance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyBox(String code, String symbol, double balance) {
    final selected = controller.selectedCurrency.value == code;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectCurrency(code),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          margin: const EdgeInsets.symmetric(horizontal: 5),
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
            boxShadow: selected
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 12,
                    ),
                  ]
                : [],
          ),
          child: Column(
            children: [
              Text(
                code,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: selected ? Colors.white : Colors.black87,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "$symbol${balance.toStringAsFixed(2)}",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: selected ? Colors.white70 : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // AMOUNT INPUT ----------------------------------------------
  Widget _amountInput() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Enter Amount"),
          const SizedBox(height: 14),

          Row(
            children: [
              Obx(
                () => Text(
                  controller.currencySymbol,
                  style: const TextStyle(
                    fontSize: 40,
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
                    fontSize: 40,
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

          const SizedBox(height: 12),

          Obx(() {
            final fee = controller.calculateFee();
            final total = controller.amount.value + fee;

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
                    total <= controller.availableBalance)
                  _badge("Valid ✓", Colors.green),

                if (controller.amount.value > 0 &&
                    total > controller.availableBalance)
                  _badge("Insufficient", Colors.red),
              ],
            );
          }),
        ],
      ),
    );
  }

  // RECIPIENT SECTION -----------------------------------------
  Widget _recipientSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Recipient Details"),
          const SizedBox(height: 16),

          _inputField(
            controller.recipientEmailController,
            "Recipient Email",
            Icons.email_outlined,
          ),
          const SizedBox(height: 12),

          _inputField(
            controller.recipientNameController,
            "Recipient Name (optional)",
            Icons.person_outline,
          ),
          const SizedBox(height: 12),

          _inputField(
            controller.recipientPhoneController,
            "Phone (optional)",
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // NOTE SECTION ----------------------------------------------
  Widget _noteSection() {
    return _sectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Add Note (Optional)"),
          const SizedBox(height: 10),

          TextField(
            controller: controller.noteController,
            maxLines: 3,
            decoration: _inputDecoration("Write a short message..."),
          ),
        ],
      ),
    );
  }

  // SUMMARY SECTION -------------------------------------------
  Widget _summarySection() {
    return Obx(() {
      if (controller.amount.value == 0) return const SizedBox.shrink();

      final fee = controller.calculateFee();
      final total = controller.amount.value + fee;

      return _sectionCard(
        gradient: true,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _summaryRow("Amount", controller.amount.value),
            const SizedBox(height: 12),

            _summaryRow("Service Fee", fee),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(color: Colors.white54),
            ),

            _summaryRow("Total to Pay", total, bold: true),
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

  // SEND BUTTON ------------------------------------------------
  Widget _sendButton() {
    return Obx(
      () => GestureDetector(
        onTap: controller.canSend ? controller.sendMoney : null,
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
            boxShadow: controller.canSend
                ? [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.4),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: controller.isSending.value
              ? const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.send_rounded,
                      color: controller.canSend
                          ? Colors.white
                          : Colors.grey[500],
                    ),
                    const SizedBox(width: 10),
                    Text(
                      "Send Money",
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: controller.canSend
                            ? Colors.white
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // --------- HELPERS -----------------------------------------

  Widget _sectionCard({required Widget child, bool gradient = false}) {
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
      child: child,
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: Color(0xFF1E293B),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey[400]),
      filled: true,
      fillColor: const Color(0xFFF1F5F9),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
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
