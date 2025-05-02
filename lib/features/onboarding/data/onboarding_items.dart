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

const onboardingItems = [
  OnboardingItem(
    imagePath: 'assets/images/onboarding1.png',
    title: 'Effortless Shipping,\nAnytime',
    description: 'Create and manage shipments with just a few taps. Simple, fast, and reliable.',
  ),
  OnboardingItem(
    imagePath: 'assets/images/onboarding2.png',
    title: 'Track Deliveries in Real Time',
    description: 'Stay updated with live tracking, order statuses, and delivery progress.',
  ),
  OnboardingItem(
    imagePath: 'assets/images/onboarding3.png',
    title: 'Secure & Seamless Payments',
    description: 'Manage cash transactions with confidence. Collect, track, and confirm every payment.',
  ),
];
