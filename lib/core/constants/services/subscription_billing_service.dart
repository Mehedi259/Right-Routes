import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';
import 'package:right_routes/core/constants/api_config/home_api_constant/home_api_constant.dart';
import 'package:right_routes/core/constants/services/api_client.dart';
import 'package:right_routes/core/constants/services/auth_service.dart';
import 'package:right_routes/core/routes/all_routes.dart';
import 'package:right_routes/global_widgets/custom_navbar.dart';
import 'package:right_routes/views/subscription_plans/subscription_model/subscription_model.dart';

/// Handles real Google Play / App Store billing, backend verification,
/// plan upgrades/downgrades, and Restore Subscription flows.
class SubscriptionBillingService {
  SubscriptionBillingService._();

  static final SubscriptionBillingService instance = SubscriptionBillingService._();

  static const String androidPackageName = 'com.rightroutes.running';

  static const String productIndividualAnnual = 'rr_individual_annual';
  static const String productIndividualMonthly = 'rr_individual_monthly';
  static const String productTeam5Monthly = 'rr_team_5_monthly';
  static const String productTeam10Monthly = 'rr_team_10_monthly';
  static const String productTeam25Monthly = 'rr_team_25_monthly';
  static const String productTeam50Monthly = 'rr_team_50_monthly';
  static const String productTeam100Monthly = 'rr_team_100_monthly';

  static const List<String> allKnownProductIds = [
    productIndividualAnnual,
    productIndividualMonthly,
    productTeam5Monthly,
    productTeam10Monthly,
    productTeam25Monthly,
    productTeam50Monthly,
    productTeam100Monthly,
  ];

  final InAppPurchase _iap = InAppPurchase.instance;
  final Map<String, ProductDetails> _storeProducts = {};
  final Map<String, String> _localizedPrices = {};
  final Map<String, String> _pendingPlanUuids = {};
  final Map<String, bool> _pendingIsTeam = {};
  final Map<String, Completer<bool>> _purchaseCompleters = {};

  StreamSubscription<List<PurchaseDetails>>? _purchaseSub;
  Completer<List<PurchaseDetails>>? _restoreCompleter;
  final List<PurchaseDetails> _restoredBuffer = [];
  bool _initialized = false;

  void ensureInitialized() {
    if (_initialized) return;
    _initialized = true;
    _purchaseSub = _iap.purchaseStream.listen(
      _onPurchaseUpdated,
      onDone: () => _purchaseSub?.cancel(),
      onError: (Object error) {
        debugPrint('IAP stream error: $error');
      },
    );
  }

  /// Returns a formatted price (without currency suffix duplication, e.g. "$14.99")
  /// from Google Play if loaded, falling back to the backend/default price string.
  String? storePriceFor(String productId) => _localizedPrices[productId];

  Future<Map<String, ProductDetails>> loadStoreProducts(
    Iterable<String> productIds,
  ) async {
    ensureInitialized();
    final ids = productIds.where((id) => id.trim().isNotEmpty).toSet();
    if (ids.isEmpty) return _storeProducts;

    try {
      final available = await _iap.isAvailable();
      if (!available) return _storeProducts;

      final response = await _iap.queryProductDetails(ids);
      if (response.error != null) {
        debugPrint('Play Store queryProductDetails error: ${response.error!.message}');
      }

      // Google Play Billing returns one GooglePlayProductDetails entry per offer
      // (base plan + trial/intro offers). Prefer trial offer for checkout while
      // reading the recurring paid price for display.
      final Map<String, List<ProductDetails>> grouped = {};
      for (final details in response.productDetails) {
        grouped.putIfAbsent(details.id, () => []).add(details);
      }

      for (final entry in grouped.entries) {
        final chosen = _pickPreferredOffer(entry.value);
        _storeProducts[entry.key] = chosen;
        final paidPrice = _extractRecurringDisplayPrice(chosen);
        if (paidPrice != null && paidPrice.isNotEmpty) {
          _localizedPrices[entry.key] = paidPrice;
        }
      }
    } catch (e) {
      debugPrint('Failed loading Play Store products: $e');
    }

    return _storeProducts;
  }

