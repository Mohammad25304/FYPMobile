import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../Controllers/PayInternetController.dart';

class PayInternetView extends GetView<PayInternetController> {
  const PayInternetView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${controller.provider['name']} Internet'),
        backgroundColor: const Color(0xFF1E88E5),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: controller.accountController,
              decoration: const InputDecoration(
                labelText: 'Account Number',
                prefixIcon: Icon(Icons.wifi),
              ),
            ),
            const SizedBox(height: 16),

            Obx(
              () => DropdownButtonFormField<String>(
                value: controller.selectedCurrency.value,
                items: const [
                  DropdownMenuItem(value: 'USD', child: Text('USD')),
                  DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  DropdownMenuItem(value: 'LBP', child: Text('LBP')),
                ],
                onChanged: (v) => controller.selectedCurrency.value = v!,
                decoration: const InputDecoration(labelText: 'Currency'),
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: controller.amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Amount',
                prefixIcon: Icon(Icons.attach_money),
              ),
            ),

            const Spacer(),

            ElevatedButton(
              onPressed: controller.pay,
              child: const Text('Pay Internet'),
            ),
          ],
        ),
      ),
    );
  }
}
