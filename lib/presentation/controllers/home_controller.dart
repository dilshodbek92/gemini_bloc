import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:get/get.dart';
import 'package:shake/shake.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../../core/services/log_service.dart';
import '../../core/services/utils_service.dart';
import '../../data/models/message_model.dart';
import '../../data/repository/gemini_talk_repository_impl.dart';
import '../../data/repository/hive_repository_impl.dart';
import '../../domain/usecases/gemini_only_text_usecase.dart';
import '../../domain/usecases/gemini_text_and_image_usecase.dart';
import '../../domain/usecases/get_messages_db_usecase.dart';
import '../../domain/usecases/save_message_db_usecase.dart';

class HomeController extends GetxController {
  List<MessageModel> messages = [];

  TextEditingController textController = TextEditingController();
  GeminiTextOnlyUseCase textOnlyUseCase =
      GeminiTextOnlyUseCase(GeminiTalkRepositoryImpl());

  GeminiTextAndImageUseCase textAndImageUseCase =
      GeminiTextAndImageUseCase(GeminiTalkRepositoryImpl());

  String? image;

  bool isLoading = false;

  apiTextOnly(String text) async {
    var either = await textOnlyUseCase.call(text);
    either.fold((l) {
      LogService.d(l);
      var messageModel = MessageModel(message: l, isMine: false);
      updateMessages(messageModel, false);
      saveMessages(messageModel);
    }, (r) async {
      LogService.d(r);
      var messageModel = MessageModel(message: r, isMine: false);
      updateMessages(messageModel, false);
      saveMessages(messageModel);
    });
  }

  apiTextAndImage(String text, String imageBase64) async {
    var either = await textAndImageUseCase.call(text, imageBase64);
    either.fold((l) {
      LogService.d(l);
      var messageModel = MessageModel(message: l, isMine: false);
      updateMessages(messageModel, false);
    }, (r) async {
      LogService.d(r);
      var messageModel = MessageModel(message: r, isMine: false);
      updateMessages(messageModel, false);
    });
  }

  updateMessages(MessageModel messageModel, bool isLoading) {
    this.isLoading = isLoading;
    messages.add(messageModel);
    update();
    saveMessages(messageModel);
  }

  onSendPressed(String text) {
    var myMessage =
        MessageModel(message: text, isMine: true, base64Image: image);
    updateMessages(myMessage, true);
    saveMessages(myMessage);

    if (image == null) {
      apiTextOnly(text);
    } else {
      apiTextAndImage(text, image!);
      image = null;
      update();
    }

    textController.clear();
  }

  onSelectImage() async {
    var base64 = await Utils.pickAndConvertImage();
    if (base64.trim().isNotEmpty) {
      image = base64;
      update();
    }
  }

  onRemoveImage() {
    image = null;
    update();
  }

  /// speech to text
  ///
  ///
  ///
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
    update();
  }

  void stopListening() async {
    await speechToText.stop();
    microphoneColor = Colors.grey.shade600;
    update();
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    _lastWords = result.recognizedWords;

    if (result.finalResult) {
      microphoneColor = Colors.grey.shade600;

      onSendPressed(_lastWords);
      update();
    }
  }

  onStartListening() {
    speechToText.isNotListening ? startListening() : stopListening();
  }

  //local database
  GetMessagesDbUseCase databaseUseCase =
      GetMessagesDbUseCase(HiveRepositoryImplementation());

  SaveMessageUseCase saveMessageUseCase =
      SaveMessageUseCase(HiveRepositoryImplementation());

  getMessages() async {
    var either = await databaseUseCase.call();
    either.fold((l) {
      update();
    }, (r) async {
      messages.addAll(r);
      update();
    });
  }

  saveMessages(MessageModel messageModel) async {
    await saveMessageUseCase.call(messageModel);
  }

  //tts
  FlutterTts? flutterTts;

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
    flutterTts = FlutterTts();
    flutterTts?.setCompletionHandler(() {
      speakerColor = Colors.grey.shade600;
      update();
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
          update();
          isSpeaking = true;
          await flutterTts!.speak(text);
        } else {
          speakerColor = Colors.grey.shade600;
          update();
          isSpeaking = false;
          flutterTts!.pause();
        }
      }
    }
  }

  @override
  void dispose() {
    super.dispose();
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
}
