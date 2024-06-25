import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../../models/message_model.dart';

class HiveService {
  static const DB_NAME = "gemini_db";
  static var box = Hive.box(DB_NAME);

  static init() async {
    var appDocumentary = await getApplicationDocumentsDirectory();
    Hive
      ..init(appDocumentary.path)
      ..registerAdapter(MessageModelAdapter());
    await Hive.openBox(DB_NAME);
  }

  static saveMessage(MessageModel message) async {
    box.add(message);
  }

  static List<MessageModel> getMessages() {
    List<MessageModel> messages = [];
    for (var i = 0; i < box.length; i++) {
      messages.add(box.getAt(i));
    }
    return messages;
  }


}
