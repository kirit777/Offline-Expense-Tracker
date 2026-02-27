import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'src/app/app.dart';
import 'src/core/ads/ads_manager.dart';
import 'src/core/services/hive_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.initialize();
  await MobileAds.instance.initialize();
  AdsManager.instance.loadInterstitialAd();
  runApp(const ProviderScope(child: ExpenseTrackerApp()));
}
