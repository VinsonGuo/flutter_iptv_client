import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import '../../provider/channel_provider.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController textEditingController;
  String appName = '';
  String version = '';

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
    PackageInfo.fromPlatform().then((value) {
      setState(() {
        appName = value.appName;
        version = value.version;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChannelProvider>();
    final currentUrl =
        context.select((ChannelProvider value) => value.currentUrl);
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          Visibility(
              visible:
                  context.select((ChannelProvider value) => value.loading),
              replacement: const SizedBox(height: 4,),
              child: const LinearProgressIndicator()),
          ListTile(
            title: const Text('Import m3u8 playlist url'),
            subtitle: TextField(
              controller: textEditingController,
              autofocus: true,
            ),
            trailing: Wrap(children: [
              FilledButton(
                  onPressed: () async {
                    final text = textEditingController.text.trim();
                    if (await provider.importFromUrl(text)) {
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                                content: Text('Import success')));
                      }
                    } else {
                      if (mounted) {
                        ScaffoldMessenger.of(this.context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    'Import failed, please check m3u8 url')));
                      }
                    }
                  },
                  child: const Text('Import')),
              const SizedBox(
                width: 10,
              ),
              FilledButton(
                  onPressed: () async {
                    await provider.resetM3UContent();
                    if (mounted) {
                      ScaffoldMessenger.of(this.context).showSnackBar(
                          const SnackBar(content: Text('Reset success')));
                    }
                  },
                  child: const Text('Reset')),
            ],),
          ),
          ListTile(
            title: const Text('Current m3u8 url'),
            subtitle: Text(currentUrl ?? ''),
          ),
          AboutListTile(
            applicationName: appName,
            applicationVersion: version,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }
}
