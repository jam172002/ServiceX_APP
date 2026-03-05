import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class RequestStatusFilter extends StatelessWidget {
  final String selectedStatus;
  final Function(String) onStatusSelected;

  /// Optional override — if not supplied the default list below is used.
  /// Pass [JobRequestsController.filterLabels] to keep them in sync.
  final List<String>? statuses;

  const RequestStatusFilter({
    super.key,
    required this.selectedStatus,
    required this.onStatusSelected,
    this.statuses,
  });

  // Default labels — kept in sync with JobRequestsController.filterLabels
  // and jobStatusToString() / statusLabel() helpers.
  static const List<String> _defaultStatuses = [
    'All',
    'Pending',
    'Under Review',
    'Accepted',
    'In Progress',
    'Ongoing',
    'Completed',
    'Cancelled',
  ];

  Color _statusColor(String s) {
    switch (s.toLowerCase()) {
      case 'all':          return XColors.primary;
      case 'new':
      case 'newrequest':   return Colors.blue;
      case 'pending':      return Colors.blueGrey;
      case 'under review': return Colors.orange;
      case 'accepted':     return Colors.green;
      case 'in progress':
      case 'ongoing':      return Colors.purple;
      case 'completed':    return Colors.teal;
      case 'cancelled':    return Colors.red;
      default:             return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = statuses ?? _defaultStatuses;

    return SizedBox(
      height: 29,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: items.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final status = items[index];
          final isSelected = status == selectedStatus;
          final color = _statusColor(status);

          return GestureDetector(
            onTap: () => onStatusSelected(status),
            child: Container(
              padding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: isSelected
                    ? color.withValues(alpha: 0.2)
                    : XColors.grey.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Center(
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? color : XColors.grey,
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