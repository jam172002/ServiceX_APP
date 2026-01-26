import 'package:flutter/material.dart';
import 'package:servicex_client_app/common/widgets/headings/simple_heading.dart';
import 'package:servicex_client_app/features/service/screens/home/widgets/vipeeps/service_providers_hor_view.dart';

class SingleSubCategory extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;
  final List<Map<String, dynamic>> providers;

  const SingleSubCategory({
    super.key,
    required this.title,
    required this.actionText,
    required this.onActionTap,
    required this.providers,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        XHeading(
          title: title,
          actionText: actionText,
          onActionTap: onActionTap,
          showActionButton: true,
          sidePadding: 16,
        ),

        const SizedBox(height: 15),

        ServiceProviderHorizontalList(providers: providers),
      ],
    );
  }
}
