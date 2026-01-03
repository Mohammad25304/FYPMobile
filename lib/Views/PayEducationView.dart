// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import '../Controllers/PayEducationController.dart';

// class PayEducationView extends GetView<PayEducationController> {
//   const PayEducationView({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFFF8F9FA),
//       appBar: AppBar(
//         elevation: 0,
//         backgroundColor: const Color(0xFF1E88E5),
//         foregroundColor: Colors.white,
//         title: Text(
//           '${controller.provider['name'] ?? 'Education'} Payment',
//           style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
//         ),
//         centerTitle: true,
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
//           child: Column(
//             children: [
//               _providerCard(),
//               const SizedBox(height: 32),
//               _studentInfoForm(),
//               const SizedBox(height: 20),
//               _paymentForm(),
//               const SizedBox(height: 24),
//               _feeBreakdown(),
//               const SizedBox(height: 32),
//               _payButton(),
//               const SizedBox(height: 20),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _providerCard() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         gradient: const LinearGradient(
//           colors: [Color(0xFF1E88E5), Color(0xFF1565C0)],
//           begin: Alignment.topLeft,
//           end: Alignment.bottomRight,
//         ),
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: const Color(0xFF1E88E5).withOpacity(0.3),
//             blurRadius: 12,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: Column(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: Colors.white.withOpacity(0.2),
//               borderRadius: BorderRadius.circular(12),
//             ),
//             child: const Icon(Icons.school, color: Colors.white, size: 32),
//           ),
//           const SizedBox(height: 12),
//           Text(
//             controller.provider['name'] ?? 'Education Institution',
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 18,
//               fontWeight: FontWeight.w600,
//             ),
//             textAlign: TextAlign.center,
//           ),
//           const SizedBox(height: 4),
//           Text(
//             'Education Fee Payment',
//             style: TextStyle(
//               color: Colors.white.withOpacity(0.8),
//               fontSize: 13,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _studentInfoForm() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.person, color: Color(0xFF1E88E5), size: 20),
//               const SizedBox(width: 8),
//               const Text(
//                 'Student Information',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildTextField(
//             controller: controller.studentIdController,
//             label: 'Student ID',
//             icon: Icons.badge,
//             keyboardType: TextInputType.text,
//             hint: 'Enter student ID number',
//           ),
//           const SizedBox(height: 16),
//           _buildTextField(
//             controller: controller.studentNameController,
//             label: 'Student Name',
//             icon: Icons.person_outline,
//             keyboardType: TextInputType.name,
//             hint: 'Enter full name',
//           ),
//           const SizedBox(height: 16),
//           _buildTextField(
//             controller: controller.semesterController,
//             label: 'Semester/Year',
//             icon: Icons.calendar_today,
//             keyboardType: TextInputType.text,
//             hint: 'e.g., Fall 2024, Year 3',
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _paymentForm() {
//     return Container(
//       padding: const EdgeInsets.all(20),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(20),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.08),
//             blurRadius: 12,
//             offset: const Offset(0, 2),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               const Icon(Icons.payment, color: Color(0xFF1E88E5), size: 20),
//               const SizedBox(width: 8),
//               const Text(
//                 'Payment Details',
//                 style: TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w600,
//                   color: Color(0xFF2C3E50),
//                 ),
//               ),
//             ],
//           ),
//           const SizedBox(height: 20),
//           _buildPaymentTypeDropdown(),
//           const SizedBox(height: 16),
//           _buildCurrencyDropdown(),
//           const SizedBox(height: 16),
//           Obx(
//             () => _buildTextField(
//               controller: controller.amountController,
//               label: 'Amount',
//               icon: Icons.attach_money,
//               keyboardType: TextInputType.number,
//               hint: 'Enter amount (${controller.selectedCurrency.value})',
//               suffix: controller.selectedCurrency.value,
//             ),
//           ),
//           const SizedBox(height: 16),
//           _buildTextField(
//             controller: controller.notesController,
//             label: 'Notes (Optional)',
//             icon: Icons.note_alt,
//             keyboardType: TextInputType.text,
//             hint: 'Add any additional notes',
//             maxLines: 3,
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     required TextInputType keyboardType,
//     required String hint,
//     String? suffix,
//     int maxLines = 1,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(
//           label,
//           style: const TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         const SizedBox(height: 8),
//         TextField(
//           controller: controller,
//           keyboardType: keyboardType,
//           maxLines: maxLines,
//           textCapitalization: keyboardType == TextInputType.name
//               ? TextCapitalization.words
//               : TextCapitalization.none,
//           decoration: InputDecoration(
//             hintText: hint,
//             hintStyle: TextStyle(color: Colors.grey[400]),
//             prefixIcon: Icon(icon, color: const Color(0xFF1E88E5)),
//             suffixText: suffix,
//             suffixStyle: const TextStyle(
//               fontWeight: FontWeight.w600,
//               color: Color(0xFF1E88E5),
//             ),
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             enabledBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: BorderSide(color: Colors.grey[300]!),
//             ),
//             focusedBorder: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12),
//               borderSide: const BorderSide(color: Color(0xFF1E88E5), width: 2),
//             ),
//             filled: true,
//             fillColor: Colors.grey[50],
//             contentPadding: EdgeInsets.symmetric(
//               horizontal: 16,
//               vertical: maxLines > 1 ? 14 : 14,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPaymentTypeDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Payment Type',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Obx(
//           () => Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: DropdownButtonFormField<String>(
//               value: controller.selectedPaymentType.value,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(
//                   Icons.category,
//                   color: Color(0xFF1E88E5),
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 4,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//               items: controller.paymentTypes
//                   .map(
//                     (type) => DropdownMenuItem(value: type, child: Text(type)),
//                   )
//                   .toList(),
//               onChanged: (value) {
//                 if (value != null) {
//                   controller.onPaymentTypeChanged(value);
//                 }
//               },
//               isExpanded: true,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildCurrencyDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text(
//           'Currency',
//           style: TextStyle(
//             fontSize: 13,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF2C3E50),
//           ),
//         ),
//         const SizedBox(height: 8),
//         Obx(
//           () => Container(
//             decoration: BoxDecoration(
//               borderRadius: BorderRadius.circular(12),
//               border: Border.all(color: Colors.grey[300]!),
//             ),
//             child: DropdownButtonFormField<String>(
//               value: controller.selectedCurrency.value,
//               decoration: InputDecoration(
//                 prefixIcon: const Icon(
//                   Icons.currency_exchange,
//                   color: Color(0xFF1E88E5),
//                 ),
//                 border: InputBorder.none,
//                 contentPadding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 4,
//                 ),
//                 filled: true,
//                 fillColor: Colors.grey[50],
//               ),
//               items: const [
//                 DropdownMenuItem(value: 'USD', child: Text('USD - US Dollar')),
//                 DropdownMenuItem(value: 'EUR', child: Text('EUR - Euro')),
//                 DropdownMenuItem(
//                   value: 'LBP',
//                   child: Text('LBP - Lebanese Pound'),
//                 ),
//               ],
//               onChanged: (value) {
//                 if (value != null) {
//                   controller.onCurrencyChanged(value);
//                 }
//               },
//               isExpanded: true,
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _feeBreakdown() {
//     return Obx(() {
//       if (controller.amount.value <= 0) {
//         return const SizedBox.shrink();
//       }

//       return Container(
//         padding: const EdgeInsets.all(20),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [
//               const Color(0xFF1E88E5).withOpacity(0.1),
//               const Color(0xFF1565C0).withOpacity(0.05),
//             ],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(16),
//           border: Border.all(
//             color: const Color(0xFF1E88E5).withOpacity(0.2),
//             width: 1,
//           ),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               children: [
//                 const Icon(
//                   Icons.receipt_long,
//                   color: Color(0xFF1E88E5),
//                   size: 20,
//                 ),
//                 const SizedBox(width: 8),
//                 const Text(
//                   'Payment Summary',
//                   style: TextStyle(
//                     fontSize: 15,
//                     fontWeight: FontWeight.w600,
//                     color: Color(0xFF2C3E50),
//                   ),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//             _buildFeeRow(
//               controller.selectedPaymentType.value,
//               controller.amount.value,
//               controller.selectedCurrency.value,
//               false,
//             ),
//             const SizedBox(height: 10),
//             controller.isFetchingFee.value
//                 ? _buildLoadingRow()
//                 : _buildFeeRow(
//                     'Processing Fee',
//                     controller.fee.value,
//                     controller.selectedCurrency.value,
//                     false,
//                   ),
//             const Padding(
//               padding: EdgeInsets.symmetric(vertical: 12),
//               child: Divider(thickness: 1, color: Color(0xFF1E88E5)),
//             ),
//             _buildFeeRow(
//               'Total',
//               controller.total.value,
//               controller.selectedCurrency.value,
//               true,
//             ),
//           ],
//         ),
//       );
//     });
//   }

//   Widget _buildFeeRow(
//     String label,
//     double value,
//     String currency,
//     bool isTotal,
//   ) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Flexible(
//           child: Text(
//             label,
//             style: TextStyle(
//               fontSize: isTotal ? 16 : 14,
//               fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
//               color: isTotal
//                   ? const Color(0xFF2C3E50)
//                   : const Color(0xFF5A6C7D),
//             ),
//             overflow: TextOverflow.ellipsis,
//           ),
//         ),
//         const SizedBox(width: 8),
//         Text(
//           '${value.toStringAsFixed(2)} $currency',
//           style: TextStyle(
//             fontSize: isTotal ? 18 : 14,
//             fontWeight: isTotal ? FontWeight.w700 : FontWeight.w500,
//             color: isTotal ? const Color(0xFF1E88E5) : const Color(0xFF2C3E50),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildLoadingRow() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         const Text(
//           'Processing Fee',
//           style: TextStyle(
//             fontSize: 14,
//             fontWeight: FontWeight.w500,
//             color: Color(0xFF5A6C7D),
//           ),
//         ),
//         Row(
//           children: [
//             SizedBox(
//               height: 12,
//               width: 12,
//               child: CircularProgressIndicator(
//                 strokeWidth: 2,
//                 valueColor: AlwaysStoppedAnimation(
//                   const Color(0xFF1E88E5).withOpacity(0.6),
//                 ),
//               ),
//             ),
//             const SizedBox(width: 8),
//             Text(
//               'Calculating...',
//               style: TextStyle(
//                 fontSize: 12,
//                 color: Colors.grey[600],
//                 fontStyle: FontStyle.italic,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _payButton() {
//     return Obx(
//       () => SizedBox(
//         width: double.infinity,
//         height: 56,
//         child: ElevatedButton(
//           onPressed: controller.isLoading.value ? null : controller.pay,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF1E88E5),
//             disabledBackgroundColor: Colors.grey[300],
//             elevation: 4,
//             shadowColor: const Color(0xFF1E88E5).withOpacity(0.4),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(14),
//             ),
//           ),
//           child: controller.isLoading.value
//               ? Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     SizedBox(
//                       height: 24,
//                       width: 24,
//                       child: CircularProgressIndicator(
//                         strokeWidth: 2.5,
//                         valueColor: AlwaysStoppedAnimation(
//                           Colors.white.withOpacity(0.9),
//                         ),
//                       ),
//                     ),
//                     const SizedBox(width: 12),
//                     const Text(
//                       'Processing...',
//                       style: TextStyle(
//                         fontSize: 16,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                       ),
//                     ),
//                   ],
//                 )
//               : Row(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   children: [
//                     const Icon(Icons.payment, color: Colors.white, size: 20),
//                     const SizedBox(width: 10),
//                     const Text(
//                       'Pay Now',
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.w600,
//                         color: Colors.white,
//                         letterSpacing: 0.5,
//                       ),
//                     ),
//                   ],
//                 ),
//         ),
//       ),
//     );
//   }
// }
