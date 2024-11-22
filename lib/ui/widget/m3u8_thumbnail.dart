import 'dart:io';

import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:ffmpeg_kit_flutter/session.dart';
import 'package:flutter/material.dart';
import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:path_provider/path_provider.dart';

import '../../common/logger.dart';

class M3U8Thumbnail extends StatefulWidget {
  final String m3u8Url;
  final String title;

  const M3U8Thumbnail({super.key, required this.title, required this.m3u8Url});

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
    logger.i('generateThumbnail for ${widget.m3u8Url}');
    try {
      // 获取临时目录
      final tempDir = Platform.isAndroid
          ? (await getExternalStorageDirectory())!
          : await getTemporaryDirectory();
      final outputPath = '${tempDir.path}/${widget.title}.jpg';
      final file = File(outputPath);
      bool needFetch = true;
      if (await file.exists()) {
        final lastModified = await file.lastModified();
        final isEmpty = (await file.length()) == 0;
        needFetch = isEmpty ||
            lastModified
                .isBefore(DateTime.now().subtract(const Duration(days: 1)));
      } else {
        await file.create(recursive: true);
      }

      if (needFetch) {
        // 使用 FFmpeg 提取第一帧
        // -y -i "${widget.m3u8Url}" -s 800x450 -vframes 1 -f image2 -updatefirst 1 "$outputPath"
        session = await FFmpegKit.execute(
            '-i "${widget.m3u8Url}" -frames:v 1 -q:v 30 -y "$outputPath"');
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
    return _thumbnailPath != null
        ? Image.file(
            File(_thumbnailPath!),
            errorBuilder: (_, __, ___) => Center(
              child: Icon(Icons.error),
            ),
          ) // 显示生成的缩略图
        : const Center(child: CircularProgressIndicator()); // 显示加载进度
  }

  @override
  void dispose() {
    super.dispose();
    session?.cancel();
  }
}
