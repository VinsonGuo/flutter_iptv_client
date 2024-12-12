import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobWidget extends StatefulWidget {
  const AdMobWidget({super.key, required this.adId, required this.width});

  final String adId;
  final int width;

  @override
  State<AdMobWidget> createState() => _AdMobWidgetState();
}

class _AdMobWidgetState extends State<AdMobWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAd();
    });
    _refreshTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      loadAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: !_isLoaded
          ? const SizedBox.shrink()
          : SizedBox(
              width: widget.width.toDouble(),
              height: 50,
              child: AdWidget(ad: _bannerAd!)),
    );
  }

  void loadAd() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: widget.adId,
      request: const AdRequest(),
      size: AdSize(width: widget.width, height: 40),
      listener: BannerAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          // Dispose the ad here to free resources.
          ad.dispose();
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // 释放广告资源
    _refreshTimer?.cancel(); // 停止定时器
    super.dispose();
  }
}
