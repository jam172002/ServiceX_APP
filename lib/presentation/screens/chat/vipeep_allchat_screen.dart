import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:servicex_client_app/presentation/widgets/search_filter_container.dart';
import 'package:servicex_client_app/presentation/screens/chat/single_chat_screen.dart';
import 'package:servicex_client_app/presentation/widgets/allchat_screen_card.dart';
import 'package:servicex_client_app/utils/constants/colors.dart';

class VipeepAllChatScreen extends StatelessWidget {
  const VipeepAllChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'All Chats',
          style: TextStyle(
            color: XColors.black,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          children: [
            SearchWithFilter(horPadding: 0, hintText: 'Search...'),
            const SizedBox(height: 16),

            // Expanded ListView
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(
                  bottom: kBottomNavigationBarHeight + 20,
                ),
                children: [
                  ...List.generate(
                    12,
                    (index) => AllChatScreenCard(
                      name: "Muhammad Sufyan",
                      lastMessage:
                          "But I must explain to you how all this mistaken idea of denouncing pleasure...",
                      date: "Today",
                      time: "11:00 PM",
                      unreadCount: index.isEven ? 5 : 0,
                      onTap: () => Get.to(
                        () => const SingleChatScreen(isServiceProvider: true),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
