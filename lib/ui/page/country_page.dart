import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:provider/provider.dart';

import '../../provider/channel_provider.dart';

class CountryPage extends StatelessWidget {
  const CountryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.select((ChannelProvider value) => value.country);
    return Scaffold(
      appBar: AppBar(title: const Text('Select Channel Country/Region')),
      body: GridView.builder(
        gridDelegate:
            const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 8),
        itemBuilder: (_, index) {
          final item = channelCountries[index];
          return ListTile(
            selected: language == item,
            selectedTileColor: Theme.of(context).colorScheme.onPrimary,
            selectedColor: Theme.of(context).colorScheme.primary,
            title: item == 'all'
                ? const Icon(
                    Icons.language,
                    size: 48,
                  )
                : Image.asset(
                    'assets/images/flags/${item.toLowerCase()}.png',
                    height: 48,
                  ),
            subtitle: Text(
              item,
              textAlign: TextAlign.center,
            ),
            onTap: () {
              context.read<ChannelProvider>().selectCountry(country: item);
              Navigator.of(context).pop();
            },
          );
        },
        itemCount: channelCountries.length,
      ),
    );
  }
}
