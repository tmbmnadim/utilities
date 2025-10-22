import 'package:utilities/api/models/game_model.dart';
import 'package:utilities/api/sources/game_source.dart';
import 'package:utilities/utils/data_state.dart';
import 'package:utilities/utils/repository_error_handler.dart';

class TestRepository {
  final TestSource _testSource = TestSource();
  

  Future<DataState<List<GameModel>>> getGames() async {
    return RepositoryErrorHandler.call(
      network: _testSource.getGames,
      proxyMessage: "Failed to get games!",
    );
  }
}
