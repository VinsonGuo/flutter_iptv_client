import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

const int maxFailedLoadAttempts = 3;

class AdMobBannerWidget extends StatefulWidget {
  const AdMobBannerWidget({super.key});

  @override
  State<AdMobBannerWidget> createState() => _AdMobBannerWidgetState();
}

class _AdMobBannerWidgetState extends State<AdMobBannerWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAd();
    });
    _retryTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (!_isLoaded) {
        loadAd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: !_isLoaded
          ? const SizedBox.shrink()
          : SizedBox(
              width: double.infinity,
              height: 50,
              child: AdWidget(ad: _bannerAd!)),
    );
  }

  void loadAd() {
    _bannerAd?.dispose();
    _bannerAd = BannerAd(
      adUnitId: bannerVideo,
      request: const AdRequest(),
      size:
          AdSize(width: MediaQuery.of(context).size.width.toInt(), height: 50),
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
          setState(() {
            _isLoaded = false;
          });
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose(); // 释放广告资源
    _retryTimer?.cancel(); // 停止定时器
    super.dispose();
  }
}

class AdMobNativeWidget extends StatefulWidget {
  const AdMobNativeWidget({super.key});

  @override
  State<AdMobNativeWidget> createState() => _AdMobNativeWidgetState();
}

class _AdMobNativeWidgetState extends State<AdMobNativeWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAd();
    });
    _retryTimer = Timer.periodic(const Duration(minutes: 3), (timer) {
      if (!_isLoaded) {
        loadAd();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: !_isLoaded
          ? const SizedBox.shrink()
          : SizedBox(
              width: double.infinity,
              height: 80,
              child: AdWidget(ad: _nativeAd!)),
    );
  }

  void loadAd() {
    _nativeAd?.dispose();
    _nativeAd = NativeAd(
      adUnitId: 'ca-app-pub-1990824556833029/2825754758',
      nativeTemplateStyle:
          NativeTemplateStyle(templateType: TemplateType.small),
      request: const AdRequest(),
      listener: NativeAdListener(
        // Called when an ad is successfully received.
        onAdLoaded: (ad) {
          debugPrint('$ad loaded.');
          setState(() {
            _isLoaded = true;
          });
        },
        // Called when an ad request failed.
        onAdFailedToLoad: (ad, error) {
          debugPrint('NativeAd failed to load: $error');
          // Dispose the ad here to free resources.
          ad.dispose();
          setState(() {
            _isLoaded = false;
          });
        },
      ),
    )..load();
  }

  @override
  void dispose() {
    _nativeAd?.dispose(); // 释放广告资源
    _retryTimer?.cancel(); // 停止定时器
    super.dispose();
  }
}

class MobAdManager {
  static InterstitialAd? _interstitialAd;
  static int _numInterstitialLoadAttempts = 0;
  static const AdRequest request = AdRequest();

  static void createInterstitialAd() {
    InterstitialAd.load(
        adUnitId: 'ca-app-pub-1990824556833029/1737163667',
        request: request,
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (InterstitialAd ad) {
            print('$ad loaded');
            _interstitialAd = ad;
            _numInterstitialLoadAttempts = 0;
            // _interstitialAd!.setImmersiveMode(true);
          },
          onAdFailedToLoad: (LoadAdError error) {
            print('InterstitialAd failed to load: $error.');
            _numInterstitialLoadAttempts += 1;
            _interstitialAd = null;
            if (_numInterstitialLoadAttempts < maxFailedLoadAttempts) {
              createInterstitialAd();
            }
          },
        ));
  }

  static void showInterstitialAd() {
    if (_interstitialAd == null) {
      print('Warning: attempt to show interstitial before loaded.');
      return;
    }
    _interstitialAd!.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (InterstitialAd ad) =>
          print('ad onAdShowedFullScreenContent.'),
      onAdDismissedFullScreenContent: (InterstitialAd ad) {
        print('$ad onAdDismissedFullScreenContent.');
        ad.dispose();
        createInterstitialAd();
      },
      onAdFailedToShowFullScreenContent: (InterstitialAd ad, AdError error) {
        print('$ad onAdFailedToShowFullScreenContent: $error');
        ad.dispose();
        createInterstitialAd();
      },
    );
    _interstitialAd!.show();
    _interstitialAd = null;
  }
}
