import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/logger.dart';

class M3U8Thumbnail extends StatefulWidget {
  final Channel channel;

  const M3U8Thumbnail({super.key, required this.channel});

  @override
  _M3U8ThumbnailState createState() => _M3U8ThumbnailState();
}

class _M3U8ThumbnailState extends State<M3U8Thumbnail> {
  String? _thumbnailPath;
  Session? session;

  @override
  void initState() {
    super.initState();
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    if (!mounted) {
      return;
    }
    logger.i('generateThumbnail for ${widget.channel.url}');
    try {
      // 获取临时目录
      final tempDir = await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/${widget.channel.name}.jpg';
      final file = File(outputPath);
      bool needFetch = true;
      if (await file.exists()) {
        final lastModified = await file.lastModified();
        final isEmpty = (await file.length()) == 0;
        needFetch = isEmpty ||
            lastModified
                .isBefore(DateTime.now().subtract(const Duration(hours: 1)));
      } else {
        await file.create(recursive: true);
      }

      if (needFetch) {
        // 使用 FFmpeg 提取第一帧
        // -y -i "${widget.m3u8Url}" -s 800x450 -vframes 1 -f image2 -updatefirst 1 "$outputPath"
        session = await FFmpegKit.execute(
            '-i "${widget.channel.url}" -frames:v 1 -q:v 30 -y "$outputPath"');
      }

      if (mounted) {
        setState(() {
          _thumbnailPath = outputPath;
        });
      }
    } catch (e, s) {
      logger.e('ffmpeg error: $e', error: e, stackTrace: s);
    }
  }

  @override
  Widget build(BuildContext context) {
    final placeholder =  CachedNetworkImage(
      width: double.infinity,
      height: double.infinity,
      imageUrl: widget.channel.logo ?? '',
      errorWidget: (_, __, ___) => const Icon(Icons.error, size: 24,),
    );
    return _thumbnailPath != null
        ? Image.file(
            File(_thumbnailPath!),
            errorBuilder: (_, __, ___) => placeholder) // 显示生成的缩略图
        : placeholder; // 显示加载进度
  }

  @override
  void dispose() {
    super.dispose();
    session?.cancel();
  }
}
