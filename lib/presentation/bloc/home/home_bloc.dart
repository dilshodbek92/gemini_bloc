import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shake/shake.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/utils_service.dart';
import '../../../data/models/message_model.dart';
import '../../../data/repository/gemini_talk_repository_impl.dart';
import '../../../data/repository/hive_repository_impl.dart';
import '../../../domain/usecases/gemini_only_text_usecase.dart';
import '../../../domain/usecases/gemini_text_and_image_usecase.dart';
import '../../../domain/usecases/get_messages_db_usecase.dart';
import '../../../domain/usecases/save_message_db_usecase.dart';
import '../../pages/starter_page.dart';
import '../starter/starter_bloc.dart';

part 'home_event.dart';

part 'home_state.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc() : super(HomeInitial()) {
    on<HomeSendEvent>(_onSendPressed);
    on<HomeLoadMessagesEvent>(_getMessages);
    on<HomeChooseImageEvent>(_onSelectImage);
    on<HomeRemoveImageEvent>(_onRemoveImage);
  }

  List<MessageModel> messages = [];

  TextEditingController textController = TextEditingController();
  GeminiTextOnlyUseCase textOnlyUseCase =
      GeminiTextOnlyUseCase(GeminiTalkRepositoryImpl());

  GeminiTextAndImageUseCase textAndImageUseCase =
      GeminiTextAndImageUseCase(GeminiTalkRepositoryImpl());

  String? image;

  Future apiTextOnly(String text) async {
    var either = await textOnlyUseCase.call(text);
    either.fold((l) {
      var messageModel = MessageModel(message: l, isMine: false);
      messages.add(messageModel);
      saveMessages(messageModel);
    }, (r) async {
      var messageModel = MessageModel(message: r, isMine: false);
      messages.add(messageModel);
      saveMessages(messageModel);
    });
  }

  Future apiTextAndImage(String text, String imageBase64) async {
    var either = await textAndImageUseCase.call(text, imageBase64);
    either.fold((l) {
      var messageModel = MessageModel(message: l, isMine: false);
      messages.add(messageModel);
      saveMessages(messageModel);
    }, (r) async {
      var messageModel = MessageModel(message: r, isMine: false);
      messages.add(messageModel);
      saveMessages(messageModel);
    });
  }

  ScrollController scrollController = ScrollController();

  Future<void> _onSendPressed(
      HomeSendEvent event, Emitter<HomeState> emit) async {
    var myMessage =
        MessageModel(message: event.message, isMine: true, base64Image: image);
    messages.add(myMessage);
    textController.clear();
    emit(HomeLoadingState());

    saveMessages(myMessage);
    if (image == null) {
      await apiTextOnly(event.message);
    } else {
      await apiTextAndImage(event.message, image!);
      image = null;
      emit(HomeMessagesLoadedState());
    }
    textController.clear();
    scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut
    );
    emit(HomeMessagesLoadedState());
  }

  Future<void> _onSelectImage(
      HomeChooseImageEvent event, Emitter<HomeState> emit) async {
    var base64 = await Utils.pickAndConvertImage();
    if (base64.trim().isNotEmpty) {
      image = base64;
      emit(HomeImageSelectedState());
    }
  }

  _onRemoveImage(HomeRemoveImageEvent event, Emitter<HomeState> emit) {
    image = null;
    emit(HomeRemoveImage());
  }

  //local database
  GetMessagesDbUseCase databaseUseCase =
      GetMessagesDbUseCase(HiveRepositoryImplementation());

  SaveMessageUseCase saveMessageUseCase =
      SaveMessageUseCase(HiveRepositoryImplementation());

  Future<void> _getMessages(
      HomeLoadMessagesEvent event, Emitter<HomeState> emit) async {
    var either = await databaseUseCase.call();

    either.fold((l) {
      emit(HomeMessagesLoadedState());
    }, (r) async {
      messages.addAll(r);
      emit(HomeMessagesLoadedState());
    });
  }

  saveMessages(MessageModel messageModel) async {
    await saveMessageUseCase.call(messageModel);
  }

  /// speech to text
  SpeechToText speechToText = SpeechToText();
  bool speechEnabled = false;
  Color microphoneColor = Colors.grey.shade600;
  String _lastWords = '';

  void initSpeech() async {
    speechEnabled = await speechToText.initialize();
  }

  void startListening() async {
    await speechToText.listen(onResult: _onSpeechResult);
    microphoneColor = Colors.red;
    //update();
  }

  void stopListening() async {
    await speechToText.stop();
    microphoneColor = Colors.grey.shade600;
    //update();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;

    if (result.finalResult) {
      microphoneColor = Colors.grey.shade600;
      add(HomeSendEvent(message: _lastWords));
    }
  }

  onStartListening() {
    speechToText.isNotListening ? startListening() : stopListening();
  }

  //tts
  FlutterTts? flutterTts = FlutterTts();

  String? language;
  String? engine;
  double volume = 0.5;
  double pitch = 1.0;
  double rate = 0.5;
  bool isCurrentLanguageInstalled = false;

  Color speakerColor = Colors.grey.shade600;

  bool get isAndroid => !kIsWeb && Platform.isAndroid;

  bool get isIOS => !kIsWeb && Platform.isIOS;
  bool isSpeaking = false;

  dynamic initTts() {
    flutterTts?.setCompletionHandler(() {
      speakerColor = Colors.grey.shade600;
      isSpeaking = false;
    });
  }

  speak(String? text) async {
    await flutterTts!.setVolume(volume);
    await flutterTts!.setSpeechRate(rate);
    await flutterTts!.setPitch(pitch);

    if (text != null) {
      if (text.isNotEmpty) {
        if (!isSpeaking) {
          speakerColor = Colors.red;

          isSpeaking = true;
          await flutterTts!.speak(text);
        } else {
          speakerColor = Colors.grey.shade600;
          isSpeaking = false;
          flutterTts!.pause();
        }
      }
    }
  }

  void dispose() {
    flutterTts!.stop();
  }

  //shake

  initShake(context) async {
    ShakeDetector? detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        speak("What do you want to know about");
      },
      minimumShakeCount: 1,
      shakeSlopTimeMS: 500,
      shakeCountResetTime: 3000,
      shakeThresholdGravity: 2.7,
    );
  }

  callSignOut(BuildContext context) async {
    await AuthService.signOutFromGoogle();
    Navigator.pushReplacement(context,
        MaterialPageRoute(builder: (BuildContext context) {
          return BlocProvider(
            create: (context) => StarterBloc(),
            child: const StarterPage(),
          );
        }));
    var result = await AuthService.signOutFromGoogle();
  }
}
