import 'package:flutter/foundation.dart';
import 'package:native_admob_flutter/native_admob_flutter.dart';

String get nativeAdUnitId {
  /// Always test with test ads
  if (kDebugMode)
    return MobileAds.nativeAdTestUnitId;
  else return 'your-native-ad-unit-id';
}

String get bannerAdUnitId {
  /// Always test with test ads
  if (kDebugMode)
    return MobileAds.bannerAdTestUnitId;
  //ca-app-pub-1517358707245875~4566120379
  else return 'ca-app-pub-1517358707245875/1801846925';
}

String get interstitialAdUnitId {
  /// Always test with test ads
  if (kDebugMode)
    return MobileAds.interstitialAdTestUnitId;
  else return 'you-interstitial-ad-unit-id';
}

String get rewardedAdUnitId {
  /// Always test with test ads
  if (kDebugMode)
    return MobileAds.rewardedAdTestUnitId;
  else return 'you-interstitial-ad-unit-id';
}

String get appOpenAdUnitId {
  /// Always test with test ads
  if (kDebugMode) return MobileAds.appOpenAdTestUnitId;
  else return 'you-app-open-ad-unit-id';
}

String get rewardedInterstitialAdUnitId {
  /// Always test with test ads
  if (kDebugMode)
    return MobileAds.rewardedInterstitialAdTestUnitId;
  else return 'you-interstitial-ad-unit-id';
}