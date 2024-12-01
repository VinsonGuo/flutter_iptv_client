import 'package:flutter/cupertino.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdMobWidget extends StatefulWidget {
  const AdMobWidget({super.key});

  @override
  State<AdMobWidget> createState() => _AdMobWidgetState();
}

class _AdMobWidgetState extends State<AdMobWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      loadAd();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: !_isLoaded
          ? const SizedBox.shrink()
          : SizedBox(
              width: MediaQuery.of(context).size.width / 2.5,
              height: 40,
              child: AdWidget(ad: _bannerAd!)),
    );
  }

  void loadAd() {
    _bannerAd = BannerAd(
      adUnitId: 'ca-app-pub-1990824556833029/8865250198',
      request: const AdRequest(),
      size: AdSize(width: MediaQuery.of(context).size.width ~/ 2.5, height: 40),
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
}
