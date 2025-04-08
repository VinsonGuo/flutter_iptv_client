import 'package:flutter/material.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:flutter_iptv_client/provider/settings_provider.dart';
import 'package:flutter_iptv_client/ui/page/country_page.dart';
import 'package:flutter_iptv_client/ui/page/select_m3u8_page.dart';
import 'package:flutter_iptv_client/ui/page/settings_page.dart';
import 'package:flutter_iptv_client/ui/widget/admob_widget.dart';
import 'package:flutter_iptv_client/ui/widget/channel_search_delegate.dart';
import 'package:flutter_iptv_client/ui/widget/global_loading_widget.dart';
import 'package:provider/provider.dart';

import '../../provider/channel_provider.dart';
import '../widget/channel_list_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ScrollController scrollController = ScrollController();
  ChannelSearchDelegate delegate = ChannelSearchDelegate();
  Null Function()? tabListener;

  @override
  void initState() {
    super.initState();
    final settingsProvider = context.read<SettingsProvider>();
    if (!settingsProvider.hasConsent) {
      settingsProvider.updateConsent();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChannelProvider>().getChannels();
    });
  }

  @override
  Widget build(BuildContext context) {
    final channels = context.select((ChannelProvider value) => value.channels);
    final loading = context.select((ChannelProvider value) => value.loading);
    final allChannels = context.select((ChannelProvider value) => value.allChannels);
    final allCategories = context.select((ChannelProvider value) => value.allCategories);
    final category = context.select((ChannelProvider value) => value.category);
    final country = context.select((ChannelProvider value) => value.country);
    final currentUrl = context.select((ChannelProvider value) => value.currentUrl);
    return GlobalLoadingWidget(
      child: OrientationBuilder(
        builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return DefaultTabController(
              length: allCategories.length,
              initialIndex: allCategories.indexOf(category),
              child: Scaffold(
                appBar: AppBar(
                  leading: Image.asset('assets/images/ic_banner.png', width: 120, height: 60,),
                  leadingWidth: 120,
                  actions: [
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const CountryPage()));
                        },
                        icon: Builder(
                            builder: (context) {
                              Widget icon;
                              if (country == 'all') {
                                icon = const Icon(Icons.language);
                              } else if (country == 'uncategorized') {
                                icon = const Icon(Icons.question_mark);
                              } else {
                                icon = Image.asset('assets/images/flags/${country.toLowerCase()}.png', height: 24,);
                              }
                              return icon;
                            }
                        )
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        showSearch(
                          context: context,
                          delegate: delegate,
                        );
                      },
                    ),
                    IconButton(
                        onPressed: () {
                          Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => const SettingsPage()));
                        },
                        icon: const Icon(Icons.settings,)
                    ),
                  ],
                  bottom: TabBar(
                    isScrollable:true,
                    tabs: allCategories.map((e) => Tab(text: e.toUpperCase(),)).toList(),
                  ),
                ),
                body: Builder(
                  builder: (context) {
                    final tabController = DefaultTabController.of(context);
                    if (tabListener != null) {
                      tabController.removeListener(tabListener!);
                    }
                    tabListener = () {
                      if(tabController.indexIsChanging) {
                        context
                            .read<ChannelProvider>()
                            .selectCategory(category: allCategories[tabController.index]);
                        scrollController.jumpTo(0);
                      }
                    };
                     tabController.addListener(tabListener!);
                    return Column(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (currentUrl == null || currentUrl.isEmpty) {
                                return Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(horizontal: 30),
                                    child: Column(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Text('Unitv is an IPTV player and does not provide video content. You can select a playlist from the integrated list or import your own.',textAlign: TextAlign.center,),
                                        const SizedBox(height: 20,),
                                        FilledButton(
                                          onPressed: () {
                                            Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectM3u8Page()));
                                          },
                                          child: const Text('Select M3U Playlist'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              } else if (!loading && allChannels.isEmpty) {
                                return Center(
                                  child: FilledButton(
                                    onPressed: () {
                                      context.read<ChannelProvider>().getChannels();
                                    },
                                    child: const Text('Try Again'),
                                  ),
                                );
                              } else {
                                return Scrollbar(
                                  child: GridView.builder(
                                    padding: const EdgeInsets.only(top: 10),
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
                                        crossAxisCount: 3,
                                        childAspectRatio: 1.2),
                                  ),
                                );
                              }
                            }
                          ),
                        ),
                      ],
                    );
                  }
                ), // This trailing comma makes auto-formatting nicer for build methods.
              ),
            );
          }
          return Scaffold(
            appBar: AppBar(
              leading: Image.asset('assets/images/ic_banner.png', width: 120, height: 60,),
              leadingWidth: 120,
              actions: [
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CountryPage()));
                    },
                    icon: Builder(
                        builder: (context) {
                          Widget icon;
                          if (country == 'all') {
                            icon = const Icon(Icons.language);
                          } else if (country == 'uncategorized') {
                            icon = const Icon(Icons.question_mark);
                          } else {
                            icon = Image.asset('assets/images/flags/${country.toLowerCase()}.png', height: 24,);
                          }
                          return icon;
                        }
                    )
                ),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () {
                    showSearch(
                      context: context,
                      delegate: delegate,
                    );
                  },
                ),
                IconButton(
                    onPressed: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SettingsPage()));
                    },
                    icon: const Icon(Icons.settings,)
                ),
              ],
            ),
            body: Row(
              children: [
                SizedBox(
                  width: 180,
                  height: double.infinity,
                  child: ListView.builder(
                    itemBuilder: (_, index) {
                      final item = allCategories[index];
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
                    itemCount: allCategories.length,
                  ),
                ),
                Expanded(
                  child: Builder(
                    builder: (context) {
                      if (currentUrl == null || currentUrl.isEmpty) {
                        return Center(
                          child:  Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 80),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Text('Unitv is an IPTV player and does not provide video content. You can select a playlist from the integrated list or import your own.', textAlign: TextAlign.center,),
                                const SizedBox(height: 20,),
                                FilledButton(
                                  onPressed: () {
                                    Navigator.push(context, MaterialPageRoute(builder: (_) => const SelectM3u8Page()));
                                  },
                                  child: const Text('Select M3U Playlist'),
                                ),
                              ],
                            ),
                          ),
                        );
                      } else if (!loading && allChannels.isEmpty) {
                        return Center(
                          child: FilledButton(
                            onPressed: () {
                              context.read<ChannelProvider>().getChannels();
                            },
                            child: const Text('Try Again'),
                          ),
                        );
                      } else {
                        return Scrollbar(
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
                        );
                      }
                    }
                  ),
                ),
              ],
            ), // This trailing comma makes auto-formatting nicer for build methods.
          );
        }
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    scrollController.dispose();
  }
}
