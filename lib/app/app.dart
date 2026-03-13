import 'package:flutter/material.dart';
import 'package:tripsync/app/router.dart';
import 'package:tripsync/app/theme/app_theme.dart';

class TripSyncApp extends StatelessWidget {
  const TripSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'TripSync',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      routerConfig: appRouter,
    );
  }
}