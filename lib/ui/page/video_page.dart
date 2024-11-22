import 'package:chewie/chewie.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key, required this.channel});

  final Channel channel;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late ChewieController chewieController;
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    logger.i('video url is ${widget.channel.url}');
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.channel.url ?? ''));
    chewieController = ChewieController(
        aspectRatio: 16 / 9,
        videoPlayerController: videoPlayerController,
        autoInitialize: true,
        autoPlay: true,
        showControlsOnInitialize: false,
        isLive: true,
        deviceOrientationsAfterFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
        deviceOrientationsOnEnterFullScreen: [DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight],
        errorBuilder: (_, msg) => Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error,
              size: 24,
            ),
            SizedBox(height: 6,),
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
      ),
      body: Row(
        children: [
          AspectRatio(
            aspectRatio: 16/9,
            child: Chewie(
              controller: chewieController,
            ),
          ),
          Expanded(child: SingleChildScrollView(child: Table(
            defaultColumnWidth: FlexColumnWidth(0.5),
            border: TableBorder.all(color:Theme.of(context).colorScheme.secondaryContainer),
            children: [
              TableRow(
                children: [
                  Text('Category'),
                  Text(widget.channel.categories.join(', ')),
                ]
              ),
              TableRow(
                  children: [
                    Text('Language'),
                    Text(widget.channel.languages.join(', ')),
                  ]
              ),
              TableRow(
                  children: [
                    Text('WebSite'),
                    Text(widget.channel.website ?? ''),
                  ]
              ),
            ],
          ),))
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
