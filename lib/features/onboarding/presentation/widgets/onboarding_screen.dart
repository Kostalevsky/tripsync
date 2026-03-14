import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:tripsync/app/theme/app_colors.dart';
import 'package:tripsync/app/theme/app_radii.dart';
import 'package:tripsync/app/theme/app_spacing.dart';
import 'package:tripsync/app/theme/app_text_styles.dart';
import 'package:tripsync/core/widgets/primary_button.dart';
import 'package:tripsync/features/onboarding/domain/onboarding_page_data.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _pageIndex = 0;

  final List<OnboardingPageData> pages = const [
    OnboardingPageData(
      title: 'Планируйте путешествия вместе',
      subtitle:
          'Создавайте поездки, приглашайте друзей и храните все планы в одном красивом приложении.',
      icon: '🧳',
    ),
    OnboardingPageData(
      title: 'Голосуйте за лучшие места',
      subtitle:
          'Добавляйте кафе, музеи и достопримечательности и решайте вместе, что попадёт в маршрут.',
      icon: '📍',
    ),
    OnboardingPageData(
      title: 'Контролируйте бюджет поездки',
      subtitle:
          'Следите за расходами и сразу смотрите, кто и кому должен по итогам путешествия.',
      icon: '💸',
    ),
  ];

  void _nextPage() {
    if (_pageIndex == pages.length - 1) {
      context.go('/login');
      return;
    }

    _controller.nextPage(
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  void _finishOnboarding() {
    context.go('/login');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLastPage = _pageIndex == pages.length - 1;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.l),
          child: Column(
            children: [
              const SizedBox(height: AppSpacing.m),
              Row(
                children: [
                  Expanded(
                    child: _PageIndicator(
                      count: pages.length,
                      index: _pageIndex,
                    ),
                  ),
                  if (!isLastPage)
                    TextButton(
                      onPressed: _finishOnboarding,
                      child: const Text('Пропустить'),
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.l),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  itemCount: pages.length,
                  onPageChanged: (index) {
                    setState(() {
                      _pageIndex = index;
                    });
                  },
                  itemBuilder: (context, index) {
                    final page = pages[index];

                    return Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          page.icon,
                          style: const TextStyle(fontSize: 96),
                        ).animate().fadeIn(duration: 400.ms),
                        const SizedBox(height: AppSpacing.xl),
                        Text(
                          page.title,
                          style: AppTextStyles.displayMedium,
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 100.ms),
                        const SizedBox(height: AppSpacing.m),
                        Text(
                          page.subtitle,
                          style: AppTextStyles.bodyMedium,
                          textAlign: TextAlign.center,
                        ).animate().fadeIn(delay: 200.ms),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.l),
              PrimaryButton(
                label: isLastPage ? 'Начать планирование' : 'Далее',
                onPressed: _nextPage,
              ),
              const SizedBox(height: AppSpacing.xl),
            ],
          ),
        ),
      ),
    );
  }
}

class _PageIndicator extends StatelessWidget {
  const _PageIndicator({required this.count, required this.index});

  final int count;
  final int index;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(
        count,
        (i) => AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: const EdgeInsets.only(right: 6),
          height: 6,
          width: i == index ? 24 : 6,
          decoration: BoxDecoration(
            color: i == index ? AppColors.primary : AppColors.border,
            borderRadius: BorderRadius.circular(AppRadii.round),
          ),
        ),
      ),
    );
  }
}
