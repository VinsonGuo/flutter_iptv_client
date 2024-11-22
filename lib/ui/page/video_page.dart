import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoPage extends StatefulWidget {
  const VideoPage({super.key, required this.url});

  final String url;

  @override
  State<VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  late ChewieController chewieController;
  late VideoPlayerController videoPlayerController;

  @override
  void initState() {
    super.initState();
    videoPlayerController =
        VideoPlayerController.networkUrl(Uri.parse(widget.url));
    chewieController = ChewieController(
        aspectRatio: 16 / 9,
        videoPlayerController: videoPlayerController,
        autoInitialize: true,
        autoPlay: true,
        showControlsOnInitialize: false,
        isLive: true,
        placeholder: const Center(child: CircularProgressIndicator()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Chewie(
        controller: chewieController,
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
