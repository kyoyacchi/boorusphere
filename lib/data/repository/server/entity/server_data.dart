import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive/hive.dart';

part 'server_data.freezed.dart';
part 'server_data.g.dart';

@freezed
class ServerData with _$ServerData {
  @HiveType(typeId: 2, adapterName: 'ServersAdapter')
  const factory ServerData({
    @HiveField(0, defaultValue: '') @Default('') String id,
    @HiveField(1, defaultValue: '') @Default('') String homepage,
    @HiveField(2, defaultValue: '') @Default('') String postUrl,
    @HiveField(3, defaultValue: '') @Default('') String searchUrl,
    @HiveField(4, defaultValue: '') @Default('') String apiAddr,
    @HiveField(7, defaultValue: '') @Default('') String tagSuggestionUrl,
    @HiveField(8, defaultValue: '') @Default('') String alias,
  }) = _ServerData;

  factory ServerData.fromJson(Map<String, dynamic> json) =>
      _$ServerDataFromJson(json);

  const ServerData._();

  bool get canSuggestTags => tagSuggestionUrl.contains('{tag-part}');

  String searchUrlOf(
    String query,
    int page,
    BooruRating searchRating,
    int postLimit,
  ) {
    String tags = query.trim().isEmpty ? ServerData.defaultTag : query.trim();
    switch (searchRating) {
      case BooruRating.safe:
        tags += ' rating:safe';
        break;
      case BooruRating.questionable:
        tags += ' rating:questionable';
        break;
      case BooruRating.explicit:
        tags += ' rating:explicit';
        break;
      case BooruRating.sensitive:
        tags += ' rating:sensitive';
        break;
      default:
        break;
    }

    // booru-on-rails doesn't support rating:x
    if (searchUrl.contains('api/v1/json/search')) {
      tags = tags.replaceAll('rating:', '');
    }

    return '$homepage/$searchUrl'
        .replaceAll('{tags}', Uri.encodeComponent(tags.trim()))
        .replaceAll('{page-id}', '$page')
        .replaceAll('{post-limit}', '$postLimit');
  }

  String suggestionUrlsOf(String query) {
    final url = '$homepage/$tagSuggestionUrl'
        .replaceAll('{post-limit}', '20')
        .replaceAll('{tag-limit}', '20');

    final encq = Uri.encodeComponent(query);
    if (!canSuggestTags) {
      throw Exception('no suggestion config for server $name');
    }

    if (query.isEmpty) {
      if (url.contains('name_pattern=')) {
        return url.replaceAll(RegExp(r'[*%]*{tag-part}[*%]*'), '');
      }
      return url.replaceAll(RegExp(r'[*%]*{tag-part}[*%]*'), '*');
    }
    return url.replaceAll('{tag-part}', encq);
  }

  String postUrlOf(int id) {
    if (postUrl.isEmpty) {
      return homepage;
    }

    final query = postUrl.replaceAll('{post-id}', id.toString());
    return '$homepage/$query';
  }

  // Key used in hive box
  String get key {
    final asKey = id.replaceAll(RegExp('[^A-Za-z0-9]'), '-');
    return '@${asKey.toLowerCase()}';
  }

  String get apiAddress => apiAddr.isEmpty ? homepage : apiAddr;

  String get name => alias.isNotEmpty ? alias : id;

  static const ServerData empty = ServerData();
  static const String defaultTag = '*';
}
