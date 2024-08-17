import 'dart:io';

import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:social_media_narrator/core/theme/app_color.dart';

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
                child: Text(isPlaying ? "Stop playing" : "play"),
              ),
            if (recordingPath == null) Text("No recording found :(")
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
                print("sumin $recordingPath");
              });
            }
          } else {
            if (await _audioRecorder.hasPermission()) {
              final Directory appDocumentDir =
                  await getApplicationDocumentsDirectory();
              final String filepath =
                  path.join(appDocumentDir.path, "recordind.wav");
              await _audioRecorder.start(RecordConfig(), path: filepath);

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
}
