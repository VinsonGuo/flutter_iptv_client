import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../../provider/channel_provider.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;
  ItemScrollController scrollController = ItemScrollController();
  bool isFullscreen = false;
  bool showFullscreenInfo = false;
  String? lastUrl;

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
      videoPlayerController?.dispose();
      chewieController?.dispose();
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(channel.url ?? ''),
          httpHeaders: {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/92.0.4515.131 Safari/537.36'});
      chewieController = ChewieController(
          aspectRatio: 16 / 9,
          videoPlayerController: videoPlayerController!,
          autoInitialize: true,
          autoPlay: true,
          showControlsOnInitialize: false,
          isLive: true,
          showControls: true,
          allowFullScreen: false,
          fullScreenByDefault: false,
          showOptions: false,
          allowedScreenSleep: false,
          allowPlaybackSpeedChanging: false,
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          deviceOrientationsOnEnterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          errorBuilder: (_, msg) => Container(
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
              ),
          placeholder: Center(child: LoadingAnimationWidget.beat(
            color: Theme.of(context).colorScheme.primary,
            size: 60,
          )),
        bufferingBuilder: (_) => Center(child: LoadingAnimationWidget.beat(
          color: Theme.of(context).colorScheme.primary,
          size: 60,
        )),
      );
      setState(() {
        showFullscreenInfo = true;
      });
      Future.delayed(const Duration(seconds: 5)).then((value) {
        if (mounted && channel.url == lastUrl) {
          setState(() {
            showFullscreenInfo = false;
          });
        }
      });

      final index = channels.indexOf(channel);
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (index >= 0 && scrollController.isAttached) {
          scrollController.scrollTo(
              index: index, duration: const Duration(milliseconds: 200));
        }
      });
    }
    lastUrl = channel.url;

    final chewie = Chewie(
      controller: chewieController!,
    );

    if (isFullscreen) {
      return PopScope(
        canPop: !isFullscreen,
        onPopInvoked: (didPop) {
          if (didPop) {
            return;
          }
          if (isFullscreen) {
            setState(() {
              isFullscreen = false;
            });
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            SystemChrome.setPreferredOrientations(DeviceOrientation.values);
          }
        },
        child: GestureDetector(
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
                  chewie,
                  Visibility(
                    visible: showFullscreenInfo,
                    child: Align(
                      alignment: const Alignment(0, 0.9),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
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
                          const SizedBox(width: 10,),
                          Text(channel.name),
                          const SizedBox(width: 10,),
                          Image.asset(
                            'assets/images/flags/${channel.country?.toLowerCase()}.png',
                            height: 12,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                          const SizedBox(
                            width: 4,
                          ),
                          Text('${channel.country ?? ''}\t${channel.languages.join(',')}'),
                        ],
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
        appBar: AppBar(
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
            title: Text(channel.name, overflow: TextOverflow.ellipsis,),
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
                Text('${channel.country ?? ''}\t${channel.languages.join(',')}'),
              ],
            ),
          ),
        ),
        body: OrientationBuilder(builder: (context, orientation) {
          if (orientation == Orientation.portrait) {
            return portraitPage(provider, chewie, channels, channel);
          }
          return landscapePage(provider, chewie, channels, channel);
        }),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
    WakelockPlus.disable();
    videoPlayerController?.dispose();
    chewieController?.dispose();
  }

  Widget landscapePage(ChannelProvider provider, Widget chewie,
      List<Channel> channels, Channel channel) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(
          width: 20,
        ),
        Column(
          children: [
            Expanded(
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: chewie,
              ),
            ),
            const SizedBox(
              height: 6,
            ),
            Row(
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
                      setState(() {
                        isFullscreen = true;
                      });
                      SystemChrome.setEnabledSystemUIMode(
                          SystemUiMode.immersive);
                      SystemChrome.setPreferredOrientations([
                        DeviceOrientation.landscapeLeft,
                        DeviceOrientation.landscapeRight,
                      ]);
                    },
                    child: const Icon(Icons.fullscreen))
              ],
            ),
          ],
        ),
        const SizedBox(
          width: 20,
        ),
        Expanded(
          child: ScrollablePositionedList.builder(
            itemScrollController: scrollController,
            itemBuilder: (_, index) {
              final item = channels[index];
              return ListTile(
                dense: true,
                horizontalTitleGap: 4,
                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
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
                    Text('${item.country ?? ''}\t${item.languages.join(',')}'),
                  ],
                ),
              );
            },
            itemCount: channels.length,
          ),
        ),
        const SizedBox(
          width: 20,
        ),
      ],
    );
  }

  Widget portraitPage(ChannelProvider provider, Widget chewie,
          List<Channel> channels, Channel channel) =>
      Column(
        children: [
          Container(
            color: Theme.of(context).colorScheme.surface,
            child: Column(
              children: [
                const SizedBox(
                  width: 20,
                ),
                AspectRatio(
                  aspectRatio: 16 / 9,
                  child: chewie,
                ),
                const SizedBox(
                  height: 10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    FilledButton(
                        onPressed: () {
                          provider.setFavorite(channel.id, !channel.isFavorite);
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
                          setState(() {
                            isFullscreen = true;
                          });
                          SystemChrome.setEnabledSystemUIMode(
                              SystemUiMode.immersive);
                          SystemChrome.setPreferredOrientations([
                            DeviceOrientation.landscapeLeft,
                            DeviceOrientation.landscapeRight,
                          ]);
                        },
                        child: const Icon(Icons.fullscreen))
                  ],
                ),
                const SizedBox(height: 10,),
              ],
            ),
          ),
          Expanded(
            child: ScrollablePositionedList.builder(
              itemScrollController: scrollController,
              itemBuilder: (_, index) {
                final item = channels[index];
                return ListTile(
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
                      Text('${item.country ?? ''}\t${item.languages.join(',')}'),
                    ],
                  ),
                );
              },
              itemCount: channels.length,
            ),
          ),
        ],
      );
}
