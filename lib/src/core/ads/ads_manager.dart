import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsManager {
  AdsManager._();

  static final AdsManager instance = AdsManager._();

  static String get bannerAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/6300978111'
          : 'ca-app-pub-3940256099942544/2934735716';
    }
    return _bannerProdId;
  }

  static String get interstitialAdUnitId {
    if (kDebugMode) {
      return Platform.isAndroid
          ? 'ca-app-pub-3940256099942544/1033173712'
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return _interstitialProdId;
  }

  // Replace with your production IDs.
  static const String _bannerProdId = 'ca-app-pub-xxxxxxxxxxxxxxxx/banner';
  static const String _interstitialProdId = 'ca-app-pub-xxxxxxxxxxxxxxxx/interstitial';

  InterstitialAd? _interstitialAd;

  void loadInterstitialAd() {
    InterstitialAd.load(
      adUnitId: interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
        },
        onAdFailedToLoad: (_) {
          _interstitialAd = null;
        },
      ),
    );
  }

  void showInterstitialAd({VoidCallback? onDismissed}) {
    final ad = _interstitialAd;
    if (ad == null) {
      loadInterstitialAd();
      onDismissed?.call();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, _) {
        ad.dispose();
        _interstitialAd = null;
        loadInterstitialAd();
        onDismissed?.call();
      },
    );

    ad.show();
  }
}
