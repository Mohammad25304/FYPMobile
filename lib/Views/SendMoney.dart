import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:cashpilot/Controllers/SendMoneyController.dart';

class SendMoney extends GetView<SendMoneyController> {
  const SendMoney({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF8FAFC),

      appBar: _appBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _currencySelector(),
              const SizedBox(height: 24),

              _amountInput(),
              const SizedBox(height: 24),

              _recipientSelector(),
              const SizedBox(height: 24),

              _noteInput(),
              const SizedBox(height: 32),

              _transactionSummary(),
              const SizedBox(height: 30),

              _sendButton(),
            ],
          ),
        ),
      ),
    );
  }

  // ============================
  // APP BAR
  // ============================
  AppBar _appBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      toolbarHeight: 70,
      leading: IconButton(
        onPressed: () => Get.back(),
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(Icons.arrow_back_rounded, color: Color(0xFF1E293B)),
        ),
      ),
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      title: const Text(
        "Send Money",
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  // ============================
  // CURRENCY SELECTOR
  // ============================
  Widget _currencySelector() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Select Currency"),
          const SizedBox(height: 16),

          Obx(
            () => Row(
              children: [
                _currencyOption("USD", "\$", controller.usdBalance),
                const SizedBox(width: 10),
                _currencyOption("EUR", "€", controller.eurBalance),
                const SizedBox(width: 10),
                _currencyOption("LBP", "LL", controller.lbpBalance),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _currencyOption(String code, String symbol, double balance) {
    return Expanded(
      child: Obx(
        () => InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => controller.selectCurrency(code),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              gradient: controller.selectedCurrency.value == code
                  ? const LinearGradient(
                      colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
                    )
                  : null,
              color: controller.selectedCurrency.value == code
                  ? null
                  : const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: controller.selectedCurrency.value == code
                    ? const Color(0xFF1E88E5)
                    : Colors.transparent,
                width: 2,
              ),
            ),
            child: Column(
              children: [
                Text(
                  code,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: controller.selectedCurrency.value == code
                        ? Colors.white
                        : const Color(0xFF1E293B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$symbol${_formatBalance(balance, code)}",
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: controller.selectedCurrency.value == code
                        ? Colors.white70
                        : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  // AMOUNT INPUT
  // ============================
  Widget _amountInput() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Enter Amount"),
          const SizedBox(height: 16),

          Row(
            children: [
              Obx(
                () => Text(
                  controller.currencySymbol,
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E88E5),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: TextField(
                  controller: controller.amountController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  style: const TextStyle(
                    fontSize: 36,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF1E293B),
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: "0.00",
                    hintStyle: TextStyle(
                      color: Color(0xFFCBD5E1),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  onChanged: controller.updateAmount,
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Available: ${controller.currencySymbol}${_formatBalance(controller.availableBalance, controller.selectedCurrency.value)}",
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w600,
                  ),
                ),

                if (controller.amount.value > 0 &&
                    controller.amount.value <= controller.availableBalance)
                  _statusBadge("✓ Valid", Colors.green),

                if (controller.amount.value > controller.availableBalance)
                  _statusBadge("Insufficient", Colors.red),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statusBadge(String text, Color color) {
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

  // ============================
  // RECIPIENT SELECTOR
  // ============================
  Widget _recipientSelector() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Send To"),
          const SizedBox(height: 16),

          _inputField(
            controller.recipientEmailController,
            "Enter recipient email",
            Icons.email_outlined,
          ),

          const SizedBox(height: 12),

          _inputField(
            controller.recipientNameController,
            "Recipient name (optional)",
            Icons.person_outline_rounded,
          ),

          const SizedBox(height: 12),

          _inputField(
            controller.recipientPhoneController,
            "Recipient phone (optional)",
            Icons.phone_outlined,
            keyboard: TextInputType.phone,
          ),
        ],
      ),
    );
  }

  // ============================
  // NOTE INPUT
  // ============================
  Widget _noteInput() {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _label("Note (Optional)"),
          const SizedBox(height: 12),

          TextField(
            controller: controller.noteController,
            maxLines: 3,
            decoration: _inputDecoration("Add a note for this transaction..."),
          ),
        ],
      ),
    );
  }

  // ============================
  // TRANSACTION SUMMARY
  // ============================
  Widget _transactionSummary() {
    return Obx(() {
      if (controller.amount.value == 0) return const SizedBox.shrink();

      final fee = controller.calculateFee();
      final total = controller.amount.value + fee;

      return _card(
        gradient: true,
        child: Column(
          children: [
            _summaryRow("Amount", controller.amount.value),
            const SizedBox(height: 12),

            _summaryRow("Transaction Fee", fee),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Divider(),
            ),

            _summaryRow("Total", total, bold: true),
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
            fontSize: bold ? 16 : 14,
            fontWeight: bold ? FontWeight.w700 : FontWeight.w600,
          ),
        ),
        Obx(
          () => Text(
            "${controller.currencySymbol}${amount.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: bold ? 18 : 15,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w700,
              color: bold ? const Color(0xFF1E88E5) : Colors.black87,
            ),
          ),
        ),
      ],
    );
  }

  // ============================
  // SEND BUTTON
  // ============================
  Widget _sendButton() {
    return Obx(
      () => GestureDetector(
        onTap: controller.canSend ? controller.sendMoney : null,
        child: Container(
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
                      color: const Color(0xFF1E88E5).withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),

          child: controller.isSending.value
              ? const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 3,
                  ),
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

  // ============================
  // HELPERS
  // ============================
  Widget _card({required Widget child, bool gradient = false}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: gradient
            ? LinearGradient(
                colors: [
                  const Color(0xFF1E88E5).withOpacity(0.1),
                  const Color(0xFF1565C0).withOpacity(0.05),
                ],
              )
            : null,
        color: gradient ? null : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: gradient
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: child,
    );
  }

  Widget _label(String txt) {
    return Text(
      txt,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: Color(0xFF64748B),
      ),
    );
  }

  Widget _inputField(
    TextEditingController controller,
    String hint,
    IconData icon, {
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: _inputDecoration(
        hint,
      ).copyWith(prefixIcon: Icon(icon, color: const Color(0xFF1E88E5))),
    );
  }

  InputDecoration _inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: Colors.grey[400],
        fontWeight: FontWeight.w500,
      ),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
      ),
    );
  }

  String _formatBalance(double balance, String currency) {
    if (currency == "LBP") {
      return balance
          .toStringAsFixed(0)
          .replaceAllMapped(
            RegExp(r"(\d{1,3})(?=(\d{3})+(?!\d))"),
            (m) => "${m[1]},",
          );
    }
    return balance.toStringAsFixed(2);
  }
}
