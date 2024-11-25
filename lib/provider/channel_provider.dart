import 'dart:convert';
import 'dart:io';
import 'dart:isolate';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_iptv_client/common/data.dart';
import 'package:flutter_iptv_client/common/logger.dart';
import 'package:flutter_iptv_client/common/shared_dio.dart';
import 'package:flutter_iptv_client/model/channel.dart';
import 'package:flutter_iptv_client/model/m3u8_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

import '../common/shared_preference.dart';

class ChannelProvider with ChangeNotifier {
  List<Channel> channels = [];
  List<Channel> allChannels = [];
  List<String> favoriteList = [];
  Channel? currentChannel;
  String? currentDescription;
  String category = 'all';
  String country = 'all';
  bool filterValidChannel = true;
  bool loading = false;
  static const favoriteListKey = 'favoriteListKey';
  static const countryKey = 'countryKey';

  Future<String> getM3UContent() async {
    final dir = await getApplicationDocumentsDirectory();
    final m3uFile = File('${dir.path}/index.m3u');
    logger.i('m3u file path: ${m3uFile.path}');
    if (!m3uFile.existsSync()) {
      await m3uFile.create(recursive: true);
      await m3uFile
          .writeAsString(await rootBundle.loadString('assets/files/index.m3u'));
    }
    return m3uFile.readAsString();
  }

  Future<void> resetM3UContent() async {
    loading = true;
    notifyListeners();
    final dir = await getApplicationDocumentsDirectory();
    final m3uFile = File('${dir.path}/index.m3u');
    await m3uFile.delete();
    loading = false;
    notifyListeners();
  }

  Future<bool> importFromUrl(String url) async {
    if (url.isEmpty || !url.contains('.m3u')) {
      return false;
    }
    loading = true;
    notifyListeners();
    try {
      final dir = await getApplicationDocumentsDirectory();
      final m3uFile = File('${dir.path}/index.m3u');
      if (!m3uFile.existsSync()) {
        await m3uFile.create(recursive: true);
      }
      final response = await sharedDio.get(url);
      if (response.isSuccess) {
        final m3uContent = response.data.toString();
        await m3uFile.writeAsString(m3uContent);
        return true;
      }
    } catch (e, s) {
      logger.e('importFromUrl error', error: e, stackTrace: s);
    }
    loading = false;
    notifyListeners();
    return false;
  }

  void getChannels() async {
    loading = true;
    notifyListeners();
    favoriteList = sharedPreferences.getStringList(favoriteListKey) ?? [];
    country = sharedPreferences.getString(countryKey) ?? 'all';
    try {
      final response = await sharedDio.get(m3u8Url);
      if (response.isSuccess) {
        String m3uContent = response.data.toString();
        final m3u8Map = Map.fromEntries(
            parseM3U8(m3uContent).map((e) => MapEntry(e.tvgId, e)));
        final channelsContent = await rootBundle.loadString(
            'assets/files/channels.json');
        final allChannelList = await Isolate.run(() {
          return (jsonDecode(channelsContent) as List).map((e) {
            final channel = Channel.fromJson(e);
            return channel;
          }).toList();
        });

        for (final channel in allChannelList) {
          channel.isFavorite = favoriteList.contains(channel.id);
          final m3u8Entry = m3u8Map[channel.id];
          if (m3u8Entry != null) {
            channel.url = m3u8Entry.url;
          }
        }
        allChannels = allChannelList;
        channels = await _filterChannel();
      }
    } catch (e) {
      logger.e('getChannels failed', error: e);
    }
    loading = false;
    notifyListeners();
  }

  void selectCategory({String category = 'all'}) async{
    this.category = category;
    var channelList = await _filterChannel();
    channels = channelList;
    notifyListeners();
  }

  Future<List<Channel>> _filterChannel() async{
    List<Channel> channelList = allChannels.toList();
    if (filterValidChannel) {
      channelList =
          channelList.where((element) => element.url != null).toList();
    }
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
    Future(() {
      final index = allChannels.indexWhere((element) => element.id == id);
      if (index >= 0) {
        final copiedChannelList = allChannels.toList();
        final channel = copiedChannelList[index];
        copiedChannelList[index] = channel.copyWith(isFavorite: isFavorite);
        allChannels = copiedChannelList;
        notifyListeners();
      }
    });
    Future(() {
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
    });
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
        final prompt = "Can you give me a general introduction of TV channel called ${currentChannel!
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
