import 'package:dartz/dartz.dart';

import '../../data/models/message_model.dart';
import '../repositories/hive_repository.dart';

class GetMessagesDbUseCase {
  final HiveRepository repository;

  GetMessagesDbUseCase(this.repository);

  Future<Either<String, List<MessageModel>>> call() async {
    return await repository.getMessages();
  }
}
