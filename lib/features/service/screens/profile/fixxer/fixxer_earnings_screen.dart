import 'package:flutter/material.dart';
import 'package:flutter_lucide/flutter_lucide.dart';
import 'package:iconsax/iconsax.dart';
import 'package:servicex_client_app/common/widgets/appbar/common_appbar.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerEarningsScreen extends StatefulWidget {
  const FixxerEarningsScreen({super.key});

  @override
  State<FixxerEarningsScreen> createState() => _FixxerEarningsScreenState();
}

class _FixxerEarningsScreenState extends State<FixxerEarningsScreen> {
  String _selectedFilter = 'All';

  List<Map<String, dynamic>> get _filteredEarnings {
    if (_selectedFilter == 'All') return _earningsDetails;
    return _earningsDetails
        .where((e) => e['status'] == _selectedFilter)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: XAppBar(title: 'Earnings'),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🔹 Earnings Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _earningsData.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
              ),
              itemBuilder: (context, index) {
                final item = _earningsData[index];
                return EarningsCard(
                  title: item['title'],
                  amount: item['amount'],
                  gradient: item['gradient'],
                  onTap: () {},
                );
              },
            ),

            const SizedBox(height: 16),

            /// 🔹 Filter (added, minimal, non-intrusive)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Earnings Details',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                DropdownButton<String>(
                  dropdownColor: XColors.secondaryBG,
                  icon: Icon(
                    LucideIcons.chevron_down,
                    color: XColors.black,
                    size: 18,
                  ),
                  style: TextStyle(fontSize: 12, color: XColors.black),

                  value: _selectedFilter,
                  underline: const SizedBox(),
                  items: const [
                    DropdownMenuItem(value: 'All', child: Text('All')),
                    DropdownMenuItem(value: 'Pending', child: Text('Pending')),
                    DropdownMenuItem(
                      value: 'Completed',
                      child: Text('Completed'),
                    ),
                    DropdownMenuItem(
                      value: 'Cancelled',
                      child: Text('Cancelled'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => _selectedFilter = value!);
                  },
                ),
              ],
            ),

            const SizedBox(height: 8),

            /// 🔹 Earnings Details List
            ..._filteredEarnings.map((item) => EarningsDetailCard(item: item)),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// ♻️ Reusable Earnings Card
/// =======================
class EarningsCard extends StatelessWidget {
  final String title;
  final String amount;
  final List<Color> gradient;
  final VoidCallback onTap;

  const EarningsCard({
    super.key,
    required this.title,
    required this.amount,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(14),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradient,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
            Text(
              amount,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// =======================
/// 📄 Earnings Detail Card
/// =======================
class EarningsDetailCard extends StatelessWidget {
  final Map<String, dynamic> item;

  const EarningsDetailCard({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: XColors.secondaryBG,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: XColors.borderColor.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: XColors.lighterTint,
                backgroundImage: const AssetImage(
                  'assets/images/service-provider.jpg',
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    item['date'],
                    style: TextStyle(fontSize: 11, color: XColors.grey),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                item['amount'],
                style: TextStyle(
                  color: item['status'] == 'Completed'
                      ? Colors.green
                      : item['status'] == 'Pending'
                      ? Colors.amber
                      : Colors.red,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                item['service'],
                style: TextStyle(fontSize: 12, color: XColors.black),
              ),
              const SizedBox(width: 12),
              Container(height: 12, width: 1, color: XColors.primary),
              const SizedBox(width: 12),
              Text(
                item['type'],
                style: TextStyle(fontSize: 12, color: XColors.black),
              ),
              const SizedBox(width: 12),
              Container(height: 12, width: 1, color: XColors.primary),
              const SizedBox(width: 12),
              Text(
                item['status'],
                style: TextStyle(fontSize: 12, color: XColors.black),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              Icon(Iconsax.location, color: XColors.primary, size: 12),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  item['location'],
                  style: TextStyle(fontSize: 12, color: XColors.black),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// =======================
/// 📊 Earnings Grid Data
/// =======================
final List<Map<String, dynamic>> _earningsData = [
  {
    'title': 'Payments Available for Withdraw',
    'amount': '\$400',
    'gradient': [
      const Color(0xFF00ff87).withValues(alpha: 0.35),
      const Color(0xFF60efff).withValues(alpha: 0.35),
    ],
  },
  {
    'title': 'Payment Being Cleared',
    'amount': '\$290.45',
    'gradient': [
      const Color(0xFFff930f).withValues(alpha: 0.35),
      const Color(0xFFfff95b).withValues(alpha: 0.35),
    ],
  },
  {
    'title': 'Payment of Pending Services',
    'amount': '\$130.98',
    'gradient': [
      const Color(0xFF0061ff).withValues(alpha: 0.35),
      const Color(0xFF60efff).withValues(alpha: 0.35),
    ],
  },
  {
    'title': 'Payments of Cancelled Jobs',
    'amount': '\$20.67',
    'gradient': [
      const Color(0xFFf83d5c).withValues(alpha: 0.35),
      const Color(0xFFfd4b2f).withValues(alpha: 0.35),
    ],
  },
];

/// =======================
/// 📄 Earnings Details Data
/// =======================
final List<Map<String, dynamic>> _earningsDetails = [
  {
    'name': 'Muhammad Sufyan',
    'date': '25 Jan 2025',
    'amount': '\$23.23',
    'service': 'Pipe Leakage Fix',
    'type': 'Direct Job',
    'status': 'Pending',
    'location': 'Block III, Street 11 Model Town Bahawalpur',
  },
  {
    'name': 'Ali Raza',
    'date': '22 Jan 2025',
    'amount': '\$52.00',
    'service': 'AC Repair',
    'type': 'Booking',
    'status': 'Completed',
    'location': 'Satellite Town, Bahawalpur',
  },
  {
    'name': 'Ahmed Khan',
    'date': '20 Jan 2025',
    'amount': '\$15.00',
    'service': 'Wiring Issue',
    'type': 'Direct Job',
    'status': 'Cancelled',
    'location': 'Model Town A',
  },
];
