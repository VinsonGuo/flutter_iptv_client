import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:provider/provider.dart';

import '../../provider/channel_provider.dart';

class ImportPage extends StatefulWidget {
  const ImportPage({super.key});

  @override
  State<ImportPage> createState() => _ImportPageState();
}

class _ImportPageState extends State<ImportPage> {
  late TextEditingController textEditingController;
  @override
  void initState() {
    super.initState();
    textEditingController = TextEditingController();
  }
  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChannelProvider>();
    return Scaffold(
      appBar: AppBar(title: Text('Import m3u8 url')),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          children: [
            TextField(controller: textEditingController, autofocus: true,),
            SizedBox(height: 10,),
            Row(
              children: [
              FilledButton(onPressed: ()async{
                final text = textEditingController.text.trim();
                await provider.importFromUrl(text);
                provider.getChannels();
              }, child: Text('Import')),
                SizedBox(width: 10,),
              FilledButton(onPressed: ()async{
                await provider.resetM3UContent();
                provider.getChannels();
              }, child: Text('Reset')),
            ],)
          ],
        )
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    textEditingController.dispose();
  }
}
