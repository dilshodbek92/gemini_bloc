import 'package:hive/hive.dart';

part 'message_model.g.dart';

@HiveType(typeId: 0)
class MessageModel extends HiveObject {
  int? id;
  @HiveField(0)
  bool? isMine;

  @HiveField(1)
  String? message;

  @HiveField(3)
  String? base64Image;

  MessageModel({this.isMine, this.message, this.base64Image});

  MessageModel.fromMap(Map<String, dynamic> json)
      : id = json['id'],
        isMine = json['isMine'],
        message = json['message'],
        base64Image = json['base64image'];

  Map<String, dynamic> toMap() => {
        'id': id,
        "isMine": isMine,
        'message': message,
        'base64Image': base64Image
      };
}
