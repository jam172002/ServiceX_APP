import 'package:flutter/material.dart';
import 'package:servicex_client_app/features/service/screens/home/linked_screens/fixxer_job_detail_screen.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class FixxerJobActionBar extends StatelessWidget {
  final FixxerJobStatus status;
  final VoidCallback onPrimaryAction;
  final VoidCallback onSecondaryAction;

  const FixxerJobActionBar({
    super.key,
    required this.status,
    required this.onPrimaryAction,
    required this.onSecondaryAction,
  });

  @override
  Widget build(BuildContext context) {
    final labels = _labelsForStatus(status);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: onSecondaryAction,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(
                labels.secondary,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: onPrimaryAction,
              style: ElevatedButton.styleFrom(
                backgroundColor: XColors.primary,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: Text(labels.primary, style: const TextStyle(fontSize: 13)),
            ),
          ),
        ],
      ),
    );
  }

  _ActionLabels _labelsForStatus(FixxerJobStatus status) {
    switch (status) {
      case FixxerJobStatus.newRequest:
        return _ActionLabels('Send Quote', 'Remove');
      case FixxerJobStatus.quoteSent:
        return _ActionLabels('Edit Quote', 'Cancel Quote');
      case FixxerJobStatus.quoteAccepted:
        return _ActionLabels('Start Job', 'Cancel Booking');
      case FixxerJobStatus.quoteCancelled:
        return _ActionLabels('Resend Quote', 'Remove');
      case FixxerJobStatus.jobStarted:
        return _ActionLabels('Mark Completed', 'Cancel Job');
      case FixxerJobStatus.jobCancelled:
        return _ActionLabels('Resend Quote', 'Remove');
      case FixxerJobStatus.completed:
        return _ActionLabels('Completed', 'Remove');
    }
  }
}

class _ActionLabels {
  final String primary;
  final String secondary;
  _ActionLabels(this.primary, this.secondary);
}
