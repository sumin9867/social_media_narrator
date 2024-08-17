part of 'sound_to_text_cubit.dart';

@immutable
abstract class SoundToTextState {}

class SoundToTextInitial extends SoundToTextState {}

class SoundToTextLoading extends SoundToTextState {}

class SoundToTextLoaded extends SoundToTextState {
  final SoundToTextClass soundToText;

  SoundToTextLoaded(this.soundToText);
}

class SoundToTextError extends SoundToTextState {
  final String error;

  SoundToTextError(this.error);
}
