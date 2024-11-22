import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:provider/provider.dart';

import '../../provider/channel_provider.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.select((ChannelProvider value) => value.language);
    return Scaffold(
      appBar: AppBar(title: Text('Select Channel Language')),
      body: Expanded(
        child: GridView.builder(
            gridDelegate:
                SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
            itemBuilder: (_, index) {
              final item = channelLanguage[index];
              return ListTile(
                selected: language == item,
                selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                selectedColor: Theme.of(context).colorScheme.primary,
                title: item == 'all'? Icon(Icons.language, size: 48,):Image.asset('assets/images/flags/${isoMapping[item]}.png', height: 48,),
                subtitle: Text(item, textAlign: TextAlign.center,),
                onTap: () {
                  context.read<ChannelProvider>().selectLanguage(language:item);
                },
              );
            }, itemCount: channelLanguage.length,),
      ),
    );
  }
}
