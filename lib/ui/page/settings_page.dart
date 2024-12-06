import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/ui/page/select_m3u8_page.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../provider/channel_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String appName = '';
  String version = '';

  @override
  void initState() {
    super.initState();
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        appName = value.appName;
        version = value.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentUrl =
        context.select((ChannelProvider value) => value.currentUrl);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Stack(
        children: [
          ListView(
            children: [
              ListTile(
                title: const Text('Select m3u8 url'),
                subtitle: Text('current url: $currentUrl'),
                autofocus: true,
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const SelectM3u8Page()));
                },
              ),
              ListTile(
                onTap: () {
                  launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=com.vinsonguo.flutter_iptv_client"));
                },
                title: const Text('Google Play'),
              ),
              ListTile(
                onTap: () {
                  launchUrl(Uri(
                    scheme: 'mailto',
                    path: 'guoziwei93@gmail.com',
                    queryParameters: {
                      'subject': 'Feedback for UniTV',
                    },
                  ));
                },
                title: const Text('Feedback'),
                subtitle: const Text('guoziwei93@gmail.com'),
              ),
              AboutListTile(
                applicationName: appName,
                applicationVersion: version,
                aboutBoxChildren: const [
                  Text("UniTV is a Flutter-based application that allows users to watch 10000+ TV channels from any country. The app provides a seamless experience with features like remote-control integration, import m3u8 playlist, video playback, and an intuitive user interface."),
                ],
              ),
            ],
          ),
          Visibility(
              visible:
              context.select((ChannelProvider value) => value.loading),
              replacement: const SizedBox(height: 4,),
              child: const LinearProgressIndicator()),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
