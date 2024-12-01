import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/common/shared_dio.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/model/m3u8_entry.dart';
import 'package:path_provider/path_provider.dart';

import '../common/shared_preference.dart';

class ChannelProvider with ChangeNotifier {
  List<Channel> channels = [];
  List<Channel> allChannels = [];
  List<Channel> searchResultChannels = [];
  List<String> favoriteList = [];
  List<String> allCategories = ['favorite', 'all'];
  Channel? currentChannel;
  String? currentDescription;
  String? currentUrl;
  String category = 'all';
  String country = 'all';
  bool loading = false;
  static const favoriteListKey = 'favoriteListKey';
  static const countryKey = 'countryKey';
  static const m3u8UrlKey = 'm3u8UrlKey';

  Future<void> resetM3UContent() async {
    await importFromUrl(m3u8Url);
  }

  Future<bool> importFromUrl(String url) async {
    if (url.isEmpty || !url.contains('.m3u')) {
      return false;
    }
    sharedPreferences.setString(m3u8UrlKey, url);
    final result = await getChannels();
    if (result) {
      selectCountry(country: 'all');
    }
    return result;
  }

  Future<bool> getChannels() async {
    loading = true;
    notifyListeners();
    favoriteList = sharedPreferences.getStringList(favoriteListKey) ?? [];
    country = sharedPreferences.getString(countryKey) ?? 'all';
      try {
        final url = sharedPreferences.getString(m3u8UrlKey) ?? m3u8Url;
        currentUrl = url;
        final response = await sharedDio.get(url);
        if (response.isSuccess) {
          String m3uContent = response.data.toString();
          await _parseChannels(m3uContent);
        }
      } catch (e) {
        logger.e('getChannels failed', error: e);
        return false;
      }
    loading = false;
    notifyListeners();
    return true;
  }

  Future<void> _parseChannels(String m3uContent) async {
    final m3u8List = parseM3U8(m3uContent);
    logger.i('_parseChannels ${m3u8List.length}');
    final channelsContent = await rootBundle.loadString(
        'assets/files/channels.json');
    final channelMap = Map.fromEntries((jsonDecode(channelsContent) as List).map((e) {
      final channel = Channel.fromJson(e);
      return MapEntry(channel.id, channel);
    }));

    Set<String> categorySet = {};
    for (final entry in m3u8List) {
      var channel = channelMap[entry.tvgId];
      if (channel == null) {
        channel = entry.toChannel();
        channelMap[channel.id] = channel;
      }
      channel.isFavorite = favoriteList.contains(channel.id);
      channel.url = entry.url;
      categorySet.addAll(channel.categories);
    }
    final categoryList = categorySet.toList();
    categoryList.sort();
    allCategories = ['favorite', 'all'] + categoryList;
    allChannels = channelMap.values.where((element) => element.url != null).toList();
    channels = await _filterChannel();
  }

  void selectCategory({String category = 'all'}) async{
    this.category = category;
    var channelList = await _filterChannel();
    channels = channelList;
    notifyListeners();
  }

  Future<List<Channel>> _filterChannel() async{
    List<Channel> channelList = allChannels.toList();
    final isFavorite = category == 'favorite';
    if (isFavorite) {
      channelList = channelList.where((element) => element.isFavorite).toList();
    } else if (category != 'all') {
      channelList = channelList
          .where((element) => element.categories.contains(category))
          .toList();
    }
    if (country != 'all' && !isFavorite) {
      channelList = channelList
          .where((element) => element.country == country)
          .toList();
    }
    return channelList;
  }

  void selectCountry({String country = 'all'}) async {
    sharedPreferences.setString(countryKey, country);
    this.country = country;
    var channelList = _filterChannel();
    channels = await channelList;
    notifyListeners();
  }

  void setFavorite(String id, bool isFavorite) async {
    if (isFavorite) {
      if (!favoriteList.contains(id)) {
        favoriteList.add(id);
      }
    } else {
      favoriteList.remove(id);
    }
    () {
      final index = allChannels.indexWhere((element) => element.id == id);
      if (index >= 0) {
        final copiedChannelList = allChannels.toList();
        final channel = copiedChannelList[index].copyWith(isFavorite: isFavorite);
        copiedChannelList[index] = channel;
        allChannels = copiedChannelList;
        if (currentChannel != null && currentChannel!.id == channel.id) {
          currentChannel = channel;
        }
        notifyListeners();
      }
    }();
    () {
      final index = channels.indexWhere((element) => element.id == id);
      if (index >= 0) {
        final copiedChannelList = channels.toList();
        final channel = copiedChannelList[index].copyWith(isFavorite: isFavorite);
        copiedChannelList[index] = channel;
        channels = copiedChannelList;
        if (currentChannel != null && currentChannel!.id == channel.id) {
          currentChannel = channel;
        }
        notifyListeners();
      }
    }();
    sharedPreferences.setStringList(favoriteListKey, favoriteList);
  }

  void setCurrentChannel(Channel? channel) {
    currentChannel = channel;
    notifyListeners();
    if (channel?.id != null) {
      generateDescription(channel!.id);
    }
  }

  Future<void> generateDescription(String channelId) async {
    try {
      currentDescription = null;
      if (currentChannel == null) {
        return;
      }
      final dir = await getApplicationDocumentsDirectory();
      final descFile = File('${dir.path}/desc/$channelId.md');
      logger.i('descFile file path: ${descFile.path}');
      String? desc;
      if (!descFile.existsSync()) {
        final prompt = "Can you give me a general introduction of TV channel in ${currentChannel!.country} called ${currentChannel!
            .name}? And then give me more details about this channel?";
        final response = await Gemini.instance.text(
            prompt, modelName: 'models/gemini-1.5-flash');
        desc = response!.content!.parts!.last.text;
        if (desc != null) {
          await descFile.create(recursive: true);
          descFile.writeAsString(desc);
        }
      } else {
        desc = await descFile.readAsString();
      }
      logger.i('channel $channelId desc is: $desc');
      if (currentChannel!.id == channelId) {
        currentDescription = desc;
        notifyListeners();
      }
    } catch (e) {
      logger.e('gemini error', error: e);
    }
  }

  bool previousChannel() {
    if (currentChannel != null) {
      final index = channels.indexOf(currentChannel!);
      if (index > 0 && index < channels.length) {
        setCurrentChannel(channels[index - 1]);
        return true;
      }
    }
    return false;
  }

  bool nextChannel() {
    if (currentChannel != null) {
      final index = channels.indexOf(currentChannel!);
      if (index >= 0 && index < channels.length - 1) {
        setCurrentChannel(channels[index + 1]);
        return true;
      }
    }
    return false;
  }
}
