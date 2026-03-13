import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/primary_button.dart';
import 'package:tripsync/features/onboarding/presentation/widgets/onboarding_page_data.dart';
import 'package:tripsync/shared/state/app_bootstrap_providers.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();

  final List<OnboardingPageData> _pages = const [
    OnboardingPageData(
      title: 'Планируйте путешествия вместе',
      subtitle:
          'Создавайте поездки, приглашайте друзей и храните все планы в одном красивом приложении.',
      icon: '🧳',
    ),
    OnboardingPageData(
      title: 'Голосуйте за лучшие места',
      subtitle:
          'Добавляйте кафе, музеи и достопримечательности и решайте вместе, что попадет в маршрут.',
      icon: '📍',
    ),
    OnboardingPageData(
      title: 'Делите бюджет без путаницы',
      subtitle:
          'Отслеживайте расходы и сразу смотрите, кто и кому должен по итогам поездки.',
      icon: '💸',
    ),
  ];

  int _currentPage = 0;

  void _completeOnboarding() {
    ref.read(onboardingCompletedProvider.notifier).state = true;
    context.go('/login');
  }

  void _handleNext() {
    if (_currentPage == _pages.length - 1) {
      _completeOnboarding();
      return;
    }

    _pageController.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.l),
          child: Column(
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _completeOnboarding,
                  child: const Text('Пропустить'),
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: _pages.length,
                  onPageChanged: (value) {
                    setState(() {
                      _currentPage = value;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = _pages[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 220,
                          height: 220,
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(AppRadii.l),
                            boxShadow: const [
                              BoxShadow(
                                color: AppColors.shadow,
                                blurRadius: 30,
                                offset: Offset(0, 12),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              page.icon,
                              style: const TextStyle(fontSize: 86),
                            ),
                          ),
                        )
                            .animate(key: ValueKey(index))
                            .fadeIn(duration: 350.ms)
                            .scale(begin: const Offset(0.92, 0.92)),

                        const SizedBox(height: AppSpacing.xl),

                        Text(
                          page.title,
                          style: AppTextStyles.headlineLarge,
                          textAlign: TextAlign.center,
                        )
                            .animate(key: ValueKey('title_$index'))
                            .fadeIn(duration: 300.ms)
                            .slideY(begin: 0.15),

                        const SizedBox(height: AppSpacing.m),

                        Text(
                          page.subtitle,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        )
                            .animate(key: ValueKey('subtitle_$index'))
                            .fadeIn(delay: 100.ms),
                      ],
                    );
                  },
                ),
              ),
              SmoothPageIndicator(
                controller: _pageController,
                count: _pages.length,
                effect: const ExpandingDotsEffect(
                  dotHeight: 8,
                  dotWidth: 8,
                  expansionFactor: 3.2,
                  spacing: 8,
                  activeDotColor: AppColors.primary,
                  dotColor: AppColors.border,
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              PrimaryButton(
                label: _currentPage == _pages.length - 1 ? 'Начать' : 'Далее',
                onPressed: _handleNext,
              ),
            ],
          ),
        ),
      ),
    );
  }
}