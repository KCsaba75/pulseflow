import 'dart:io';

import 'package:purchases_flutter/purchases_flutter.dart';

import '../config/app_config.dart';

class SubscriptionService {
  Future<void> init({String? appUserId}) async {
    final apiKey = Platform.isIOS
        ? AppConfig.revenueCatIosApiKey
        : AppConfig.revenueCatAndroidApiKey;

    await Purchases.configure(
      PurchasesConfiguration(apiKey)..appUserID = appUserId,
    );
  }

  Future<bool> isPremium() async {
    final info = await Purchases.getCustomerInfo();
    return info.entitlements.active.containsKey(AppConfig.premiumEntitlementId);
  }

  Future<Offerings> getOfferings() => Purchases.getOfferings();

  Future<bool> purchasePackage(Package package) async {
    final result = await Purchases.purchasePackage(package);
    return result.customerInfo.entitlements.active
        .containsKey(AppConfig.premiumEntitlementId);
  }

  Future<bool> restorePurchases() async {
    final info = await Purchases.restorePurchases();
    return info.entitlements.active.containsKey(AppConfig.premiumEntitlementId);
  }
}
