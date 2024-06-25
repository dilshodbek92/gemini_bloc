import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:video_player/video_player.dart';

import '../../../core/services/auth_service.dart';
import '../../pages/home_page.dart';
import '../home/home_bloc.dart';

part 'starter_event.dart';

part 'starter_state.dart';

class StarterBloc extends Bloc<StarterEvent, StarterState> {
  StarterBloc() : super(StarterInitial()) {
    on<StarterVideoEvent>(_initVideoPlayer);
  }

  late VideoPlayerController controller;

  Future<void> _initVideoPlayer(
      StarterVideoEvent event, Emitter<StarterState> emit) async {
    controller.play();
    controller.setLooping(true);
    emit(StarterVideoState());
  }

  initVideoController() async {
    controller = VideoPlayerController.asset("assets/videos/gemini_video.mp4")
      ..initialize();
  }

  //tts
  FlutterTts flutterTts = FlutterTts();

  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.7;
  bool isCurrentLanguageInstalled = false;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isIOS => !kIsWeb && Platform.isIOS;

  speak(String? text) async {
    await flutterTts.setVolume(volume);
    await flutterTts.setSpeechRate(rate);
    await flutterTts.setPitch(pitch);

    if (text != null) {
      if (text.isNotEmpty) {
        await flutterTts.speak(text);
      }
    }
  }

  callHomePage(BuildContext context) {
    flutterTts.stop();
    controller.dispose();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
      return BlocProvider(
        create: (context) => HomeBloc(),
        child: const HomePage(),
      );
    }));
  }

  callGoogleSignIn(BuildContext context) async {
    await AuthService.signInWithGoogle();
    callHomePage(context);
  }
}
