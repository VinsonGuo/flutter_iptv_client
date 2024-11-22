import 'dart:convert';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/common/shared_dio.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/model/m3u8_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/shared_preference.dart';

class ChannelProvider with ChangeNotifier {
  List<Channel> channels = [];
  List<Channel> allChannels = [];
  List<String> favoriteList = [];
  String category = 'all';
  String language = 'all';
  bool filterValidChannel = true;
  static const favoriteListKey = 'favoriteListKey';
  static const languageKey = 'languageKey';
  static const categoryKey = 'categoryKey';

  void getChannels() async {
    favoriteList = sharedPreferences.getStringList(favoriteListKey) ?? [];
    category = sharedPreferences.getString(categoryKey) ?? 'all';
    language = sharedPreferences.getString(languageKey) ?? 'all';

    // final m3uContent = await rootBundle.loadString('assets/files/index.m3u');
    String m3uContent;
    final response = await sharedDio.get('https://iptv-org.github.io/iptv/index.m3u');
    if (response.isSuccess) {
      m3uContent = response.data.toString();
      logger.i('load channel from network');
    } else {
      m3uContent = await rootBundle.loadString('assets/files/index.m3u');
      logger.i('load channel from assets');
    }
    final m3u8Map =
        Map.fromEntries(parseM3U8(m3uContent).map((e) => MapEntry(e.tvgId, e)));
    final channelsContent =
        await rootBundle.loadString('assets/files/channels.json');
    var allChannelList = (jsonDecode(channelsContent) as List).map((e) {
      final channel = Channel.fromJson(e);
      return channel;
    }).toList();

    for (final channel in allChannelList) {
      channel.isFavorite = favoriteList.contains(channel.id);
      final m3u8Entry = m3u8Map[channel.id];
      if (m3u8Entry != null) {
        channel.url = m3u8Entry.url;
        channel.name = m3u8Entry.title;
      }
    }
    allChannels = allChannelList;
    channels = _filterChannel();
    notifyListeners();
  }

  void selectCategory({String category = 'all'}) {
    sharedPreferences.setString(categoryKey, category);
    this.category = category;
    var channelList = _filterChannel();
    channels = channelList;
    notifyListeners();
  }

  List<Channel> _filterChannel() {
    List<Channel> channelList = allChannels.toList();
    if (filterValidChannel) {
      channelList = channelList.where((element) => element.url != null).toList();
    }
    final isFavorite = category == 'favorite';
    if (isFavorite){
      channelList = channelList.where((element) => element.isFavorite).toList();
    } else if (category != 'all') {
      channelList = channelList.where((element) => element.categories.contains(category)).toList();
    }
    if (language != 'all' && !isFavorite) {
      channelList = channelList.where((element) => element.languages.contains(language)).toList();
    }
    return channelList;
  }

  void selectLanguage({String language = 'all'}) {
    sharedPreferences.setString(languageKey, language);
    this.language = language;
    var channelList = _filterChannel();
    channels = channelList;
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
    Future((){
      final index = allChannels.indexWhere((element) => element.id == id);
      if (index >= 0) {
        final copiedChannelList = allChannels.toList();
        final channel = copiedChannelList[index];
        copiedChannelList[index] = channel.copyWith(isFavorite: isFavorite);
        allChannels = copiedChannelList;
        notifyListeners();
      }
    });
    Future((){
      final index = channels.indexWhere((element) => element.id == id);
      if (index >= 0) {
        final copiedChannelList = channels.toList();
        final channel = copiedChannelList[index];
        copiedChannelList[index] = channel.copyWith(isFavorite: isFavorite);
        channels = copiedChannelList;
        notifyListeners();
      }
    });
    sharedPreferences.setStringList(favoriteListKey, favoriteList);
  }
}
