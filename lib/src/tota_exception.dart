/// Exception raised when there's an internal or user error.
class TotaException implements Exception {
  final String message;

  TotaException(this.message);

  @override
  String toString() => 'TotaException: ${this.message}';
}

/// Exception raised when file is not found at [path].
TotaException fileNotFoundException(String path) =>
    TotaException('file not found: `$path`');

/// Exception raised when a file already exists at [path].
TotaException fileAlreadyExistsException(String path) =>
    TotaException('file already exists: `$path`');