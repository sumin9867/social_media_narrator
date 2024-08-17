import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_narrator/features/sound_recording/domain/sound_to_text_model.dart';
import 'package:social_media_narrator/features/sound_recording/infrastructure/sound_to_text_repositary.dart';

part 'sound_to_text_state.dart';

class SoundToTextCubit extends Cubit<SoundToTextState> {
  final SoundToTextRepository repository;

  SoundToTextCubit({required this.repository}) : super(SoundToTextInitial());

  Future<void> sendFile(String filePath) async {
    try {
      emit(SoundToTextLoading());
      final response = await repository.sendFileToApi(filePath);
      emit(SoundToTextLoaded(response));
    } catch (e) {
      emit(SoundToTextError('Failed to upload file: ${e.toString()}'));
    }
  }
}
