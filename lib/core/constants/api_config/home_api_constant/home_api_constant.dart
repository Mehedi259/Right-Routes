class HomeApiConstant {
  static const String baseUrl = "http://54.236.158.228:8003/api/v1";

  // ---------------------  above is baseurl ------------------

  static const String createRoute = "/navigation/create-route/";
  static const String routePost = "/route/";
  static const String updateRouteName = "/route/";
  static const String permitStartingPoint = "/permit-starting-point/";
  static const String routePermit = "/permit/";

  // Team Manager API Endpoints
  static const String teamMembers = "/team/members/";
  static const String teamMemberDetails = "/team/member/"; // Append {id}/
  static const String teamMultipleMembersAdd = "/team/multiple-members-add/";
  static const String removeTeamMember = "/team/remove-member/";
  // Subscription API Endpoints
  static const String currentPlan = "/subscription/current-plan/";
  static const String purchasePlan = "/subscription/purchase/";
  static const String purchaseVerify = "/subscription/purchase-verify/";
  static const String subscriptionPlans = '/subscription-plans/';
}
