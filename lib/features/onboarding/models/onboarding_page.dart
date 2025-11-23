class OnboardingPageData {
  final String title;
  final String description;
  final String imagePath;
  final bool isLastPage;

  const OnboardingPageData({
    required this.title,
    required this.description,
    required this.imagePath,
    this.isLastPage = false,
  });
}

final List<OnboardingPageData> onboardingPages = [
  const OnboardingPageData(
    title: 'Deliver Smarter, Faster',
    description: 'Boost your performance and deliver with confidence every time.',
    imagePath: 'assets/images/board_1.png',
  ),
  const OnboardingPageData(
    title: 'Track Every Shipment in Real Time',
    description: 'Stay updated with real-time tracking of all your deliveries.',
    imagePath: 'assets/images/board_2.png',
  ),
  const OnboardingPageData(
    title: 'Simplify Your Workday',
    description: 'Manage all your tasks efficiently in one place.',
    imagePath: 'assets/images/board_3.png',
    isLastPage: true,
  ),
];

