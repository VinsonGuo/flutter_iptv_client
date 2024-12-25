import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/common/shared_preference.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class SettingsProvider with ChangeNotifier {
  Color seedColor = Color(sharedPreferences.getInt(seedColorKey) ?? Colors.deepPurple.value);

  static const seedColorKey = 'seedColorKey';

  static const seedColorMap = {
    'deepPurple':Colors.deepPurple,
    'indigo':Colors.indigo,
    'blue':Colors.blue,
    'green':Colors.green,
    'lime':Colors.lime,
    'red':Colors.red,
    'pink':Colors.pink,
    'orange':Colors.orange,
    'cyan':Colors.cyan,
    'teal':Colors.teal,
  };

  ConsentStatus? status;

  bool get hasConsent => status == ConsentStatus.obtained || status == ConsentStatus.notRequired;


  SettingsProvider() {
    ConsentInformation.instance.getConsentStatus().then((status) {
      status = status;
      notifyListeners();
    });
  }

  void setSeedColor(Color color) {
    seedColor = color;
    sharedPreferences.setInt(seedColorKey, color.value);
    notifyListeners();
  }

  void updateConsent() {
    final params = ConsentRequestParameters(
      tagForUnderAgeOfConsent: false,
      consentDebugSettings: ConsentDebugSettings(
        debugGeography: DebugGeography.debugGeographyDisabled,
      ),
    );
    ConsentInformation.instance.requestConsentInfoUpdate(
      params,
          () async {
        if (await ConsentInformation.instance.isConsentFormAvailable()) _loadForm();
      },
          (FormError error) {},
    );
  }

  void _loadForm() {
    ConsentForm.loadConsentForm(
          (consentForm) async {
        status = await ConsentInformation.instance.getConsentStatus();
        if (status == ConsentStatus.required) {
          consentForm.show(
                (formError) => _loadForm(),
          );
        }
      },
          (formError) {},
    );
  }

  Future<void> debugReset() async {
    await ConsentInformation.instance.reset();
  }
}