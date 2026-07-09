sealed class ApiResult<T> {
  const ApiResult();
}

class ApiResultSuccess<T> extends ApiResult<T> {
  final T data;
  const ApiResultSuccess(this.data);
}

class ApiResultFailure<T> extends ApiResult<T> {
  final String errorMessage;
  final Object? exception;
  const ApiResultFailure(this.errorMessage, [this.exception]);
}

class ApiResultLoading<T> extends ApiResult<T> {
  const ApiResultLoading();
}
