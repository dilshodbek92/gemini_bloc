import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

import '../../core/services/utils_service.dart';
import '../bloc/home/home_bloc.dart';
import '../widgets/item_gemini_message.dart';
import '../widgets/item_user_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late HomeBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<HomeBloc>(context);
    bloc.add(HomeLoadMessagesEvent());
    bloc.initSpeech();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            centerTitle: true,
            backgroundColor: Colors.black,
            title: SizedBox(
              width: 130,
              child: Lottie.asset("assets/animations/gemini_logo.json"),
            ),
            actions: [
              GestureDetector(
                onTap: () {
                  Utils.dialogCommon(
                    context,
                    "Log out",
                    "Do you want to log out",
                    false,
                    () => {bloc.callSignOut(context)},
                  );
                },
                child: const ClipRRect(
                  borderRadius: BorderRadius.all(Radius.circular(15)),
                  child: Image(
                    image: AssetImage("assets/images/ic_person.png"),
                    width: 30,
                    height: 30,
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              )
            ],
          ),
          body: Container(
            //margin: const EdgeInsets.only(top: 10),
            padding: const EdgeInsets.all(10),
            width: double.infinity,
            child: Column(
              children: [
                Expanded(
                  child: Stack(
                    children: [
                      ListView.builder(
                        controller: bloc.scrollController,
                        itemCount: bloc.messages.length,
                        itemBuilder: (context, index) {
                          var message = bloc.messages[index];
                          return message.isMine!
                              ? itemOfUserMessage(message)
                              : itemOfGeminiMessage(message, bloc, context);
                        },
                      ),
                      state is HomeLoadingState
                          ? Center(
                              child: SizedBox(
                                height: 70,
                                child: Lottie.asset(
                                    'assets/animations/gemini_buffering.json'),
                              ),
                            )
                          : const SizedBox.shrink()
                    ],
                  ),
                ),
                const SizedBox(
                  height: 5,
                ),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 15),
                  padding: const EdgeInsets.only(left: 20),
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      border:
                          Border.all(width: 2, color: Colors.grey.shade600)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      bloc.image != null
                          ? Stack(
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(
                                      top: 16, bottom: 16),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.memory(
                                      base64Decode(
                                        bloc.image!,
                                      ),
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    ),
                                  ),
                                ),
                                Container(
                                  height: 100,
                                  width: 100,
                                  padding:
                                      const EdgeInsets.only(right: 10, top: 20),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      GestureDetector(
                                        onTap: () {
                                          bloc.add(HomeRemoveImageEvent());
                                        },
                                        child: const Icon(
                                            CupertinoIcons.xmark_circle_fill),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            )
                          : SizedBox(),
                      Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: bloc.textController,
                              onSubmitted: (text) {
                                var text =
                                    bloc.textController.text.toString().trim();
                                bloc.add(HomeSendEvent(message: text));
                              },
                              maxLines: null,
                              textInputAction: TextInputAction.send,
                              cursorColor: Colors.white,
                              style: const TextStyle(color: Colors.white),
                              keyboardType: TextInputType.text,
                              decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Message",
                                  hintStyle:
                                      TextStyle(color: Colors.grey.shade600)),
                            ),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: Icon(Icons.attach_file,
                                    color: Colors.grey.shade600),
                                onPressed: () {
                                  bloc.add(HomeChooseImageEvent());
                                },
                              ),
                              IconButton(
                                color: bloc.microphoneColor,
                                icon: const Icon(
                                  Icons.mic,
                                ),
                                onPressed: () {
                                  bloc.onStartListening();
                                },
                              ),
                              IconButton(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: -10),
                                icon: Icon(
                                  Icons.send,
                                  color: Colors.grey.shade600,
                                ),
                                onPressed: () {
                                  var text = bloc.textController.text
                                      .toString()
                                      .trim();
                                  bloc.add(HomeSendEvent(
                                      message: text, base64Image: bloc.image));
                                },
                              ),
                            ],
                          )
                        ],
                      ),
                    ],
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
