package com.example.common.constants;

/**
 * Application-wide error codes for consistent error handling.
 *
 * <p>These constants define standardized error codes used throughout the application for better
 * error tracking and client-side handling.
 *
 * @author Claude Code
 * @since 1.0.0
 */
public final class ErrorCodes {

  /** User-related error codes. */
  public static final String USER_NOT_FOUND = "USER_NOT_FOUND";

  public static final String USER_ALREADY_EXISTS = "USER_ALREADY_EXISTS";
  public static final String INVALID_USER_ID = "INVALID_USER_ID";
  public static final String USERNAME_ALREADY_EXISTS = "USERNAME_ALREADY_EXISTS";
  public static final String EMAIL_ALREADY_EXISTS = "EMAIL_ALREADY_EXISTS";

  /** Validation error codes. */
  public static final String VALIDATION_FAILED = "VALIDATION_FAILED";

  public static final String INVALID_REQUEST_FORMAT = "INVALID_REQUEST_FORMAT";
  public static final String MISSING_REQUIRED_FIELD = "MISSING_REQUIRED_FIELD";

  /** Database operation error codes. */
  public static final String DATABASE_ERROR = "DATABASE_ERROR";

  public static final String OPTIMISTIC_LOCKING_FAILURE = "OPTIMISTIC_LOCKING_FAILURE";
  public static final String CONSTRAINT_VIOLATION = "CONSTRAINT_VIOLATION";

  /** General application error codes. */
  public static final String INTERNAL_SERVER_ERROR = "INTERNAL_SERVER_ERROR";

  public static final String OPERATION_NOT_PERMITTED = "OPERATION_NOT_PERMITTED";
  public static final String RESOURCE_CONFLICT = "RESOURCE_CONFLICT";

  // Private constructor to prevent instantiation
  private ErrorCodes() {
    throw new UnsupportedOperationException("This is a utility class and cannot be instantiated");
  }
}
