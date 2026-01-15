import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_exception.freezed.dart';

@freezed
class ApiException with _$ApiException implements Exception {
  const factory ApiException.network({String? message}) = NetworkException;
  const factory ApiException.timeout({String? message}) = TimeoutException;
  const factory ApiException.unauthorized({String? message}) = UnauthorizedException;
  const factory ApiException.forbidden({String? message}) = ForbiddenException;
  const factory ApiException.notFound({String? message}) = NotFoundException;
  const factory ApiException.server({String? message, int? statusCode}) = ServerException;
  const factory ApiException.unknown({String? message}) = UnknownException;
}

ApiException mapStatusCodeToException(int statusCode, {String? message}) {
  switch (statusCode) {
    case 401:
      return ApiException.unauthorized(message: message);
    case 403:
      return ApiException.forbidden(message: message);
    case 404:
      return ApiException.notFound(message: message);
    case >= 500:
      return ApiException.server(message: message, statusCode: statusCode);
    default:
      return ApiException.unknown(message: message);
  }
}
