import 'package:dio/dio.dart';
import 'package:flutter_iptv_client/common/shared_dio.dart';
import 'package:retrofit/retrofit.dart';

import '../model/channel.dart';
part 'http_client.g.dart';

@RestApi(baseUrl: 'https://iptv-org.github.io/api/')
abstract class HttpClient {
  static final instance = HttpClient();

  factory HttpClient() => _HttpClient(sharedDio);

  @GET('channels.json')
  Future<List<Channel>> getChannel();
}