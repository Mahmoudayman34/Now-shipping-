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
  });
}

enum DetailedBreakdownTab {
  awaitingAction,
  headingToCustomer,
  pickup
}