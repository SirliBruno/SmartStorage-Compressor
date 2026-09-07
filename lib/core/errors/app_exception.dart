/// Sealed class hierarchy for typed application exceptions.
sealed class AppException implements Exception {
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppException(this.message, {this.cause, this.stackTrace});

  @override
  String toString() => 'AppException: $message (cause: $cause)';
}

/// Media library or file permission denied by user or OS.
class PermissionDeniedException extends AppException {
  final bool isPermanentlyDenied;

  const PermissionDeniedException({
    super.message = 'Media library permission was denied.',
    this.isPermanentlyDenied = false,
    super.cause,
    super.stackTrace,
  });
}

/// Storage capacity is insufficient for temp or final output.
class InsufficientStorageException extends AppException {
  final int requiredBytes;
  final int availableBytes;

  const InsufficientStorageException({
    required this.requiredBytes,
    required this.availableBytes,
    super.message = 'Insufficient storage to perform video compression.',
    super.cause,
    super.stackTrace,
  });
}

/// Video format, container, or codec is not supported by native hardware.
class UnsupportedCodecException extends AppException {
  final String codec;

  const UnsupportedCodecException({
    required this.codec,
    super.message = 'Unsupported video codec or profile.',
    super.cause,
    super.stackTrace,
  });
}

/// Native hardware compression failed during processing.
class CompressionFailedException extends AppException {
  final String? technicalDetails;

  const CompressionFailedException({
    this.technicalDetails,
    super.message = 'Hardware video compression failed.',
    super.cause,
    super.stackTrace,
  });
}

/// User explicitly aborted or cancelled the operation.
class OperationCancelledException extends AppException {
  const OperationCancelledException({
    super.message = 'Operation was cancelled by user.',
    super.cause,
    super.stackTrace,
  });
}

/// Deletion of asset failed (OS permission rejected or file locked).
class DeletionFailedException extends AppException {
  const DeletionFailedException({
    super.message = 'Failed to delete asset from media library.',
    super.cause,
    super.stackTrace,
  });
}

/// Free quota limit reached (3 compressions or 25 screenshots).
class QuotaExceededException extends AppException {
  final String feature;

  const QuotaExceededException({
    required this.feature,
    super.message = 'Free tier limit reached for this feature.',
    super.cause,
    super.stackTrace,
  });
}
