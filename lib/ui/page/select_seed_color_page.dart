import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/provider/settings_provider.dart';
import 'package:provider/provider.dart';

class SelectSeedColorPage extends StatelessWidget {
  const SelectSeedColorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    final seedColor =
        context.select((SettingsProvider value) => value.seedColor);
    final colors = SettingsProvider.seedColorMap.entries.toList();
    return Scaffold(
      appBar: AppBar(title: const Text('Select Theme Color')),
      body: ListView.builder(
        itemBuilder: (_, index) {
          final color = colors[index];
          return RadioListTile(
              title: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: color.value,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Text(color.key),
                ],
              ),
              value: color.value.value,
              groupValue: seedColor.value,
              autofocus: seedColor.value == color.value.value,
              onChanged: (value) {
                if (value != null) {
                  provider.setSeedColor(Color(value));
                }
              });
        },
        itemCount: colors.length,
      ),
    );
  }
}
