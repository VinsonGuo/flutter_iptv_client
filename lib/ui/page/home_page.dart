import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/model/m3u8_entry.dart';
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
  String selectedCategory = channelCategories[0];

  @override
  void initState() {
    super.initState();
    context.read<ChannelProvider>().getChannels();
  }

  @override
  Widget build(BuildContext context) {
    final channels = context.select((ChannelProvider value) => value.channels);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            icon: Icon(Icons.search),
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
                  selected: selectedCategory == item,
                  selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    setState(() {
                      selectedCategory = item;
                    });
                    context.read<ChannelProvider>().select(category: item);
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
