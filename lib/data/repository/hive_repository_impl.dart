import 'package:dartz/dartz.dart';

import '../../domain/repositories/hive_repository.dart';
import '../datasources/local/no_sql.dart';
import '../models/message_model.dart';

class HiveRepositoryImplementation extends HiveRepository {
  @override
  Future<Either<String, List<MessageModel>>> getMessages() async {
    try {
      var messages = HiveService.getMessages();
      return Right(messages);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<void> saveMessage(MessageModel messageModel) async {
    HiveService.saveMessage(messageModel);
  }
}
