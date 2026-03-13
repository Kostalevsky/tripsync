import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/features/auth/presentation/login_screen.dart';
import 'package:tripsync/features/budget/presentation/budget_screen.dart';
import 'package:tripsync/features/home/presentation/home_screen.dart';
import 'package:tripsync/features/onboarding/presentation/onboarding_screen.dart';
import 'package:tripsync/features/places/presentation/places_screen.dart';
import 'package:tripsync/features/planner/presentation/planner_screen.dart';
import 'package:tripsync/features/splash/presentation/splash_screen.dart';
import 'package:tripsync/features/trips/presentation/create_trip_screen.dart';
import 'package:tripsync/features/trips/presentation/trip_details_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashScreen();
      },
    ),
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (BuildContext context, GoRouterState state) {
        return const OnboardingScreen();
      },
    ),
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (BuildContext context, GoRouterState state) {
        return const LoginScreen();
      },
    ),
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
    ),
    GoRoute(
      path: '/create-trip',
      name: 'create-trip',
      builder: (BuildContext context, GoRouterState state) {
        return const CreateTripScreen();
      },
    ),
    GoRoute(
      path: '/trip/:tripId',
      name: 'trip-details',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.pathParameters['tripId']!;
        return TripDetailsScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trip/:tripId/places',
      name: 'trip-places',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.pathParameters['tripId']!;
        return PlacesScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trip/:tripId/planner',
      name: 'trip-planner',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.pathParameters['tripId']!;
        return PlannerScreen(tripId: tripId);
      },
    ),
    GoRoute(
      path: '/trip/:tripId/budget',
      name: 'trip-budget',
      builder: (BuildContext context, GoRouterState state) {
        final tripId = state.pathParameters['tripId']!;
        return BudgetScreen(tripId: tripId);
      },
    ),
  ],
);