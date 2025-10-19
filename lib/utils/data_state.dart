import 'dart:developer';

import 'package:flutter/cupertino.dart';

abstract class DataState<T> {
  final T? _data;
  final int? _code;
  final String? _message;
  final Object? _error;

  const DataState({T? data, String? message, int? code, Object? error})
    : _data = data,
      _message = message,
      _error = error,
      _code = code;

  T? getData({
    Function(T)? onSuccess,
    Function()? onSuccessNoData,
    Function(String? error)? onFailure,
  }) {
    if (this is DataSuccess && _data != null) {
      if (onSuccess != null) {
        onSuccess(_data);
      }
      return _data as T;
    } else if (this is DataSuccess && _data == null) {
      if (onSuccessNoData != null) {
        onSuccessNoData();
      }
      return null;
    } else if (_error != null) {
      if (onFailure != null) {
        onFailure(_message);
      }
      throw _error;
    } else {
      throw Exception("${T.runtimeType} not found");
    }
  }

  void printError() {
    if (_error != null) {
      log("CAUGHT ERROR ON REPO HANDLER: $_error");
    }
  }

  String getMessage(String placeholder) {
    return _message ?? placeholder;
  }
}

class DataSuccess<T> extends DataState<T> {
  const DataSuccess(T data) : super(data: data);
}

class DataFailed<T> extends DataState<T> {
  const DataFailed(String message, {super.code, super.error})
    : super(message: message);
}
