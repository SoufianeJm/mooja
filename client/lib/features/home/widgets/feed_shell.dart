import 'package:flutter/material.dart';
import '../../../core/themes/theme_exports.dart';
import 'tab_navigation.dart';
import 'floating_action_bar.dart';

/// Shell wrapper that provides persistent tab navigation and floating action bar
/// for both protestor and organization feed screens
class FeedShell extends StatefulWidget {
  final Widget child;
  final TabType activeTab;
  final Function(TabType) onTabChanged;

  const FeedShell({
    super.key,
    required this.child,
    required this.activeTab,
    required this.onTabChanged,
  });

  @override
  State<FeedShell> createState() => _FeedShellState();
}

class _FeedShellState extends State<FeedShell> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ThemeColors.backgroundPrimary(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: 16.ph + 20.pt,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TabNavigation(
                      activeTab: widget.activeTab,
                      onTabChanged: widget.onTabChanged,
                    ),
                    24.v,
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionBar(
        onContributeTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Contribute tapped - Navigate to create protest'),
            ),
          );
          // TODO: Navigate to contribution board
        },
        onAddTap: () {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Add tapped - Quick action')),
          );
          // TODO: Show menu
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
