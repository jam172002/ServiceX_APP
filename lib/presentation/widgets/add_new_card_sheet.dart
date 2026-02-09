import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/card_input_field.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

void addNewCardSheet(
  RxList<Map<String, dynamic>> cards, {
  Function(Map<String, dynamic>)? onCardAdded,
}) {
  final numberCtrl = TextEditingController();
  final nameCtrl = TextEditingController();
  final RxString selectedMonth = ''.obs;
  final RxString selectedYear = ''.obs;

  final RxString numberError = ''.obs;
  final RxString nameError = ''.obs;
  final RxString expiryError = ''.obs;

  final List<String> months = List.generate(
    12,
    (i) => (i + 1).toString().padLeft(2, '0'),
  );
  final int currentYear = DateTime.now().year;
  final List<String> years = List.generate(
    12,
    (i) => (currentYear + i).toString().substring(2),
  );

  Get.bottomSheet(
    Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(Get.context!).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  'Add Payment Card',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(height: 16),
              Obx(
                () => CardInputField(
                  hint: 'Card Number',
                  controller: numberCtrl,
                  keyboardType: TextInputType.number,
                  maxLength: 19,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    CardNumberInputFormatter(),
                  ],
                  errorText: numberError.value,
                ),
              ),
              const SizedBox(height: 12),
              Obx(
                () => CardInputField(
                  hint: 'Card Holder Name',
                  controller: nameCtrl,
                  keyboardType: TextInputType.name,
                  errorText: nameError.value,
                ),
              ),
              const SizedBox(height: 12),
              Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedMonth.value.isEmpty
                            ? null
                            : selectedMonth.value,

                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          label: Text('Month'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),

                        style: const TextStyle(
                          color: Colors.black,
                          fontSize: 14,
                        ),

                        iconEnabledColor: Colors.black,

                        items: months.map((m) {
                          return DropdownMenuItem<String>(
                            value: m,
                            child: Text(
                              m,
                              style: const TextStyle(color: Colors.black),
                            ),
                          );
                        }).toList(),

                        dropdownColor: Colors.white,

                        onChanged: (v) => selectedMonth.value = v ?? '',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedYear.value.isEmpty
                            ? null
                            : selectedYear.value,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.shade100,
                          label: Text('Year'),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        iconEnabledColor: Colors.black,
                        items: years
                            .map(
                              (y) => DropdownMenuItem(value: y, child: Text(y)),
                            )
                            .toList(),
                        dropdownColor: XColors.secondaryBG,
                        style: TextStyle(color: XColors.black),
                        onChanged: (v) => selectedYear.value = v ?? '',
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    bool isValid = true;
                    numberError.value = '';
                    nameError.value = '';
                    expiryError.value = '';

                    String number = numberCtrl.text.replaceAll(' ', '').trim();
                    String name = nameCtrl.text.trim();
                    String expiry =
                        '${selectedMonth.value}/${selectedYear.value}';

                    if (number.isEmpty ||
                        number.length != 16 ||
                        !RegExp(r'^[0-9]+$').hasMatch(number)) {
                      numberError.value = 'Enter a valid 16-digit number';
                      isValid = false;
                    } else if (!number.startsWith('4') &&
                        !number.startsWith('5')) {
                      numberError.value = 'Only Visa or MasterCard allowed';
                      isValid = false;
                    }

                    if (name.isEmpty ||
                        !RegExp(r'^[a-zA-Z ]+$').hasMatch(name)) {
                      nameError.value = 'Enter a valid card holder name';
                      isValid = false;
                    }

                    if (selectedMonth.value.isEmpty ||
                        selectedYear.value.isEmpty) {
                      expiryError.value = 'Select expiry month and year';
                      isValid = false;
                    }

                    if (!isValid) return;

                    final newCard = {
                      "number": number,
                      "name": name.toUpperCase(),
                      "expiry": expiry,
                      "isDefault": cards.isEmpty,
                    };

                    cards.add(newCard);
                    if (onCardAdded != null) onCardAdded(newCard);
                    Get.back();
                  },
                  child: const Text('Save Card'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
    isScrollControlled: true,
  );
}
