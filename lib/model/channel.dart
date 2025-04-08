import 'package:json_annotation/json_annotation.dart';

part 'channel.g.dart';

@JsonSerializable()
class Channel {

  Channel({
    required this.id,
    required this.name,
    required this.logo,
    required this.url,
    required this.categories,
    required this.languages,
    required this.country,
    required this.website,
    required this.isFavorite,
    required this.httpUserReferer,
    required this.httpUserAgent,
  });

  String id;
  String name;
  String? logo;
  String? url;
  @JsonKey(defaultValue: [])
  List<String> categories;
  @JsonKey(defaultValue: [])
  List<String> languages;
  String? country;
  String? website;
  @JsonKey(defaultValue: false)
  bool isFavorite;
  String? httpUserReferer;
  String? httpUserAgent;


  factory Channel.fromJson(Map<String, dynamic> json) => _$ChannelFromJson(json);

  Map<String, dynamic> toJson() => _$ChannelToJson(this);

  Channel copyWith({
    String? id,
    String? name,
    String? logo,
    String? url,
    List<String>? categories,
    List<String>? languages,
    String? country,
    String? website,
    bool? isFavorite,
    String? httpUserReferer,
    String? httpUserAgent,
    bool? isAvailable,
  }) {
    return Channel(
      id: id ?? this.id,
      name: name ?? this.name,
      logo: logo ?? this.logo,
      url: url ?? this.url,
      categories: categories ?? this.categories,
      languages: languages ?? this.languages,
      country: country ?? this.country,
      website: website ?? this.website,
      isFavorite: isFavorite ?? this.isFavorite,
      httpUserReferer: httpUserReferer ?? this.httpUserReferer,
      httpUserAgent: httpUserAgent ?? this.httpUserAgent,
    );
  }
}
