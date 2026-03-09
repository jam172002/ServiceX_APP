import 'package:flutter/material.dart';
import 'package:servicex_client_app/presentation/widgets/simple_heading.dart';
import 'package:servicex_client_app/presentation/widgets/service_providers_hor_view.dart';

class SingleSubCategory extends StatelessWidget {
  final String title;
  final String actionText;
  final VoidCallback onActionTap;
  final List<Map<String, dynamic>> providers;
  final bool isLoading;

  const SingleSubCategory({
    super.key,
    required this.title,
    required this.actionText,
    required this.onActionTap,
    required this.providers,
    this.isLoading = false,
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

        isLoading
            ? const _ProviderListShimmer()
            : providers.isEmpty
            ? Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'No providers available for $title.',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
        )
            : ServiceProviderHorizontalList(providers: providers),
      ],
    );
  }
}

// ── Simple shimmer placeholder while fixxers load ─────────────────
class _ProviderListShimmer extends StatelessWidget {
  const _ProviderListShimmer();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 4,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, __) => Container(
          width: 90,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}