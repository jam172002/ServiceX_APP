import 'package:flutter/material.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/features/service/screens/profile/widgets/transaction_details_dialog.dart';
import 'package:servicex_client_app/features/service/screens/profile/widgets/transaction_tile.dart';
import 'package:servicex_client_app/features/service/screens/profile/widgets/wallet_card.dart';
import 'package:servicex_client_app/utils/constants/enums.dart';

class WalletScreen extends StatelessWidget {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Wallet'),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          children: [
            /// Wallet Balance Card
            WalletCard(),
            const SizedBox(height: 16),

            /// Transactions List
            ListView.separated(
              itemCount: 12,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) {
                final isCredit = index % 2 == 0;

                return TransactionTile(
                  dateTime: '24 December, 2025 · 01:00 AM',
                  cardNumber: '5555 4444 3333 4093',
                  amount: isCredit ? 350 : 120,
                  type: isCredit
                      ? TransactionType.credit
                      : TransactionType.debit,
                  onTap: () {
                    showTransactionDetailsDialog(
                      context,
                      caseType: isCredit
                          ? TransactionCase.received
                          : TransactionCase.sent,
                      titleName: isCredit ? 'AC Repair Service' : 'Ali Haider',
                      dateTime: '24 December, 2025 · 01:00 AM',
                      location: index == 2
                          ? 'Gulberg, Lahore'
                          : 'DHA Phase 6, Lahore',
                      avatarAsset: isCredit
                          ? 'assets/icons/ac.png'
                          : 'assets/images/service-provider.jpg',
                      isCancelled: index == 3,
                    );
                  },
                );
              },
            ),
            SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
