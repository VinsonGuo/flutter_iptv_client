import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../common/data.dart';
import '../../provider/channel_provider.dart';

class SelectM3u8Page extends StatefulWidget {
  const SelectM3u8Page({super.key});

  @override
  State<SelectM3u8Page> createState() => _SelectM3u8PageState();
}

class _SelectM3u8PageState extends State<SelectM3u8Page> {
  late TextEditingController textEditingController;

  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChannelProvider>();
    final currentUrl =
        context.select((ChannelProvider value) => value.currentUrl);
    final m3u8UrlList =
        context.select((ChannelProvider value) => value.m3u8UrlList);
    return Scaffold(
      appBar: AppBar(title: const Text('Select m3u url')),
      body: Stack(
        children: [
          ListView(
            children: [
              MediaQuery.of(context).orientation == Orientation.portrait
                  ? Column(children: [
                      ListTile(
                        title: const Text('Import m3u playlist url'),
                        subtitle: TextField(
                          controller: textEditingController,
                          onSubmitted: (_) async {
                            await onImportPress(provider);
                          },
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          FilledButton(
                              onPressed: () async {
                                await onImportPress(provider);
                              },
                              child: const Text('Import')),
                          FilledButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                await provider.resetM3UContent();
                                if (mounted) {
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(const SnackBar(
                                          content: Text('Reset success')));
                                }
                              },
                              child: const Text('Reset')),
                        ],
                      )
                    ])
                  : ListTile(
                      title: const Text('Import m3u playlist url'),
                      subtitle: TextField(
                        controller: textEditingController,
                        onSubmitted: (_) async {
                          await onImportPress(provider);
                        },
                      ),
                      trailing: Wrap(
                        children: [
                          FilledButton(
                              onPressed: () async {
                                await onImportPress(provider);
                              },
                              child: const Text('Import')),
                          const SizedBox(
                            width: 10,
                          ),
                          FilledButton(
                              onPressed: () async {
                                FocusManager.instance.primaryFocus?.unfocus();
                                await provider.resetM3UContent();
                                if (mounted) {
                                  ScaffoldMessenger.of(this.context)
                                      .showSnackBar(const SnackBar(
                                          content: Text('Reset success')));
                                }
                              },
                              child: const Text('Reset')),
                        ],
                      ),
                    ),
              for (final url in m3u8UrlList)
                Row(
                  children: [
                    Expanded(
                      child: RadioListTile(
                          title: Text(url),
                          value: url,
                          groupValue: currentUrl,
                          autofocus: url == currentUrl,
                          onChanged: (value) {
                            if (value != null) {
                              provider.importFromUrl(value);
                            }
                          }),
                    ),
                    Visibility(
                        visible: url != defaultM3u8Url && url != currentUrl,
                        child: IconButton(
                          onPressed: () async {
                            final result = await showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                      title: Text('Message'),
                                      content: Text('Confirm to delete?'),
                                      actions: [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, false);
                                            },
                                            child: Text('Cancel')),
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context, true);
                                            },
                                            child: Text('Confirm')),
                                      ],
                                    ));
                            if (result == true) {
                              provider.deleteM3u8Url(url);
                            }
                          },
                          icon: const Icon(
                            Icons.delete,
                          ),
                        )),
                  ],
                ),
            ],
          ),
          Visibility(
              visible: context.select((ChannelProvider value) => value.loading),
              replacement: const SizedBox(
                height: 4,
              ),
              child: const LinearProgressIndicator()),
        ],
      ),
    );
  }

  Future<void> onImportPress(ChannelProvider provider) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final text = textEditingController.text.trim();
    if (await provider.importFromUrl(text)) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Import success')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Import failed, please check m3u8 url')));
      }
    }
  }
}
