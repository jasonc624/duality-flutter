import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'dart:io' show Platform;

class ListAdWidget extends StatefulWidget {
  final String adUnitId;
  final AdSize adSize;

  const ListAdWidget({
    Key? key,
    required this.adUnitId,
    this.adSize = AdSize.banner,
  }) : super(key: key);

  @override
  _ListAdWidgetState createState() => _ListAdWidgetState();
}

class _ListAdWidgetState extends State<ListAdWidget> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  void _loadAd() {
    final String testAdUnitId = Platform.isAndroid
        ? 'ca-app-pub-3940256099942544/6300978111' // Android test ad unit ID
        : 'ca-app-pub-3940256099942544/2934735716'; // iOS test ad unit ID

    _bannerAd = BannerAd(
      size: widget.adSize,
      adUnitId: kDebugMode ? testAdUnitId : widget.adUnitId,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          setState(() {
            _isAdLoaded = true;
          });
        },
        onAdFailedToLoad: (ad, error) {
          debugPrint('BannerAd failed to load: $error');
          ad.dispose();
        },
      ),
    );

    _bannerAd!.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_isAdLoaded && _bannerAd != null) {
      return Container(
        color: Colors.deepPurple.shade100,
        alignment: Alignment.center,
        width: double.infinity,
        height: 40.0,
        child: AdWidget(ad: _bannerAd!),
      );
    }
    // Return an empty container if the ad is not loaded
    return Container();
  }
}
