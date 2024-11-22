import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iptv_client/common/shared_dio.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/model/m3u8_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../common/shared_preference.dart';

class ChannelProvider with ChangeNotifier {
  List<Channel> channels = [];
  List<Channel> allChannels = [];
  List<String> favoriteList = [];
  static const favoriteListKey = 'favoriteListKey';

  void getChannels() async {
    favoriteList = sharedPreferences.getStringList(favoriteListKey) ?? [];
    final m3uContent = await rootBundle.loadString('assets/files/index.m3u');
    final m3u8Map =
        Map.fromEntries(parseM3U8(m3uContent).map((e) => MapEntry(e.tvgId, e)));
    final channelsContent =
        await rootBundle.loadString('assets/files/channels.json');
    var channelList = (jsonDecode(channelsContent) as List).map((e) {
      final channel = Channel.fromJson(e);
      return channel;
    }).toList();

    for (final channel in channelList) {
      channel.isFavorite = favoriteList.contains(channel.id);
      final m3u8Entry = m3u8Map[channel.id];
      if (m3u8Entry != null) {
        channel.url = m3u8Entry.url;
      }
    }
    channels = channelList;
    allChannels = channelList;
    notifyListeners();
  }

  void select({String category = 'all', String language = 'all'}) {
    var channelList = allChannels.toList();
    if (category != 'all') {
      channelList = channelList.where((element) => element.categories.contains(category)).toList();
    }
    if (language != 'all') {
      channelList = channelList.where((element) => element.languages.contains(language)).toList();
    }
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
    final index =
        await Future(() => channels.indexWhere((element) => element.id == id));
    if (index >= 0) {
      final copiedChannelList = channels.toList();
      final channel = copiedChannelList[index];
      copiedChannelList[index] = channel.copyWith(isFavorite: isFavorite);
      channels = copiedChannelList;
      notifyListeners();
    }
    sharedPreferences.setStringList(favoriteListKey, favoriteList);
  }
}
