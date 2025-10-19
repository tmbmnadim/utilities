import 'package:utilities/cat_fact_model.dart';
import 'package:utilities/sources/test_source.dart';
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
