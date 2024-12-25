import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../provider/channel_provider.dart';
import '../widget/admob_widget.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? videoPlayerController;
  ItemScrollController scrollController = ItemScrollController();
  bool isFullscreen = false;
  bool showFullscreenInfo = false;
  String? lastUrl;
  Timer? fullscreenInfoDismissTimer;
  int index = 0;
  bool isBuffering = false;
  bool isError = false;

  @override
  void initState() {
    super.initState();
    WakelockPlus.enable();
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.read<ChannelProvider>();
    final channel =
        context.select((ChannelProvider value) => value.currentChannel)!;
    final channels = context.select((ChannelProvider value) => value.channels);
    logger.i('video url is ${channel.url}');
    if (lastUrl != channel.url) {
      setState(() {
        isBuffering = true;
        isError = false;
      });
      videoPlayerController?.dispose();
      videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(channel.url ?? ''),
          httpHeaders: {
            'User-Agent':
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36'
          })
        ..initialize().then((value) {
          setState(() {
            isBuffering = false;
            isError = false;
          });
        }).catchError((e) {
          setState(() {
            isBuffering = false;
            isError = true;
          });
        });
      videoPlayerController?.play();
      _showFullscreenInfo(channel);

      index = channels.indexOf(channel);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (index >= 0 && scrollController.isAttached) {
          scrollController.scrollTo(
              index: index, duration: const Duration(milliseconds: 200));
        }
      });
    }
    lastUrl = channel.url;
    final videoPlayer = AspectRatio(
        aspectRatio: videoPlayerController!.value.isInitialized
            ? videoPlayerController!.value.aspectRatio
            : 16 / 9,
        child: Container(
          color: Colors.black,
          child: Stack(
            children: [
              VideoPlayer(videoPlayerController!,),
              if (isBuffering)
                Center(
                    child: LoadingAnimationWidget.beat(
                  color: Theme.of(context).colorScheme.primary,
                  size: 60,
                ))
              else if (isError)
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.center,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error,
                        size: 24,
                      ),
                      SizedBox(
                        height: 6,
                      ),
                      Text(
                          "The selected channel is currently not available. This might be due to a temporary issue or Geo-blocked. Please try refreshing the page or importing a valid custom playlist URL."),
                    ],
                  ),
                )
            ],
          ),
        ));

    if (isFullscreen) {
      return PopScope(
        canPop: !isFullscreen,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          exitFullscreen();
        },
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () {
            _showFullscreenInfo(channel);
          },
          onHorizontalDragEnd: (details) {
            if ((details.primaryVelocity ?? 0) > 10) {
              provider.previousChannel();
            } else if ((details.primaryVelocity ?? 0) < -10) {
              provider.nextChannel();
            }
          },
          child: KeyboardListener(
            focusNode: FocusNode(),
            onKeyEvent: (event) {
              final key = event.logicalKey;
              if (key == LogicalKeyboardKey.arrowUp) {
                provider.previousChannel();
              } else if (key == LogicalKeyboardKey.arrowDown) {
                provider.nextChannel();
              }
            },
            child: Scaffold(
              backgroundColor: Colors.black,
              body: Stack(
                children: [
                  Align(alignment: Alignment.center, child: videoPlayer),
                  AnimatedOpacity(
                    opacity: showFullscreenInfo ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Align(
                      alignment: const Alignment(-0.95, -0.8),
                      child: InkWell(
                          canRequestFocus: false,
                          onTap: () {
                            exitFullscreen();
                          },
                          child: const Icon(Icons.arrow_back_outlined)),
                    ),
                  ),
                  AnimatedOpacity(
                    opacity: showFullscreenInfo ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Align(
                      alignment: const Alignment(0, 0.9),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CachedNetworkImage(
                              width: 60,
                              height: 40,
                              imageUrl: channel.logo ?? '',
                              errorWidget: (_, __, ___) => Icon(
                                Icons.tv,
                                size: 24,
                                color: Theme.of(context).colorScheme.onPrimary,
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(channel.name),
                            const SizedBox(
                              width: 10,
                            ),
                            Image.asset(
                              'assets/images/flags/${channel.country?.toLowerCase()}.png',
                              height: 12,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                                '${channel.country ?? ''}\t${channel.languages.join(',')}'),
                          ],
                        ),
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
      );
    } else {
      return Scaffold(
        appBar: MediaQuery.of(context).orientation == Orientation.portrait
            ? AppBar(
                title: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                  leading: CachedNetworkImage(
                    width: 40,
                    height: 25,
                    imageUrl: channel.logo ?? '',
                    errorWidget: (_, __, ___) => Icon(
                      Icons.tv,
                      size: 24,
                      color: Theme.of(context).colorScheme.primaryContainer,
                    ),
                  ),
                  title: Text(
                    channel.name,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Row(
                    children: [
                      Image.asset(
                        'assets/images/flags/${channel.country?.toLowerCase()}.png',
                        height: 12,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(
                          '${channel.country ?? ''}\t${channel.languages.join(',')}'),
                    ],
                  ),
                ),
              )
            : null,
        body: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return portraitPage(provider, videoPlayer, channels, channel);
          }
          return landscapePage(provider, videoPlayer, channels, channel);
        }),
      );
    }
  }

  void exitFullscreen() {
    if (isFullscreen) {
      setState(() {
        isFullscreen = false;
      });
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (index >= 0 && scrollController.isAttached) {
          scrollController.scrollTo(
              index: index, duration: const Duration(milliseconds: 200));
        }
      });
    }
  }

  void _showFullscreenInfo(Channel channel) {
    setState(() {
      showFullscreenInfo = true;
    });
    fullscreenInfoDismissTimer?.cancel();
    fullscreenInfoDismissTimer = Timer(const Duration(seconds: 5), () {
      setState(() {
        showFullscreenInfo = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
    videoPlayerController?.dispose();
    fullscreenInfoDismissTimer?.cancel();
  }

  Widget landscapePage(ChannelProvider provider, Widget videoPlayer,
      List<Channel> channels, Channel channel) {
    return SafeArea(
      child: Row(
        children: [
          Expanded(
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      width: 16,
                    ),
                    IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.arrow_back_outlined)),
                    CachedNetworkImage(
                      width: 40,
                      height: 25,
                      imageUrl: channel.logo ?? '',
                      errorWidget: (_, __, ___) => Icon(
                        Icons.tv,
                        size: 24,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    const SizedBox(
                      width: 4,
                    ),
                    Expanded(
                        child: Text(
                      channel.name,
                      style: Theme.of(context).textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    )),
                  ],
                ),
                // videoPlayer,
                Expanded(
                  child: Center(child: videoPlayer),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    FilledButton(
                        onPressed: () {
                          provider.setFavorite(channel.id, !channel.isFavorite);
                        },
                        child: Icon(
                          channel.isFavorite ? Icons.star : Icons.star_border,
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    FilledButton(
                        onPressed: () {
                          provider.previousChannel();
                        },
                        child: const Row(
                          children: [
                            Icon(Icons.skip_previous),
                            Text('Prev'),
                          ],
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    FilledButton(
                        onPressed: () {
                          provider.nextChannel();
                        },
                        child: const Row(
                          children: [
                            Text('Next'),
                            Icon(Icons.skip_next),
                          ],
                        )),
                    const SizedBox(
                      width: 10,
                    ),
                    FilledButton(
                        autofocus: true,
                        onPressed: () {
                          enterFullscreen();
                        },
                        child: const Icon(Icons.fullscreen))
                  ],
                ),
                const SizedBox(
                  height: 6,
                ),
              ],
            ),
          ),
          const SizedBox(
            width: 6,
          ),
          SizedBox(
            width: 280,
            child: Column(
              children: [
                const AdMobNativeWidget(),
                Expanded(
                  child: ScrollablePositionedList.builder(
                    itemScrollController: scrollController,
                    itemBuilder: (_, index) {
                      final item = channels[index];
                      return ListTile(
                        dense: true,
                        horizontalTitleGap: 4,
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 8),
                        selected: item.id == channel.id,
                        selectedTileColor:
                            Theme.of(context).colorScheme.onPrimary,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        onTap: () {
                          provider.setCurrentChannel(item);
                        },
                        leading: CachedNetworkImage(
                          width: 40,
                          height: 25,
                          imageUrl: item.logo ?? '',
                          errorWidget: (_, __, ___) => Icon(
                            Icons.tv,
                            size: 24,
                            color:
                                Theme.of(context).colorScheme.primaryContainer,
                          ),
                        ),
                        title: Text(item.name),
                        subtitle: Row(
                          children: [
                            Image.asset(
                              'assets/images/flags/${item.country?.toLowerCase()}.png',
                              height: 12,
                              errorBuilder: (_, __, ___) =>
                                  const SizedBox.shrink(),
                            ),
                            const SizedBox(
                              width: 4,
                            ),
                            Text(
                                '${item.country ?? ''}\t${item.languages.join(',')}'),
                          ],
                        ),
                      );
                    },
                    itemCount: channels.length,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget portraitPage(ChannelProvider provider, Widget videoPlayer,
          List<Channel> channels, Channel channel) =>
      SafeArea(
        top: false,
        bottom: true,
        child: Column(
          children: [
            Container(
              color: Theme.of(context).colorScheme.surface,
              child: Column(
                children: [
                  const SizedBox(
                    width: 20,
                  ),
                  videoPlayer,
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      FilledButton(
                          onPressed: () {
                            provider.setFavorite(
                                channel.id, !channel.isFavorite);
                          },
                          child: Icon(
                            channel.isFavorite ? Icons.star : Icons.star_border,
                          )),
                      FilledButton(
                          onPressed: () {
                            provider.previousChannel();
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.skip_previous),
                            ],
                          )),
                      FilledButton(
                          onPressed: () {
                            provider.nextChannel();
                          },
                          child: const Row(
                            children: [
                              Icon(Icons.skip_next),
                            ],
                          )),
                      FilledButton(
                          autofocus: true,
                          onPressed: () {
                            enterFullscreen();
                          },
                          child: const Icon(Icons.fullscreen))
                    ],
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ScrollablePositionedList.builder(
                itemScrollController: scrollController,
                itemBuilder: (_, index) {
                  final item = channels[index];
                  return ListTile(
                    dense: true,
                    selected: item.id == channel.id,
                    selectedTileColor: Theme.of(context).colorScheme.onPrimary,
                    selectedColor: Theme.of(context).colorScheme.primary,
                    onTap: () {
                      provider.setCurrentChannel(item);
                    },
                    leading: CachedNetworkImage(
                      width: 40,
                      height: 25,
                      imageUrl: item.logo ?? '',
                      errorWidget: (_, __, ___) => Icon(
                        Icons.tv,
                        size: 24,
                        color: Theme.of(context).colorScheme.primaryContainer,
                      ),
                    ),
                    title: Text(item.name),
                    subtitle: Row(
                      children: [
                        Image.asset(
                          'assets/images/flags/${item.country?.toLowerCase()}.png',
                          height: 12,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                        const SizedBox(
                          width: 4,
                        ),
                        Text(
                            '${item.country ?? ''}\t${item.languages.join(',')}'),
                      ],
                    ),
                  );
                },
                itemCount: channels.length,
              ),
            ),
          ],
        ),
      );

  void enterFullscreen() {
    setState(() {
      isFullscreen = true;
    });
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
  }
}
