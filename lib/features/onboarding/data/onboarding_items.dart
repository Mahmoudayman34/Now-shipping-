class OnboardingItem {
  final String imagePath;
  final String title;
  final String description;

  const OnboardingItem({
    required this.imagePath,
    required this.title,
    required this.description,
  });
}

// Note: These will be dynamically loaded from localization
const onboardingItems = [
  OnboardingItem(
    imagePath: 'assets/images/onboarding1.png',
    title: 'effortlessShipping',
    description: 'effortlessShippingDesc',
  ),
  OnboardingItem(
    imagePath: 'assets/images/onboarding2.png',
    title: 'trackDeliveries',
    description: 'trackDeliveriesDesc',
  ),
  OnboardingItem(
    imagePath: 'assets/images/onboarding3.png',
    title: 'securePayments',
    description: 'securePaymentsDesc',
  ),
];
