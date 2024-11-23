import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';

import '../../provider/channel_provider.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key, required this.channel});

  final Channel channel;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late ChewieController chewieController;
  late VideoPlayerController videoPlayerController;
  late bool isFavorite;

  @override
  void initState() {
    super.initState();
    logger.i('video url is ${widget.channel.url}');
    isFavorite = widget.channel.isFavorite;
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.channel.url ?? ''));
    chewieController = ChewieController(
        aspectRatio: 16 / 9,
        videoPlayerController: videoPlayerController,
        autoInitialize: true,
        autoPlay: true,
        showControlsOnInitialize: false,
        isLive: true,
        allowedScreenSleep: false,
        deviceOrientationsAfterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        deviceOrientationsOnEnterFullScreen: [
          DeviceOrientation.landscapeLeft,
          DeviceOrientation.landscapeRight
        ],
        errorBuilder: (_, msg) => Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error,
                  size: 24,
                ),
                SizedBox(
                  height: 6,
                ),
                Text(msg),
              ],
            ),
        placeholder: const Center(child: CircularProgressIndicator()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.channel.name),
        actions: [
          IconButton(
              focusColor: Colors.grey,
              onPressed: () {
                context
                    .read<ChannelProvider>()
                    .setFavorite(widget.channel.id, !isFavorite);
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
      body: Row(
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: Chewie(
              controller: chewieController,
            ),
          ),
          Expanded(
              child: SingleChildScrollView(
            child: Column(
              children: [
                FilledButton(
                    autofocus: true,
                    onPressed: () {
                      chewieController.enterFullScreen();
                    },
                    child: Row(
                      children: [
                        Icon(Icons.fullscreen),
                        Text('FullScreen'),
                      ],
                    ))
              ],
            ),
          ))
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    videoPlayerController.dispose();
    chewieController.dispose();
  }
}
