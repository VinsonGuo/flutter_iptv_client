import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class VideoSettingsPage extends StatelessWidget {
  const VideoSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    final is16to9 = context.select((SettingsProvider value) => value.is16to9);
    return Scaffold(
        appBar: AppBar(title: const Text('Select Video Ratio')),
        body: ListView(
          children: [
            const ListTile(
              title: Text('Select Video Ratio'),
            ),
            RadioListTile(
                title: const Text('Original'),
                value: SettingsProvider.videoRatioOriginal,
                groupValue: is16to9
                    ? SettingsProvider.videoRatio16to9
                    : SettingsProvider.videoRatioOriginal,
                onChanged: (value) {
                  if (value != null) {
                    provider.setVideoRatio(value);
                  }
                }),
            RadioListTile(
                title: const Text('16:9'),
                value: SettingsProvider.videoRatio16to9,
                groupValue: is16to9
                    ? SettingsProvider.videoRatio16to9
                    : SettingsProvider.videoRatioOriginal,
                onChanged: (value) {
                  if (value != null) {
                    provider.setVideoRatio(value);
                  }
                })
          ],
        ));
  }
}
