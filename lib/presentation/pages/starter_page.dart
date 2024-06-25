import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';
import 'package:video_player/video_player.dart';

import '../../core/constants/welcoming.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/log_service.dart';
import '../bloc/starter/starter_bloc.dart';

class StarterPage extends StatefulWidget {
  const StarterPage({super.key});

  @override
  State<StarterPage> createState() => _StarterPageState();
}

class _StarterPageState extends State<StarterPage> {
  late StarterBloc bloc;

  @override
  void initState() {
    super.initState();
    bloc = BlocProvider.of<StarterBloc>(context);
    bloc.initVideoController();
    bloc.add(StarterVideoEvent());
    bloc.speak(WELCOMING_MESSAGE);
    LogService.i(AuthService.isLoggedIn().toString());
  }


  @override
  Widget build(BuildContext context) {
    return BlocBuilder<StarterBloc, StarterState>(
      builder: (context, state) {
        return Scaffold(
          backgroundColor: Colors.black,
          body: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            margin: const EdgeInsets.only(bottom: 20),
            child: Column(children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Lottie.asset("assets/animations/gemini_logo.json"),
              ),
              Expanded(
                child: bloc.controller.value.isInitialized
                    ? VideoPlayer(bloc.controller)
                    : Container(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(30),
                        border: Border.all(color: Colors.white, width: 2)),
                    child: AuthService.isLoggedIn()
                        ? MaterialButton(
                            onPressed: () {
                              bloc.callHomePage(context);
                              //bloc.callGoogleSignIn(context);
                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Chat with gemini'.toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                const Icon(
                                  Icons.arrow_forward,
                                  color: Colors.white,
                                )
                              ],
                            ))
                        : MaterialButton(
                            onPressed: () {
                              //bloc.callHomePage(context);

                               bloc.callGoogleSignIn(context);

                            },
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Image(
                                  height: 25,
                                  width: 25,
                                  image: AssetImage(
                                      "assets/images/google_logo.png"),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Text(
                                  'Sign in with google'.toUpperCase(),
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            )),
                  ),
                ],
              ),
            ],
            ),
          ),
        );
      },
    );
  }
}
