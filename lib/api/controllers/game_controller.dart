import 'dart:developer';

import 'package:get/get.dart';
import 'package:utilities/api/models/game_model.dart';
import 'package:utilities/api/repositories/game_repository.dart';
import 'package:utilities/utils/controller_utils.dart';

class GameController extends GetxController {
  final TestRepository _repo = TestRepository();

  // ============================================= State
  final Rx<TestState> _state = TestState.initial().obs;
  List<GameModel> get games => _state.value.games;
  String get errorMessage => _state.value.errorMessage;
  ControllerStatus get status => _state.value.status;

  bool get isInitial => status == ControllerStatus.initial;
  bool get isLoading => status == ControllerStatus.loading;
  bool get isSuccess => status == ControllerStatus.success;
  bool get isUpdated => status == ControllerStatus.updated;
  bool get isCreated => status == ControllerStatus.created;
  bool get isFailure => status == ControllerStatus.failure;

  void _failure(String message) {
    _state.value = TestState.failure(
      games: _state.value.games,
      errorMessage: message,
    );
  }

  void _update(GameModel game) {
    List<GameModel> updated = [];
    for (var old in _state.value.games) {
      if (game.id == old.id) {
        updated.add(game);
      } else {
        updated.add(old);
      }
    }

    _state.value = TestState.updated(games: updated);
  }

  // ============================================= Methods
  Future<void> getGames() async {
    try {
      _state.value = TestState.loading();
      final getState = await _repo.getGames();

      getState.getData(
        onSuccess: (data) {
          _state.value = TestState.success(data);
        },
        onFailure: (error) => _state.value = TestState.failure(
          games: _state.value.games,
          errorMessage: error ?? "Something went wrong",
        ),
      );
    } catch (e) {
      log(e.toString());
      _failure(e.toString());
    }
  }
}

class TestState {
  final List<GameModel> _games;
  final String _errorMessage;
  final ControllerStatus _status;

  List<GameModel> get games => List.unmodifiable(_games);

  String get errorMessage => _errorMessage;

  ControllerStatus get status => _status;

  TestState.initial({
    List<GameModel> games = const [],
    String errorMessage = "",
  }) : _games = games,
       _errorMessage = errorMessage,
       _status = ControllerStatus.initial;

  TestState.loading({
    List<GameModel> games = const [],
    String errorMessage = "",
  }) : _games = games,
       _errorMessage = errorMessage,
       _status = ControllerStatus.loading;

  TestState.success(List<GameModel> games, {String errorMessage = ""})
    : _games = games,
      _errorMessage = errorMessage,
      _status = ControllerStatus.success;

  TestState.updated({
    List<GameModel> games = const [],
    String errorMessage = "",
  }) : _games = games,
       _errorMessage = errorMessage,
       _status = ControllerStatus.updated;

  TestState.created({
    List<GameModel> games = const [],
    String errorMessage = "",
  }) : _games = games,
       _errorMessage = errorMessage,
       _status = ControllerStatus.created;

  TestState.failure({
    List<GameModel> games = const [],
    String errorMessage = "",
  }) : _games = games,
       _errorMessage = errorMessage,
       _status = ControllerStatus.failure;
}
