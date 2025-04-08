import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/provider/settings_provider.dart';
import 'package:flutter_iptv_client/ui/page/select_m3u8_page.dart';
import 'package:flutter_iptv_client/ui/page/select_seed_color_page.dart';
import 'package:flutter_iptv_client/ui/page/video_settings_page.dart';
import 'package:flutter_iptv_client/ui/widget/global_loading_widget.dart';
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
      body: GlobalLoadingWidget(
        child: ListView(
          children: [
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Select M3U Playlist'),
              subtitle: Text(currentUrl == null || currentUrl.isEmpty
                  ? 'Please Select M3U Playlist'
                  : 'current url: $currentUrl'),
              autofocus: true,
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SelectM3u8Page()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.refresh),
              onTap: () {
                context.read<ChannelProvider>().getChannels();
              },
              title: const Text('Refresh Channels'),
            ),
            ListTile(
              leading: const Icon(Icons.color_lens),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const SelectSeedColorPage()));
              },
              title: const Text('Theme'),
            ),
            ListTile(
              leading: const Icon(Icons.ondemand_video),
              onTap: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const VideoSettingsPage()));
              },
              title: const Text('Video Settings'),
            ),
            if (Platform.isAndroid)
              ListTile(
                leading: const Icon(Icons.store),
                onTap: () {
                  launchUrl(Uri.parse("https://play.google.com/store/apps/details?id=com.vinsonguo.flutter_iptv_client"));
                },
                title: const Text('Google Play'),
              ),
            ListTile(
              leading: const Icon(Icons.feedback),
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
            ),
            const Divider(),
            AboutListTile(
              applicationName: appName,
              applicationVersion: version,
              aboutBoxChildren: const [
                Text("UniTV is a Flutter-based application that allows users to watch 10000+ TV channels from any country. The app provides a seamless experience with features like remote-control integration, import m3u8 playlist, video playback, and an intuitive user interface."),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
