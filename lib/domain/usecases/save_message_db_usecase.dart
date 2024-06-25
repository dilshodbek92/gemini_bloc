import '../../data/models/message_model.dart';
import '../repositories/hive_repository.dart';

class SaveMessageUseCase {
  final HiveRepository repository;

  SaveMessageUseCase(this.repository);

  Future call(MessageModel messageModel) async {
    await repository.saveMessage(messageModel);
  }
}
