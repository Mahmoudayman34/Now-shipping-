class DashboardStats {
  final int inHubPackages;
  final int toDeliverToday;
  final int headingToCustomer;
  final int awaitingAction;
  final int successfulOrders;
  final double successRate;
  final int unsuccessfulOrders;
  final double unsuccessRate;
  final int headingToYou;
  final int newOrders;
  final double expectedCash;
  final double collectedCash;
  final double collectionRate;
  final bool isEmailVerified;
  final bool isProfileComplete;

  DashboardStats({
    this.inHubPackages = 0,
    this.toDeliverToday = 0,
    this.headingToCustomer = 0,
    this.awaitingAction = 0,
    this.successfulOrders = 0,
    this.successRate = 0,
    this.unsuccessfulOrders = 0,
    this.unsuccessRate = 0,
    this.headingToYou = 0,
    this.newOrders = 0,
    this.expectedCash = 0.0,
    this.collectedCash = 0.0,
    this.collectionRate = 0,
    this.isEmailVerified = false,
    this.isProfileComplete = false,
  });
  
  factory DashboardStats.fromJson(Map<String, dynamic> json) {
    final orderStats = json['dashboardData']?['orderStats'] ?? {};
    final financialStats = json['dashboardData']?['financialStats'] ?? {};
    final userData = json['userDate'] ?? {};
    
    return DashboardStats(
      // Order stats
      inHubPackages: orderStats['totalOrders'] ?? 0,
      headingToCustomer: orderStats['headingToCustomerCount'] ?? 0,
      awaitingAction: orderStats['awaitingActionCount'] ?? 0,
      successfulOrders: orderStats['completedCount'] ?? 0,
      successRate: (orderStats['completionRate'] ?? 0).toDouble(),
      unsuccessfulOrders: orderStats['unsuccessfulCount'] ?? 0,
      unsuccessRate: (orderStats['unsuccessfulRate'] ?? 0).toDouble(),
      headingToYou: orderStats['headingToYouCount'] ?? 0,
      newOrders: orderStats['newOrdersCount'] ?? 0,
      
      // Financial stats
      expectedCash: (financialStats['expectedCash'] ?? 0).toDouble(),
      collectedCash: (financialStats['collectedCash'] ?? 0).toDouble(),
      collectionRate: (financialStats['collectionRate'] ?? 0).toDouble(),
      
      // User data
      isEmailVerified: userData['isVerified'] ?? false,
      isProfileComplete: userData['isCompleted'] ?? false,
    );
  }
}

enum DetailedBreakdownTab {
  awaitingAction,
  headingToCustomer,
  pickup
}