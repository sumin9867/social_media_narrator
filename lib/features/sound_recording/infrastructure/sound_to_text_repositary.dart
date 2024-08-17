// domain/repositories/sound_to_text_repository.dart
import 'package:social_media_narrator/features/sound_recording/domain/sound_to_text_model.dart';

abstract class SoundToTextRepository {
  Future<SoundToTextClass> sendFileToApi(String filePath);
}