  ProductDetails _pickPreferredOffer(List<ProductDetails> offers) {
    for (final item in offers) {
      if (item is GooglePlayProductDetails) {
        final idx = item.subscriptionIndex;
        final subs = item.productDetails.subscriptionOfferDetails;
        if (idx != null && subs != null && idx < subs.length) {
          final offer = subs[idx];
          final hasFreePhase = offer.pricingPhases.any((p) => p.priceAmountMicros == 0);
          final hasTrialTag = offer.offerTags.any((t) => t.toLowerCase().contains('trial')) ||
              (offer.offerId?.toLowerCase().contains('trial') ?? false);
          if (hasFreePhase || hasTrialTag) {
            return item;
          }
        }
      }
    }
    return offers.first;
  }

  String? _extractRecurringDisplayPrice(ProductDetails details) {
    if (details is GooglePlayProductDetails) {
      final idx = details.subscriptionIndex;
      final subs = details.productDetails.subscriptionOfferDetails;
      if (idx != null && subs != null && idx < subs.length) {
        final phases = subs[idx].pricingPhases;
        if (phases.isNotEmpty) {
          final paidPhase = phases.lastWhere(
            (p) => p.priceAmountMicros > 0,
            orElse: () => phases.last,
          );
          if (paidPhase.formattedPrice.isNotEmpty) {
            return paidPhase.formattedPrice;
          }
        }
      }
    }
    return details.price.isNotEmpty ? details.price : null;
  }

  Future<bool> purchasePlan(
    SubscriptionPlanModel plan, {
    required bool isTeamFlow,
  }) async {
    ensureInitialized();

    if (plan.id <= 0) {
      _showError('This plan is currently unavailable from the server.');
      return false;
    }

    final productId = plan.productId.trim();
    if (productId.isEmpty) {
      _showError('Play Store product ID is missing for this plan.');
      return false;
    }

    final available = await _iap.isAvailable();
    if (!available) {
      _showError('Google Play Billing is not available on this device.');
      return false;
    }

    // Ensure store ProductDetails are loaded cleanly before creating backend pending record
    if (!_storeProducts.containsKey(productId)) {
      await loadStoreProducts([productId]);
    }
    final productDetails = _storeProducts[productId];
    if (productDetails == null) {
      _showError(
        'Subscription "$productId" is not yet configured or published in Google Play Console.',
      );
      return false;
    }

    // 1. Create pending backend subscription record
    final purchaseUrl = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.purchasePlan);
    final purchaseResponse = await ApiClient.post(
      purchaseUrl,
      body: {'plan_id': plan.id},
    );

    final pData = _decodeResponse(purchaseResponse.data);
    if ((purchaseResponse.statusCode != 200 && purchaseResponse.statusCode != 201) ||
        pData?['success'] != true ||
        pData?['data']?['uuid'] == null) {
      _showError(_extractErrorMessage(pData, 'Failed to initiate subscription checkout.'));
      return false;
    }

    final String pendingUuid = pData!['data']['uuid'].toString();
    _pendingPlanUuids[productId] = pendingUuid;
    _pendingIsTeam[productId] = isTeamFlow;

