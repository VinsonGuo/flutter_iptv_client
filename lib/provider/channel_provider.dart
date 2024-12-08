import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/common/shared_dio.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/model/m3u8_entry.dart';

import '../common/shared_preference.dart';

class ChannelProvider with ChangeNotifier {
  List<Channel> channels = [];
  List<Channel> allChannels = [];
  List<Channel> searchResultChannels = [];
  List<String> favoriteList = [];
  List<String> m3u8UrlList = [];
  List<String> allCategories = ['favorite', 'all'];
  List<String> allCountries = ['all'];
  Channel? currentChannel;
  String? currentUrl;
  String category = 'all';
  String country = 'all';
  bool loading = false;
  static const favoriteListKey = 'favoriteListKey';
  static const countryKey = 'countryKey';
  static const m3u8UrlKey = 'm3u8UrlKey';
  static const m3u8UrlListKey = 'm3u8UrlListKey';

  Future<void> resetM3UContent() async {
    await importFromUrl(defaultM3u8Url);
  }

  Future<bool> importFromUrl(String url) async {
    if (url.isEmpty || !url.contains('.m3u')) {
      return false;
    }
    sharedPreferences.setString(m3u8UrlKey, url);
    final result = await getChannels();
    if (result) {
      resetFilter();
      if (!m3u8UrlList.contains(url)) {
        m3u8UrlList.add(url);
        sharedPreferences.setStringList(m3u8UrlListKey, m3u8UrlList);
        notifyListeners();
      }
    } else {
      sharedPreferences.setString(m3u8UrlKey, currentUrl ?? defaultM3u8Url);
    }
    return result;
  }

  void deleteM3u8Url(String url) {
    final copiedList = m3u8UrlList.toList();
    if (copiedList.remove(url)) {
      m3u8UrlList = copiedList;
      sharedPreferences.setStringList(m3u8UrlListKey, copiedList);
      notifyListeners();
    }
  }

  Future<bool> getChannels() async {
    var result = true;
    loading = true;
    notifyListeners();
    favoriteList = sharedPreferences.getStringList(favoriteListKey) ?? [];
    country = sharedPreferences.getString(countryKey) ?? 'all';
    m3u8UrlList = sharedPreferences.getStringList(m3u8UrlListKey) ?? [defaultM3u8Url];
    try {
      final url = sharedPreferences.getString(m3u8UrlKey) ?? defaultM3u8Url;
      final response = await sharedDio.get(url);
      String m3uContent = response.data.toString();
      await _parseChannels(m3uContent);
      currentUrl = url;
    } catch (e) {
      logger.e('getChannels failed', error: e);
      result = false;
    }
    loading = false;
    notifyListeners();
    return result;
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
    Set<String> countrySet = {};
    for (final entry in m3u8List) {
      var channel = channelMap[entry.tvgId];
      if (channel == null) {
        channel = entry.toChannel();
        channelMap[channel.id] = channel;
      }
      channel.isFavorite = favoriteList.contains(channel.id);
      channel.url = entry.url;
      categorySet.addAll(channel.categories);
      countrySet.add(channel.country ?? 'uncategorized');
    }
    final categoryList = categorySet.toList();
    categoryList.sort();
    allCategories = ['favorite', 'all'] + categoryList;
    final countryList = countrySet.toList();
    countryList.sort();
    allCountries = ['all'] + countryList;
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

  void resetFilter() async {
    const all = 'all';
    sharedPreferences.setString(countryKey, all);
    country = all;
    category = all;
    var channelList = _filterChannel();
    channels = await channelList;
    notifyListeners();
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
