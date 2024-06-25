import 'package:flutter/material.dart';
import 'package:flutter_linkify/flutter_linkify.dart';

import '../../data/models/message_model.dart';
import '../bloc/home/home_bloc.dart';
import '../pages/web_page.dart';

Widget itemOfGeminiMessage(
    MessageModel message, HomeBloc bloc, BuildContext context) {
  return Container(
    margin: const EdgeInsets.only(top: 20),
    padding: const EdgeInsets.all(16),
    width: double.infinity,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          SizedBox(
            width: 24,
            child: Image.asset('assets/images/gemini_icon.png'),
          ),
          GestureDetector(
            onTap: () {
              //controller.speak(message.message);
              bloc.speak(message.message);
            },
            child: const Icon(
              color: Colors.grey,
              Icons.volume_up,
              //color: controller.speakerColor ,
            ),
          )
        ]),
        Container(
          alignment: Alignment.topLeft,
          padding: const EdgeInsets.only(top: 16),
          child: Linkify(
            onOpen: (link) {
              Navigator.push(context,
                  MaterialPageRoute(builder: (BuildContext context) {
                return WebPage(url: link.url);
              }));
            },
            text: message.message!,
            style: const TextStyle(
                color: Color.fromRGBO(173, 173, 176, 1), fontSize: 16),
          ),
        ),
      ],
    ),
  );
}
