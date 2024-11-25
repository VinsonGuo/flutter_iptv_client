import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/model/m3u8_entry.dart';
import 'package:flutter_iptv_client/ui/page/import_page.dart';
import 'package:flutter_iptv_client/ui/page/country_page.dart';
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
  late ScrollController scrollController;

  @override
  void initState() {
    super.initState();
    scrollController = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChannelProvider>().getChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final channels = context.select((ChannelProvider value) => value.channels);
    final loading = context.select((ChannelProvider value) => value.loading);
    final allChannels = context.select((ChannelProvider value) => value.allChannels);
    final category = context.select((ChannelProvider value) => value.category);
    final country = context.select((ChannelProvider value) => value.country);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset('assets/images/ic_banner.png', width: 120, height: 60,),
        actions: [
          IconButton(
            focusColor: Colors.grey,
              onPressed: () {
                Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CountryPage()));
              },
              icon: country == 'all'
                  ? const Icon(
                      Icons.language,
                    )
                  : Image.asset(
                      'assets/images/flags/${country.toLowerCase()}.png',
                      height: 28,
                    )),
          IconButton(
            focusColor: Colors.grey,
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChannelSearchDelegate(),
              );
            },
          ),
          IconButton(
            focusColor: Colors.grey,
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ChannelProvider>().getChannels();
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
                  autofocus: category == item,
                  title: Text(item.toUpperCase()),
                  selected: category == item,
                  selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                  selectedColor: Theme.of(context).colorScheme.primary,
                  onTap: () {
                    context
                        .read<ChannelProvider>()
                        .selectCategory(category: item);
                    scrollController.jumpTo(0);
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
                  child: Visibility(
                    visible: loading || allChannels.isNotEmpty,
                    replacement: Center(
                      child: FilledButton(
                        onPressed: () {
                          context.read<ChannelProvider>().getChannels();
                        },
                        child: const Text('Try Again'),
                      ),
                    ),
                    child: Scrollbar(
                      child: GridView.builder(
                        controller: scrollController,
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
    scrollController.dispose();
  }
}
