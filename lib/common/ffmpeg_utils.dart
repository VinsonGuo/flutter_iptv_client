import 'package:ffmpeg_kit_flutter/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter/return_code.dart';
import 'package:flutter_iptv_client/common/logger.dart';

Future<bool> isM3U8Playable(String m3u8Url) async {
  try {
    // 构建 ffprobe 命令来检查 m3u8 文件
    final command = 'ffprobe -i $m3u8Url v:0';

    // 执行命令
    final session = await FFmpegKit.execute(command);
    final returnCode = await session.getReturnCode();

    if (ReturnCode.isSuccess(returnCode)) {
      // 成功执行，检查输出信息
      final output = await session.getOutput();
      if (output != null && output.contains('Stream')) {
        // 如果包含 "Stream"，说明 m3u8 中存在视频流
        return true;
      }
    } else {
      // 如果执行失败，m3u8 文件不可用
      final error = await session.getOutput();
      logger.e('FFprobe error: $error');
    }
  } catch (e) {
    logger.e('Error checking m3u8: $e');
  }

  return false;
}
