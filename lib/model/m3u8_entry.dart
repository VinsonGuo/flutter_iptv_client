import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/model/channel.dart';

class M3U8Entry {
  final String tvgId;
  final String tvgLogo;
  final String groupTitle;
  final String title;
  final String url;
  final String? httpUserAgent;
  final String? httpReferer;

  M3U8Entry({
    required this.tvgId,
    required this.tvgLogo,
    required this.groupTitle,
    required this.title,
    required this.url,
    required this.httpUserAgent,
    required this.httpReferer,
  });

  @override
  String toString() {
    return '''
Title: $title
tvg-id: $tvgId
tvg-logo: $tvgLogo
group-title: $groupTitle
URL: $url
httpUserAgent: $httpUserAgent
httpReferer: $httpReferer
''';
  }

  Channel toChannel() => Channel(
        id: tvgId.isEmpty ? title : tvgId,
        name: title,
        logo: tvgLogo,
        url: url,
        categories: [groupTitle.toLowerCase()],
        languages: [],
        country: 'uncategorized',
        website: '',
        isFavorite: false,
        httpUserAgent: httpUserAgent,
        httpUserReferer: httpReferer,
      );
}

List<M3U8Entry> parseM3U8(String content) {
  final lines = content.split('\n');
  final entries = <M3U8Entry>[];

  String? currentTvgId;
  String? currentTvgLogo;
  String? currentGroupTitle;
  String? currentTitle;
  String? httpUserAgent;
  String? httpReferer;

  for (var line in lines) {
    try {
      if (line.startsWith('#EXTINF:')) {
        final attributes = RegExp(r'([\w-]+)(?:="([^"]*)")?')
            .allMatches(line)
            .map((match) => MapEntry(match.group(1)!, match.group(2) ?? ''))
            .toList();
        currentTvgId = attributes
            .firstWhere((attr) => attr.key == 'tvg-id',
                orElse: () => const MapEntry('', ''))
            .value;
        currentTvgLogo = attributes
            .firstWhere((attr) => attr.key == 'tvg-logo',
                orElse: () => const MapEntry('', ''))
            .value;
        currentGroupTitle = attributes
            .firstWhere((attr) => attr.key == 'group-title',
                orElse: () => const MapEntry('', ''))
            .value;

        final titleMatch = RegExp(r',([^,]+)$').firstMatch(line);
        currentTitle = titleMatch?.group(1) ?? '';
      } else if (line.startsWith('#EXTVLCOPT:http-referrer=')) {
        httpReferer = line.substring('#EXTVLCOPT:http-referrer='.length);
        print('gzwtest $currentTitle');
      } else if (line.startsWith('#EXTVLCOPT:http-user-agent=')) {
        httpUserAgent = line.substring('#EXTVLCOPT:http-user-agent='.length);
      } else if (!line.startsWith('#') && line.isNotEmpty) {
        entries.add(M3U8Entry(
          tvgId: currentTvgId ?? '',
          tvgLogo: currentTvgLogo ?? '',
          groupTitle: currentGroupTitle ?? '',
          title: currentTitle ?? '',
          url: line,
          httpReferer: httpReferer,
          httpUserAgent: httpUserAgent,
        ));

        // Reset variables
        currentTvgId = null;
        currentTvgLogo = null;
        currentGroupTitle = null;
        currentTitle = null;
        httpReferer = null;
        httpUserAgent = null;
      }
    } catch (t, s) {
      logger.e("line $line parse failed", error: t, stackTrace: s);
    }
  }

  return entries;
}
