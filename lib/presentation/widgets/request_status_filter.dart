import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class RequestStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusSelected;

  const RequestStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
  });

  final List<String> statuses = const [
    'All',
    'New',
    'Under Review',
    'Accepted',
    'InProgress',
    'Completed',
    'Cancelled',
  ];

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'new':
        return Colors.blue;
      case 'under review':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'inprogress':
        return Colors.purple;
      case 'completed':
        return Colors.teal;
      case 'cancelled':
        return Colors.red;
      case 'all':
        return XColors.primary;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 29,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: statuses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = statuses[index];
          final isSelected = status == selectedStatus;

          return GestureDetector(
            onTap: () => onStatusSelected(status),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? getStatusColor(status).withValues(alpha: 0.2)
                    : XColors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? getStatusColor(status) : XColors.grey,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
