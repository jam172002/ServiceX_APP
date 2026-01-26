import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/service/screens/profile/widgets/payment_card_widget.dart';
import 'package:servicex_client_app/features/service/screens/profile/widgets/add_new_card_sheet.dart';

class PaymentCardsScreen extends StatefulWidget {
  const PaymentCardsScreen({super.key});

  @override
  State<PaymentCardsScreen> createState() => _PaymentCardsScreenState();
}

class _PaymentCardsScreenState extends State<PaymentCardsScreen> {
  final RxList<Map<String, dynamic>> cards = <Map<String, dynamic>>[
    {
      "number": "4111111111111121",
      "name": "ROBIN WILLIAMS",
      "expiry": "07/32",
      "isDefault": true,
    },
    {
      "number": "5555444433334093",
      "name": "JOHN DOE",
      "expiry": "11/29",
      "isDefault": false,
    },
  ].obs;

  void setDefault(int index) {
    for (int i = 0; i < cards.length; i++) {
      cards[i]['isDefault'] = false;
    }
    cards[index]['isDefault'] = true;
    cards.refresh();
  }

  void confirmDelete(int index) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove Card'),
        content: const Text('Do you want to remove this card?'),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              cards.removeAt(index);
              Get.back();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String detectBrand(String number) {
    if (number.startsWith('4')) return 'VISA';
    if (number.startsWith('5')) return 'MASTERCARD';
    return 'CARD';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Saved Cards'),
      body: Obx(
        () => ListView.builder(
          padding: const EdgeInsets.all(16),

          itemCount: cards.length,
          itemBuilder: (context, index) {
            final card = cards[index];
            return GestureDetector(
              onTap: () => setDefault(index),
              child: PaymentCardWidget(
                number: card['number'],
                name: card['name'],
                expiry: card['expiry'],
                brand: detectBrand(card['number']),
                isDefault: card['isDefault'],
              ),
            );
          },
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: () => addNewCardSheet(cards),
          child: const Text('Add New Card'),
        ),
      ),
    );
  }
}
