import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:test_socket/features/chat/controller/chat_controller.dart';
import 'package:test_socket/features/home/controller/navigation_controller.dart';
import 'package:test_socket/features/chat/views/home_view.dart';
import 'package:test_socket/features/profile/view/profile_view.dart';

class NavigationBarPage extends ConsumerWidget {
  const NavigationBarPage({super.key});

  final screens = const [HomeView(), ProfileView()];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final screenIndex = ref.watch(navigationIndexProvider);
    final navigationNotifier = ref.read(navigationIndexProvider.notifier);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(chatControllerProvider.notifier).initialize("dsafds");
    });

    return Scaffold(
      body: screens[screenIndex],

      // ✅ Use BottomNavigationBar for horizontal layout at the bottom
      bottomNavigationBar: BottomNavigationBar(
        // Retain your custom properties
        landscapeLayout: BottomNavigationBarLandscapeLayout.linear,
        elevation: 10,
        mouseCursor: WidgetStateMouseCursor.clickable,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
        currentIndex: screenIndex,

        onTap: (value) {
          navigationNotifier.state = value;
        },
      ),
    );
  }
}
