import 'package:freezed_annotation/freezed_annotation.dart';

part 'Result.freezed.dart';

@freezed
abstract class Result<T> with _$Result<T> {
  const factory Result.idle() = Idle<T>;

  const factory Result.loading() = Loading<T>;

  const factory Result.success({required T data}) = Success<T>;

  const factory Result.failure({required String reason}) = Failure<T>;
}
