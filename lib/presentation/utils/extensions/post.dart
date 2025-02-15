import 'package:boorusphere/data/repository/booru/entity/post.dart';
import 'package:boorusphere/presentation/provider/settings/entity/booru_rating.dart';
import 'package:boorusphere/presentation/utils/entity/content.dart';
import 'package:boorusphere/presentation/utils/entity/pixel_size.dart';

extension PostExt on Post {
  bool get hasCategorizedTags => [
        ...tagsArtist,
        ...tagsCharacter,
        ...tagsCopyright,
        ...tagsGeneral,
        ...tagsMeta
      ].isNotEmpty;

  Set<String> get allTags => {
        ...tagsArtist,
        ...tagsCharacter,
        ...tagsCopyright,
        ...tagsGeneral,
        ...tagsMeta,
        ...tags,
      };

  String get describeTags => allTags.join(' ');

  double get aspectRatio {
    if (prescreensize.hasPixels) {
      return prescreensize.aspectRatio;
    } else if (sampleSize.hasPixels) {
      return sampleSize.aspectRatio;
    } else {
      return originalSize.aspectRatio;
    }
  }

  PixelSize get originalSize => PixelSize(width: width, height: height);

  PixelSize get sampleSize =>
      PixelSize(width: sampleWidth, height: sampleHeight);

  PixelSize get prescreensize =>
      PixelSize(width: previewWidth, height: previewHeight);

  BooruRating get rating => BooruRating.parse(rateValue);

  Content get content {
    final sample = sampleFile.asContent();
    final original = originalFile.asContent();
    if (sample.isPhoto && original.isVideo || sample.isUnsupported) {
      return original;
    }

    return sample;
  }

  String get heroTag {
    return '$id-$serverId';
  }
}
