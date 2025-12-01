/// Utility class to handle success and error cases in a type-safe way
///
/// Evaluate a function that may throw an exception and return a Result
///
/// Example:
///
/// ```dart
/// Result<List<Story>> result = await getListStories();
///
/// if (result is Ok<List<Story>>) {
///   final stories = result.value;
///   // Do something with the stories
/// } else if (result is Error<List<Story>>) {
///   final error = result.error;
///   // Handle the error
/// }
/// ```
sealed class Result<T> {
  const Result();
}

final class Ok<T> extends Result<T> {
  final T value;
  const Ok(this.value);
}

final class Error<T> extends Result<T> {
  final Exception error;
  const Error(this.error);
}
