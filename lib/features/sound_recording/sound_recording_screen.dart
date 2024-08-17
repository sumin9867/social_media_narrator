import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:social_media_narrator/core/theme/app_color.dart';
import 'package:http/http.dart' as http;

class SoundRecordingScreen extends StatefulWidget {
  const SoundRecordingScreen({super.key});

  @override
  State<SoundRecordingScreen> createState() => _SoundRecordingScreenState();
}

class _SoundRecordingScreenState extends State<SoundRecordingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  final AudioPlayer audioPlayer = AudioPlayer();
  String? recordingPath;
  bool isRecording = false;
  bool isPlaying = false;
  String? apiResponse; // To store and display the API response

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (recordingPath != null)
              MaterialButton(
                onPressed: () async {
                  if (audioPlayer.playing) {
                    audioPlayer.stop();
                    setState(() {
                      isPlaying = false;
                    });
                  } else {
                    await audioPlayer.setFilePath(recordingPath!);
                    audioPlayer.play();
                    setState(() {
                      isPlaying = true;
                    });
                  }
                },
                color: AppColor.primary,
                child: Text(isPlaying ? "Stop playing" : "Play"),
              ),
            if (recordingPath == null) const Text("No recording found :("),
            if (apiResponse != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  apiResponse!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18, color: Colors.black),
                ),
              ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (isRecording) {
            final String? filePath = await _audioRecorder.stop();
            if (filePath != null) {
              setState(() {
                isRecording = false;
                recordingPath = filePath;
              });
              await sendFileToApi(filePath);
            }
          } else {
            if (await _audioRecorder.hasPermission()) {
              final String filePath =
                  await getDownloadsFilePath("recording.m4a");
              await _audioRecorder.start(const RecordConfig(), path: filePath);
              setState(() {
                isRecording = true;
                recordingPath = null;
              });
            }
          }
        },
        child: Icon(isRecording ? Icons.stop : Icons.mic),
      ),
    );
  }

  Future<String> getDownloadsFilePath(String fileName) async {
    final Directory? downloadsDir = await getDownloadsDirectory();
    if (downloadsDir != null) {
      final String filePath = path.join(downloadsDir.path, fileName);
      return filePath;
    } else {
      throw Exception("Downloads directory not available");
    }
  }

  Future<void> sendFileToApi(String filePath) async {
    final uri = Uri.parse('https://api.turboline.ai/openai/audio/translations');
    final request = http.MultipartRequest('POST', uri)
      ..headers['X-TL-Key'] = 'a3f48783e2834526a4eff8056abce4b7'
      ..files.add(await http.MultipartFile.fromPath('file', filePath))
      ..fields['model'] = 'whisper-1'
      ..fields['prompt'] = 'Translate this audio into English.'
      ..fields['response_format'] = 'json';

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      setState(() {
        apiResponse = responseBody; // Store the API response to display it
      });
    } else {
      setState(() {
        apiResponse =
            'File upload failed with status code: ${response.statusCode}';
      });
    }
  }
}
