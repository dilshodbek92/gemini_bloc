import 'dart:convert';

import 'package:flutter/material.dart';

import '../../data/models/message_model.dart';

Widget itemOfUserMessage(MessageModel message) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.end,
    children: [
      Column(
        children: [
          Container(
            margin: const EdgeInsets.all(10),
            padding: const EdgeInsets.all(10),
            constraints: const BoxConstraints(maxWidth: 300),
            decoration: const BoxDecoration(
                color: Color.fromRGBO(38, 39, 42, 1),
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(25),
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                    topRight: Radius.circular(4))),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.message!,
                  overflow: TextOverflow.visible,
                  style: const TextStyle(color: Colors.grey, fontSize: 16),
                ),
                message.base64Image != null && message.base64Image!.isNotEmpty
                    ? Container(
                        padding: const EdgeInsets.only(top: 16, bottom: 6),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.memory(
                            base64Decode(message.base64Image!),
                          ),
                        ),
                      )
                    : const SizedBox.shrink()
              ],
            ),
          ),
        ],
      ),
    ],
  );
}
