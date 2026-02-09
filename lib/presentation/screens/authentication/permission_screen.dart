import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class PermissionScreen extends StatelessWidget {
  final String title;
  final String subtitle;
  final String allowButtonText;
  final VoidCallback onAllow;
  final String denyButtonText;
  final VoidCallback? onDeny;
  final Widget? illustration;
  final bool showDenyButton;

  const PermissionScreen({
    super.key,
    required this.title,
    required this.subtitle,
    required this.allowButtonText,
    required this.onAllow,
    this.denyButtonText = 'No, May be other time',
    this.onDeny,
    this.illustration,
    this.showDenyButton = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Top illustration with stacked circles
            Expanded(
              flex: 4,
              child: SizedBox(
                width: double.infinity,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Big background circle
                    Container(
                      width: screenWidth * 0.8,
                      height: screenWidth * 0.8,
                      decoration: BoxDecoration(
                        color: XColors.primaryBG,
                        border: Border.all(
                          color: XColors.borderColor.withValues(alpha: 0.2),
                          width: 3,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Smaller circle on top
                    Container(
                      width: screenWidth * 0.55,
                      height: screenWidth * 0.55,
                      decoration: BoxDecoration(
                        color: XColors.primaryBG,
                        border: Border.all(
                          color: XColors.borderColor.withValues(alpha: 0.2),
                          width: 3,
                        ),
                        shape: BoxShape.circle,
                      ),
                    ),
                    // Illustration or default placeholder
                    if (illustration != null)
                      illustration!
                    else
                      Container(
                        width: screenWidth * 0.3,
                        height: screenWidth * 0.3,
                        decoration: BoxDecoration(
                          color: XColors.primaryBG,
                          border: Border.all(
                            color: XColors.borderColor.withValues(alpha: 0.2),
                            width: 3,
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Bottom content
            Expanded(
              flex: 3,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Title
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: screenHeight * 0.025,
                        fontWeight: FontWeight.bold,
                        color: XColors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.008),

                    // Subtitle
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: screenHeight * 0.015,
                        color: XColors.grey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Allow button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: onAllow,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: XColors.primary,
                          padding: EdgeInsets.symmetric(
                            vertical: screenHeight * 0.018,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          allowButtonText,
                          style: TextStyle(
                            fontSize: screenHeight * 0.018,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    // Optional deny button
                    if (showDenyButton && onDeny != null)
                      TextButton(
                        onPressed: onDeny,
                        style:
                            TextButton.styleFrom(
                              padding: EdgeInsets.zero,
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                              foregroundColor: XColors.grey,
                            ).copyWith(
                              overlayColor: WidgetStateProperty.all(
                                Colors.transparent,
                              ),
                            ),
                        child: Text(
                          denyButtonText,
                          style: TextStyle(
                            color: XColors.grey,
                            fontSize: screenHeight * 0.016,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
