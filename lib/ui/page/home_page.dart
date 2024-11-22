import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/model/m3u8_entry.dart';
import 'package:flutter_iptv_client/ui/page/language_page.dart';
import 'package:flutter_iptv_client/ui/page/video_page.dart';
import 'package:flutter_iptv_client/ui/widget/channel_search_delegate.dart';
import 'package:flutter_iptv_client/ui/widget/m3u8_thumbnail.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../provider/channel_provider.dart';
import '../widget/channel_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  @override
  void initState() {
    super.initState();
    context.read<ChannelProvider>().getChannels();
  }

  @override
  Widget build(BuildContext context) {
    final channels = context.select((ChannelProvider value) => value.channels);
    final category = context.select((ChannelProvider value) => value.category);
    final language = context.select((ChannelProvider value) => value.language);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(onPressed: () {
            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>LanguagePage()));
          }, icon: language == 'all'? Icon(Icons.language,):Image.asset('assets/images/flags/${isoMapping[language]}.png', height: 28,)),
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChannelSearchDelegate(),
              );
            },
          )
        ],
      ),
      body: Row(
        children: [
          SizedBox(
            width: 180,
            height: double.infinity,
            child: ListView.builder(
              itemBuilder: (_, index) {
                final item = channelCategories[index];
                return ListTile(
                  title: Text(item.toUpperCase()),
                  selected: category == item,
                  selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    context.read<ChannelProvider>().selectCategory(category: item);
                  },
                );
              },
              itemCount: channelCategories.length,
            ),
          ),
          Expanded(
            child: Column(
              children: [
                Expanded(
                  child: Scrollbar(
                    child: GridView.builder(
                      itemBuilder: (context, index) {
                        final item = channels[index];
                        return ChannelListTile(item: item);
                      },
                      itemCount: channels.length,
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                              mainAxisSpacing: 5,
                              crossAxisSpacing: 5,
                              crossAxisCount: 4,
                              childAspectRatio: 1.2),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
