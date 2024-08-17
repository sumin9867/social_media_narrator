import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:social_media_narrator/features/sound_recording/domain/sound_to_text_model.dart';
import 'package:social_media_narrator/features/sound_recording/infrastructure/sound_to_text_repositary.dart';

class SoundToTextRepositoryImpl implements SoundToTextRepository {
  @override
  Future<SoundToTextClass> sendFileToApi(String filePath) async {
    final uri = Uri.parse('https://api.turboline.ai/openai/audio/translations');
    final request = http.MultipartRequest('POST', uri)
      ..headers['X-TL-Key'] = 'a3f48783e2834526a4eff8056abce4b7'
      ..files.add(await http.MultipartFile.fromPath('file', filePath))
      ..fields['model'] = 'whisper-1'
      ..fields['prompt'] = 'Translate this audio into English.'
      ..fields['response_format'] = 'json';

    try {
      final response =
          await request.send().timeout(const Duration(seconds: 30));

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final jsonResponse = json.decode(responseBody);

        return SoundToTextClass.fromJson(jsonResponse);
      } else {
        final responseBody = await response.stream.bytesToString();
        throw Exception(
            'File upload failed with status code: ${response.statusCode}, Response body: $responseBody');
      }
    } catch (e) {
      throw Exception('File upload failed: $e');
    }
  }
}
