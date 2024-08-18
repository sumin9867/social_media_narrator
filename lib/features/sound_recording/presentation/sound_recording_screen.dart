import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_narrator/features/sound_recording/application/sound_to_text_cubit.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:social_media_narrator/core/theme/app_color.dart';
import 'package:social_media_narrator/features/sound_recording/presentation/widgets/emergency_screen.dart';
import 'package:social_media_narrator/features/sound_recording/presentation/widgets/emergency_word_list.dart';

class SoundRecordingScreen extends StatefulWidget {
  const SoundRecordingScreen({super.key});

  @override
  State<SoundRecordingScreen> createState() => _SoundRecordingScreenState();
}

class _SoundRecordingScreenState extends State<SoundRecordingScreen> {
  final AudioRecorder _audioRecorder = AudioRecorder();
  String? recordingPath;
  bool isRecording = false;
  Timer? recordingTimer;
  Timer? apiResponseTimer;

  @override
  void initState() {
    super.initState();
    startRecordingCycle();
  }

  void startRecordingCycle() async {
    if (await _audioRecorder.hasPermission()) {
      await startRecording();
    }
  }

  Future<void> startRecording() async {
    final String filePath = await getDownloadsFilePath("recording.m4a");

    if (recordingPath != null && File(recordingPath!).existsSync()) {
      File(recordingPath!).deleteSync();
    }

    await _audioRecorder.start(const RecordConfig(), path: filePath);
    setState(() {
      isRecording = true;
      recordingPath = filePath;
    });

    recordingTimer = Timer(const Duration(seconds: 8), () async {
      await stopRecording();
    });
  }

  Future<void> stopRecording() async {
    final String? filePath = await _audioRecorder.stop();
    if (filePath != null) {
      setState(() {
        isRecording = false;
        recordingPath = filePath;
      });

      // ignore: use_build_context_synchronously
      context.read<SoundToTextCubit>().sendFile(filePath);

      apiResponseTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final state = context.read<SoundToTextCubit>().state;
        if (state is SoundToTextLoaded) {
          final displayText = state.soundToText.text;

          if (displayText != null &&
              EmergencyWordList()
                  .emergencyPhrases
                  .any((phrase) => displayText.contains(phrase))) {
            apiResponseTimer?.cancel();
            showEmergencyScreen();
          } else {
            startRecordingCycle();
            apiResponseTimer?.cancel();
          }
        }
      });
    }
  }

  @override
  void dispose() {
    recordingTimer?.cancel();
    apiResponseTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<SoundToTextCubit, SoundToTextState>(
        builder: (context, state) {
          String? displayText;
          if (state is SoundToTextLoaded) {
            displayText = state.soundToText.text;
          }

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Center(
                child: GestureDetector(
                  onTap: () async {
                    if (isRecording) {
                      await stopRecording();
                    } else {
                      if (await _audioRecorder.hasPermission()) {
                        await startRecording();
                      }
                    }
                  },
                  child: CircleAvatar(
                    radius: 140,
                    child: CircleAvatar(
                      radius: 100,
                      backgroundColor: AppColor.primary,
                      child: Icon(
                        isRecording ? Icons.stop : Icons.mic,
                        size: 60,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 30,
              ),
              if (state is SoundToTextLoading)
                const CircularProgressIndicator(),
              if (displayText != null)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    displayText,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.black),
                  ),
                ),
              if (state is SoundToTextError)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    state.error,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 18, color: Colors.red),
                  ),
                ),
            ],
          );
        },
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

  void showEmergencyScreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => EmergencyScreen(
          onCancel: () {
            Navigator.of(context).pop();
            startRecordingCycle();
          },
          onTimeout: () {
            log("Emergency action taken!");
          },
        ),
      ),
    );
  }
}
