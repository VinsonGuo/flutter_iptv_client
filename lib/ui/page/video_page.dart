import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:provider/provider.dart';
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
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    final channel = context.read<ChannelProvider>().currentChannel!;
    logger.i('video url is ${channel.url}');
    isFavorite = channel.isFavorite;
  }

  @override
  Widget build(BuildContext context) {
    final channel =
        context.select((ChannelProvider value) => value.currentChannel)!;
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
    return Scaffold(
      appBar: AppBar(
        title: Text(channel.name),
        actions: [
          IconButton(
              focusColor: Colors.grey,
              onPressed: () {
                context
                    .read<ChannelProvider>()
                    .setFavorite(channel.id, !isFavorite);
                setState(() {
                  isFavorite = !isFavorite;
                });
              },
              icon: Icon(
                isFavorite ? Icons.star : Icons.star_border,
                size: 24,
              ))
        ],
      ),
      body: SingleChildScrollView(
        child: Row(
          children: [
            SizedBox(
              width: 20,
            ),
            Column(
              children: [
                SizedBox(
                  height: 160,
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Chewie(
                      controller: chewieController!,
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Row(
                  children: [
                    FilledButton(
                        onPressed: () {
                          context.read<ChannelProvider>().previousChannel();
                        },
                        child: Row(
                          children: [
                            Icon(Icons.skip_previous),
                            Text('Prev'),
                          ],
                        )),
                    SizedBox(
                      width: 20,
                    ),
                    FilledButton(
                        onPressed: () {
                          context.read<ChannelProvider>().nextChannel();
                        },
                        child: Row(
                          children: [
                            Text('Next'),
                            Icon(Icons.skip_next),
                          ],
                        )),
                  ],
                )
              ],
            ),
            SizedBox(
              width: 20,
            ),
            Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(channel.name),
                Text('Country:\t'+ (channel.country ?? 'Unknown')),
                Text('Website:\t'+ (channel.website ?? 'Unknown')),
                Text('Language:\t'+ channel.languages.join(',')),
                Text('Category:\t'+ channel.categories.join(',')),
                UnconstrainedBox(
                  child: FilledButton(
                      autofocus: true,
                      onPressed: () {
                        chewieController?.enterFullScreen();
                      },
                      child: Row(
                        children: [
                          Icon(Icons.fullscreen),
                          Text('FullScreen'),
                        ],
                      )),
                )
              ],
            ))
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController?.dispose();
    chewieController?.dispose();
    context.read<ChannelProvider>().setCurrentChannel(null);
  }
}
