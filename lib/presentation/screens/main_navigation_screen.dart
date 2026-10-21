import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../providers/app_providers.dart';
import '../widgets/floating_fun_fact_guide.dart';
import 'hangul_guide_screen.dart';
import 'home_screen.dart';
import 'practice_hub_screen.dart';
import 'progress_screen.dart';

/// Responsive Main Navigation Shell supporting Mobile, Tablet, and Desktop:
/// - Desktop / Wide Screen (width >= 840): NavigationRail sidebar on the left.
/// - Mobile / Narrow Screen (width < 840): Bento NavigationBar on the bottom.
/// - Preserves all tab states via IndexedStack and hosts FloatingFunFactGuide.
class MainNavigationScreen extends ConsumerStatefulWidget {
  final int initialIndex;

  const MainNavigationScreen({
    super.key,
    this.initialIndex = 0,
  });

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  late int _currentIndex;

  static const List<Widget> _pages = [
    HomeScreen(),
    HangulGuideScreen(),
    PracticeHubScreen(),
    ProgressScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  void _onSelectTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final storage = ref.watch(storageServiceProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 840;

        if (isDesktop) {
          // Desktop & Wide Tablet Layout: Sidebar NavigationRail
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _onSelectTab,
                  labelType: NavigationRailLabelType.all,
                  backgroundColor: theme.cardTheme.color,
                  indicatorColor: AppColors.primaryContainer,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Text(
                      '한글',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.map_outlined),
                      selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
                      label: Text('Journey'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.menu_book_outlined),
                      selectedIcon: Icon(Icons.menu_book_rounded, color: AppColors.primary),
                      label: Text('Guide'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.sports_esports_outlined),
                      selectedIcon: Icon(Icons.sports_esports_rounded, color: AppColors.primary),
                      label: Text('Practice'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.emoji_events_outlined),
                      selectedIcon: Icon(Icons.emoji_events_rounded, color: AppColors.primary),
                      label: Text('Profile'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1),
                Expanded(
                  child: Stack(
                    children: [
                      IndexedStack(
                        index: _currentIndex,
                        children: _pages,
                      ),
                      FloatingFunFactGuide(
                        storageService: storage,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        }

        // Mobile Layout: Bottom NavigationBar
        return Scaffold(
          body: Stack(
            children: [
              IndexedStack(
                index: _currentIndex,
                children: _pages,
              ),
              FloatingFunFactGuide(
                storageService: storage,
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _currentIndex,
            onDestinationSelected: _onSelectTab,
            backgroundColor: theme.cardTheme.color,
            indicatorColor: AppColors.primaryContainer,
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.map_outlined),
                selectedIcon: Icon(Icons.map_rounded, color: AppColors.primary),
                label: 'Journey',
              ),
              NavigationDestination(
                icon: Icon(Icons.menu_book_outlined),
                selectedIcon: Icon(Icons.menu_book_rounded, color: AppColors.primary),
                label: 'Guide',
              ),
              NavigationDestination(
                icon: Icon(Icons.sports_esports_outlined),
                selectedIcon: Icon(Icons.sports_esports_rounded, color: AppColors.primary),
                label: 'Practice',
              ),
              NavigationDestination(
                icon: Icon(Icons.emoji_events_outlined),
                selectedIcon: Icon(Icons.emoji_events_rounded, color: AppColors.primary),
                label: 'Profile',
              ),
            ],
          ),
        );
      },
    );
  }
}