    // 2. Prepare upgrade/downgrade ChangeSubscriptionParam if user already owns an active Android sub
    ChangeSubscriptionParam? changeParam;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      changeParam = await _buildChangeSubscriptionParam(newProductId: productId);
    }

    final PurchaseParam purchaseParam;
    if (productDetails is GooglePlayProductDetails) {
      purchaseParam = GooglePlayPurchaseParam(
        productDetails: productDetails,
        applicationUserName: pendingUuid,
        offerToken: productDetails.offerToken,
        changeSubscriptionParam: changeParam,
      );
    } else {
      purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: pendingUuid,
      );
    }

    final completer = Completer<bool>();
    _purchaseCompleters[productId]?.complete(false);
    _purchaseCompleters[productId] = completer;

    final launched = await _iap.buyNonConsumable(purchaseParam: purchaseParam);
    if (!launched) {
      _purchaseCompleters.remove(productId);
      _showError('Unable to launch store checkout sheet.');
      return false;
    }

    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () {
        _purchaseCompleters.remove(productId);
        return false;
      },
    );
  }

  Future<ChangeSubscriptionParam?> _buildChangeSubscriptionParam({
    required String newProductId,
  }) async {
    try {
      final addition = _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
      final past = await addition.queryPastPurchases();
      for (final oldPurchase in past.pastPurchases) {
        if (oldPurchase.productID != newProductId &&
            oldPurchase.billingClientPurchase.purchaseState == PurchaseStateWrapper.purchased) {
          return ChangeSubscriptionParam(
            oldPurchaseDetails: oldPurchase,
            replacementMode: ReplacementMode.withTimeProration,
          );
        }
      }
    } catch (e) {
      debugPrint('Unable to inspect past Play purchases for upgrade: $e');
    }
    return null;
  }

  Future<bool> restoreSubscriptions() async {
    ensureInitialized();

    final String platformStr = GetPlatform.isIOS ? 'ios' : 'android';
    final List<Map<String, dynamic>> restorePayload = [];
    final List<PurchaseDetails> toComplete = [];

    try {
      final available = await _iap.isAvailable();
      if (available) {
        if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
          final addition = _iap.getPlatformAddition<InAppPurchaseAndroidPlatformAddition>();
          final past = await addition.queryPastPurchases();
          for (final p in past.pastPurchases) {
            if (p.billingClientPurchase.purchaseState == PurchaseStateWrapper.purchased) {
              restorePayload.add(_serializePurchase(p));
              if (p.pendingCompletePurchase) {
                toComplete.add(p);
              }
            }
          }
        }

        // Also trigger standard store restorePurchases if nothing was already returned
        if (restorePayload.isEmpty) {
          _restoredBuffer.clear();
          _restoreCompleter = Completer<List<PurchaseDetails>>();
          await _iap.restorePurchases();
          await Future.delayed(const Duration(seconds: 2));
          if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
            _restoreCompleter!.complete(List<PurchaseDetails>.from(_restoredBuffer));
          }
          final streamed = await (_restoreCompleter?.future ?? Future.value(<PurchaseDetails>[]));
          _restoreCompleter = null;
          for (final p in streamed) {
            restorePayload.add(_serializePurchase(p));
            if (p.pendingCompletePurchase) {
              toComplete.add(p);
            }
          }
        }
      }

      final restoreUrl = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.restoreSubscription);
      final response = await ApiClient.post(
        restoreUrl,
        body: {
          'platform': platformStr,
          'purchases': restorePayload,
        },
      );

      final data = _decodeResponse(response.data);
      if (response.statusCode == 200 && data?['success'] == true && data?['restored'] == true) {
        for (final p in toComplete) {
          await _iap.completePurchase(p);
        }
        final subData = data!['data'] as Map<String, dynamic>?;
        await _syncPlanStateAndNavigate(
          subData: subData,
          fallbackIsTeam: (subData?['plan_type'] ?? '').toString().toUpperCase() == 'TEAM',
          successMessage: 'Subscription restored successfully!',
        );
        return true;
      }

      _showInfo(data?['message']?.toString() ?? 'No active subscription found to restore.');
      return false;
    } catch (e) {
      debugPrint('Restore subscription error: $e');
      _showError('Could not restore subscription. Please try again.');
      return false;
    }
  }

  Future<void> _onPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      final productId = purchase.productID;

      if (purchase.status == PurchaseStatus.pending) {
        continue;
      }

      if (purchase.status == PurchaseStatus.canceled) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        _finishCompleter(productId, false);
        _showInfo('Purchase was cancelled.');
        continue;
      }

      if (purchase.status == PurchaseStatus.error) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        _finishCompleter(productId, false);
        _showError(purchase.error?.message ?? 'Store purchase failed.');
        continue;
      }

      if (purchase.status == PurchaseStatus.restored) {
        if (_restoreCompleter != null && !_restoreCompleter!.isCompleted) {
          _restoredBuffer.add(purchase);
          continue;
        }
        // Only treat unsolicited restored events if user initiated purchase on this product
        if (!_pendingPlanUuids.containsKey(productId)) {
          if (purchase.pendingCompletePurchase) {
            await _iap.completePurchase(purchase);
          }
          continue;
        }
      }

      if (purchase.status == PurchaseStatus.purchased || purchase.status == PurchaseStatus.restored) {
        final ok = await _verifyAndCompletePurchase(purchase);
        _finishCompleter(productId, ok);
      }
    }
  }

  Future<bool> _verifyAndCompletePurchase(PurchaseDetails purchase) async {
    final productId = purchase.productID;
    final pendingUuid = _pendingPlanUuids.remove(productId);
    final isTeam = _pendingIsTeam.remove(productId) ?? productId.contains('_team_');

    if (pendingUuid == null || pendingUuid.isEmpty) {
      if (purchase.pendingCompletePurchase) {
        await _iap.completePurchase(purchase);
      }
      return false;
    }

    try {
      final payload = _serializePurchase(purchase);
      payload['subscription_plan_uuid'] = pendingUuid;
      payload['platform'] = GetPlatform.isIOS ? 'ios' : 'android';

      final verifyUrl = Uri.parse(HomeApiConstant.baseUrl + HomeApiConstant.purchaseVerify);
      final verifyResponse = await ApiClient.post(verifyUrl, body: payload);
      final vData = _decodeResponse(verifyResponse.data);

      if ((verifyResponse.statusCode == 200 || verifyResponse.statusCode == 201) &&
          vData?['success'] == true) {
        if (purchase.pendingCompletePurchase) {
          await _iap.completePurchase(purchase);
        }
        final subData = vData?['data'] as Map<String, dynamic>?;
        await _syncPlanStateAndNavigate(
          subData: subData,
          fallbackIsTeam: isTeam,
          successMessage: 'Subscription activated successfully!',
        );
        return true;
      }

      _showError(_extractErrorMessage(vData, 'Failed to verify purchase with server.'));
      return false;
    } catch (e) {
      debugPrint('Purchase verify error: $e');
      _showError('An error occurred while verifying your purchase.');
      return false;
    }
  }

  Map<String, dynamic> _serializePurchase(PurchaseDetails purchase) {
    String? purchaseToken = purchase.verificationData.serverVerificationData;
    String? orderId;
    bool autoRenew = true;

    if (purchase is GooglePlayPurchaseDetails) {
      purchaseToken = purchase.billingClientPurchase.purchaseToken;
      orderId = purchase.billingClientPurchase.orderId;
      autoRenew = purchase.billingClientPurchase.isAutoRenewing;
    }

    final txId = purchase.purchaseID ?? orderId ?? purchaseToken;
    DateTime? purchaseTime;
    final rawMs = int.tryParse(purchase.transactionDate ?? '');
    if (rawMs != null && rawMs > 0) {
      purchaseTime = DateTime.fromMillisecondsSinceEpoch(rawMs, isUtc: true);
    }

    return {
      'product_id': purchase.productID,
      'transaction_id': txId,
      'original_transaction_id': orderId ?? txId,
      'purchase_token': purchaseToken,
      if (GetPlatform.isIOS) 'receipt_data': purchase.verificationData.serverVerificationData,
      'package_name': androidPackageName,
      'order_id': orderId,
      'auto_renew': autoRenew,
      if (purchaseTime != null) 'purchase_time': purchaseTime.toIso8601String(),
      'raw_response': {
        'source': purchase.verificationData.source,
        'localVerificationData': purchase.verificationData.localVerificationData,
      },
    };
  }

  Future<void> _syncPlanStateAndNavigate({
    required Map<String, dynamic>? subData,
    required bool fallbackIsTeam,
    required String successMessage,
  }) async {
    final planType = (subData?['plan_type'] ?? '').toString().toUpperCase();
    final bool isTeam = planType.isNotEmpty ? (planType == 'TEAM') : fallbackIsTeam;

    await AuthService.saveIsTeamPlan(isTeam);
    if (Get.isRegistered<NavController>()) {
      Get.find<NavController>().updateTeamPlanStatus(isTeam);
    }

    Get.snackbar(
      'Success',
      successMessage,
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    if (isTeam) {
      Get.offAllNamed(AppRoutes.teamManager);
    } else {
      Get.offAllNamed(AppRoutes.homeScreen);
    }
  }

  void _finishCompleter(String productId, bool result) {
    final c = _purchaseCompleters.remove(productId);
    if (c != null && !c.isCompleted) {
      c.complete(result);
    }
  }

  Map<String, dynamic>? _decodeResponse(dynamic raw) {
    if (raw == null) return null;
    if (raw is Map<String, dynamic>) return raw;
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  String _extractErrorMessage(Map<String, dynamic>? data, String fallback) {
    if (data == null) return fallback;
    if (data['message'] != null && data['message'].toString().isNotEmpty) {
      return data['message'].toString();
    }
    if (data['detail'] != null && data['detail'].toString().isNotEmpty) {
      return data['detail'].toString();
    }
    if (data['errors'] is Map) {
      final errors = data['errors'] as Map;
      if (errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return first.first.toString();
        return first.toString();
      }
    }
    return fallback;
  }

  void _showError(String msg) {
    Get.snackbar('Error', msg, backgroundColor: Colors.red, colorText: Colors.white);
  }

  void _showInfo(String msg) {
    Get.snackbar('Subscription', msg, backgroundColor: Colors.orange.shade800, colorText: Colors.white);
  }
}
