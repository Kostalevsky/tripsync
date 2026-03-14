import 'package:flutter/material.dart';
import 'package:tripsync/app/theme/app_spacing.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.padding = const EdgeInsets.all(AppSpacing.l),
    this.floatingActionButton,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final EdgeInsetsGeometry padding;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: SafeArea(
        child: Padding(padding: padding, child: child),
      ),
    );
  }
}
