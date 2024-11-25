import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:video_player/video_player.dart';

import '../../provider/channel_provider.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key});

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  ChewieController? chewieController;
  VideoPlayerController? videoPlayerController;
  bool isFullscreen = false;
  bool showFullscreenInfo = false;
  String? lastUrl;

  @override
  Widget build(BuildContext context) {
    final channel =
        context.select((ChannelProvider value) => value.currentChannel)!;
    final desc = context.select((ChannelProvider value) => value.currentDescription);
    logger.i('video url is ${channel.url}');
    if (lastUrl != channel.url) {
      videoPlayerController?.dispose();
      chewieController?.dispose();
      videoPlayerController =
          VideoPlayerController.networkUrl(Uri.parse(channel.url ?? ''));
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
          deviceOrientationsAfterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          deviceOrientationsOnEnterFullScreen: [
            DeviceOrientation.landscapeLeft,
            DeviceOrientation.landscapeRight
          ],
          errorBuilder: (_, msg) => Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error,
                      size: 24,
                    ),
                    const SizedBox(
                      height: 6,
                    ),
                    Text(msg),
                  ],
                ),
              ),
          placeholder: const Center(child: CircularProgressIndicator()));
      setState(() {
        showFullscreenInfo = true;
      });
      Future.delayed(const Duration(seconds: 5), ).then((value) {
        if (mounted) {
          setState(() {
            showFullscreenInfo = false;
          });
        }
      });
    }
    lastUrl = channel.url;

    final chewie = Chewie(
      controller: chewieController!,
    );
    return isFullscreen
        ? PopScope(
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
              }
            },
            child: KeyboardListener(
              focusNode: FocusNode(),
              onKeyEvent: (event) {
                final key = event.logicalKey;
                if (key == LogicalKeyboardKey.arrowUp) {
                  context.read<ChannelProvider>().previousChannel();
                } else if (key == LogicalKeyboardKey.arrowDown) {
                  context.read<ChannelProvider>().nextChannel();
                }
              },
              child: Scaffold(
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
                              errorWidget: (_, __, ___) => const Icon(
                                Icons.error,
                                size: 24,
                              ),
                            ),
                            Text(channel.name),
                          ],
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
          )
        : Scaffold(
            appBar: AppBar(
              title: Row(
                children: [
                  CachedNetworkImage(
                    width: 60,
                    height: 40,
                    imageUrl: channel.logo ?? '',
                    errorWidget: (_, __, ___) => const Icon(
                      Icons.error,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10,),
                  Text(channel.name),
                ],
              ),
              actions: [
                IconButton(
                    focusColor: Colors.grey,
                    onPressed: () {
                      context
                          .read<ChannelProvider>()
                          .setFavorite(channel.id, !channel.isFavorite);
                    },
                    icon: Icon(
                      channel.isFavorite ? Icons.star : Icons.star_border,
                      size: 24,
                    ))
              ],
            ),
            body: Row(
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
                      height: 10,
                    ),
                    Row(
                      children: [
                        FilledButton(
                            onPressed: () {
                              if (channel.website != null) {
                                launchUrl(Uri.parse(channel.website!));
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Could not open the URL.')),
                                );
                              }
                            },
                            child: const Row(
                              children: [
                                Icon(Icons.web),
                              ],
                            )),
                        const SizedBox(
                          width: 10,
                        ),
                        FilledButton(
                            onPressed: () {
                              context
                                  .read<ChannelProvider>()
                                  .previousChannel();
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
                              context.read<ChannelProvider>().nextChannel();
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
                              SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
                            },
                            child: const Icon(Icons.fullscreen))
                      ],
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                  ],
                ),
                const SizedBox(
                  width: 20,
                ),
                Expanded(
                  child: ListView(
                      children: [
                        Text('Channel Description from Gemini✨',style: Theme.of(context).textTheme.titleMedium,),
                        const SizedBox(height: 10,),
                        Visibility(
                            visible: desc != null,
                            replacement: const LinearProgressIndicator(),
                            child: MarkdownBody(data: desc ?? '')),
                      ],
                  )),
                const SizedBox(
                  width: 20,
                ),
              ],
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController?.dispose();
    chewieController?.dispose();
  }
}
