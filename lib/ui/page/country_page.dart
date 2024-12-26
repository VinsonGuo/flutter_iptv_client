import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../provider/channel_provider.dart';

class CountryPage extends StatelessWidget {
  const CountryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final language = context.select((ChannelProvider value) => value.country);
    final allCountries = context.select((ChannelProvider value) => value.allCountries);
    return Scaffold(
      appBar: AppBar(title: const Text('Channel Country/Region')),
      body: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: MediaQuery.of(context).size.width ~/ 80),
        itemBuilder: (_, index) {
          final item = allCountries[index];
          return ListTile(
            selected: language == item,
            selectedTileColor: Theme.of(context).colorScheme.onPrimary,
            selectedColor: Theme.of(context).colorScheme.primary,
            title: Builder(
              builder: (context) {
                Widget icon;
                if (item == 'all') {
                  icon = const Icon(Icons.language, size: 48,);
                } else if (item == 'uncategorized') {
                  icon = const Icon(Icons.question_mark, size: 48,);
                } else {
                  icon = Image.asset('assets/images/flags/${item.toLowerCase()}.png', height: 48,);
                }
                return icon;
              }
            ),
            subtitle: Text(
              item.toUpperCase(),
              textAlign: TextAlign.center,
            ),
            onTap: () {
              context.read<ChannelProvider>().selectCountry(country: item);
              Navigator.of(context).pop();
            },
          );
        },
        itemCount: allCountries.length,
      ),
    );
  }
}
