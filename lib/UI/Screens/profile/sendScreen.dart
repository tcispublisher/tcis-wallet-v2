// import 'package:crypto_wallet/UI/Screens/profile/sendConfirmationScreen.dart';
// import 'package:flutter/material.dart';
//
// class SendScreen extends StatefulWidget {
//   final Map<String, dynamic> token;
//   final String symbol;
//   final double balance;
//   final double price;
//   final String image;
//   final String walletAddress;
//
//   const SendScreen({
//     super.key,
//     required this.token,
//     required this.symbol,
//     required this.balance,
//     required this.price,
//     required this.image,
//     required this.walletAddress,
//   });
//
//   @override
//   State<SendScreen> createState() => _SendScreenState();
// }
//
// class _SendScreenState extends State<SendScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final TextEditingController _addressController = TextEditingController();
//   final TextEditingController _amountController = TextEditingController();
//   double _gasFee = 0.0001;
//
//   @override
//   void dispose() {
//     _addressController.dispose();
//     _amountController.dispose();
//     super.dispose();
//   }
//
//   void _onSend() {
//     if (_formKey.currentState!.validate()) {
//       Navigator.push(
//         context,
//         MaterialPageRoute(
//           builder: (context) => SendConfirmationScreen(
//             token: widget.token,
//             address: _addressController.text,
//             amount: double.parse(_amountController.text),
//             gasFee: _gasFee,
//           ),
//         ),
//       );
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF131718),
//       appBar: AppBar(
//         backgroundColor: const Color(0xFF131718),
//         elevation: 0,
//         leading: IconButton(
//           icon: const Icon(Icons.arrow_back, color: Colors.white),
//           onPressed: () => Navigator.pop(context),
//         ),
//         title: const Text(
//           'Send',
//           style: TextStyle(color: Colors.white, fontSize: 18),
//         ),
//         actions: [
//           TextButton(
//             onPressed: () {},
//             child: const Text(
//               'Batch send',
//               style: TextStyle(color: Colors.grey, fontSize: 14),
//             ),
//           ),
//         ],
//       ),
//       body: SingleChildScrollView(
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Form(
//             key: _formKey,
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Select token & network',
//                   style: TextStyle(color: Colors.grey, fontSize: 14),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1A1F24),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Row(
//                         children: [
//                           Image.asset(
//                             widget.token['icon'],
//                             width: 24,
//                             height: 24,
//                           ),
//                           const SizedBox(width: 8),
//                           Text(
//                             widget.token['name'],
//                             style: const TextStyle(color: Colors.white, fontSize: 16),
//                           ),
//                         ],
//                       ),
//                       const Text(
//                         'Network: Ethereum',
//                         style: TextStyle(color: Colors.grey, fontSize: 14),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'To',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: _addressController,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: const Color(0xFF1A1F24),
//                     hintText: 'Receiving address',
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide.none,
//                     ),
//                   ),
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter a receiving address';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Amount',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 const SizedBox(height: 8),
//                 TextFormField(
//                   controller: _amountController,
//                   decoration: InputDecoration(
//                     filled: true,
//                     fillColor: const Color(0xFF1A1F24),
//                     hintText: '0.00',
//                     hintStyle: const TextStyle(color: Colors.grey),
//                     suffixText: 'USDT',
//                     suffixStyle: const TextStyle(color: Colors.white),
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                       borderSide: BorderSide.none,
//                     ),
//                     suffixIcon: IconButton(
//                       icon: const Icon(Icons.check_circle, color: Colors.tealAccent),
//                       onPressed: () {},
//                     ),
//                   ),
//                   keyboardType: TextInputType.number,
//                   validator: (value) {
//                     if (value == null || value.isEmpty) {
//                       return 'Please enter an amount';
//                     }
//                     if (double.tryParse(value) == null || double.parse(value) <= 0) {
//                       return 'Please enter a valid amount';
//                     }
//                     return null;
//                   },
//                 ),
//                 const SizedBox(height: 20),
//                 const Text(
//                   'Gas Fee',
//                   style: TextStyle(color: Colors.white, fontSize: 16),
//                 ),
//                 const SizedBox(height: 8),
//                 Container(
//                   padding: const EdgeInsets.all(12),
//                   decoration: BoxDecoration(
//                     color: const Color(0xFF1A1F24),
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text('<0.0001 ETH', style: TextStyle(color: Colors.grey, fontSize: 14)),
//                       const Text('\$0.08', style: TextStyle(color: Colors.white, fontSize: 14)),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//                 Center(
//                   child: SizedBox(
//                     width: MediaQuery.of(context).size.width * 0.7,
//                     child: ElevatedButton(
//                       onPressed: _onSend,
//                       style: ElevatedButton.styleFrom(
//                         backgroundColor: Colors.tealAccent,
//                         padding: const EdgeInsets.symmetric(vertical: 14),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(100),
//                         ),
//                       ),
//                       child: const Text(
//                         'Confirm',
//                         style: TextStyle(
//                           color: Colors.black,
//                           fontWeight: FontWeight.bold,
//                           fontSize: 16,
//                         ),
//                       ),
//                     ),
//                   ),
//                 ),
//                 const SizedBox(height: 20),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }