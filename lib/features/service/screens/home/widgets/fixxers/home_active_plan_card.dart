import 'package:flutter/material.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class HomeActivePlanCard extends StatelessWidget {
  const HomeActivePlanCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: Offset(0, 6),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          //? Card Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  //? Plan Title
                  Text(
                    'Premium Plan',
                    style: TextStyle(
                      fontSize: 12,
                      color: XColors.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 4),
                  //? Plan Price
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '\$500',
                          style: TextStyle(
                            color: XColors.black,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        TextSpan(
                          text: ' /month',
                          style: TextStyle(color: XColors.grey, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              //? Connects
              Column(
                children: [
                  Text(
                    '50',
                    style: TextStyle(
                      color: XColors.black,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Connects',
                    style: TextStyle(color: XColors.grey, fontSize: 10),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 10),
          Divider(
            height: 0.5,
            color: XColors.borderColor.withValues(alpha: 0.5),
          ),
          SizedBox(height: 10),
          //? Card Bottom
          Text(
            'Plan Description',
            style: TextStyle(
              color: XColors.black,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          Text(
            'At vero eos et accusamus et iusto odio dignissimos ducimus qui blanditiis praesentium voluptatum deleniti atque corrupti quos dolores et quas molestias excepturi sint occaecati cupiditate non provident, similique sunt in culpa qui officia deserunt mollitia animi,',
            overflow: TextOverflow.ellipsis,
            maxLines: 3,
            textAlign: TextAlign.justify,
            style: TextStyle(color: XColors.grey, fontSize: 11),
          ),
        ],
      ),
    );
  }
}
