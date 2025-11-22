import '../../../core/constants/app_images.dart';
import 'onboarding_model.dart';

class OnboardingData {
  static List<OnboardingModel> items = [
    OnboardingModel(
      imageUrl: AppImages.onboarding1,
      headline: 'Explore Every Product You Need',
      description:
      'Find groceries, essentials, and local items from nearby retailers and wholesalers — all in one place.',
    ),
    OnboardingModel(
      imageUrl: AppImages.onboarding2,
      headline: 'Smart Deals & Personalized Offers',
      description:
      'Get the best prices, exclusive discounts, and recommendations based on your shopping habits.',
    ),
    OnboardingModel(
      imageUrl: AppImages.onboarding3,
      headline: 'Fast & Reliable Delivery',
      description:
      'Place your order and get quick doorstep delivery with live updates and real-time tracking.',
    ),
  ];
}
