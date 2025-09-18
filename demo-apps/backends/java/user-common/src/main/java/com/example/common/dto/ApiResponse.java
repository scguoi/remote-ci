package com.example.common.dto;

import com.fasterxml.jackson.annotation.JsonInclude;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Generic API response wrapper.
 *
 * <p>This class provides a consistent structure for all API responses, including success/error
 * status, message, and optional data payload.
 *
 * @param <T> The type of data payload
 * @author Claude Code
 * @since 1.0.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
@JsonInclude(JsonInclude.Include.NON_NULL)
public class ApiResponse<T> {

  /** Indicates whether the operation was successful. */
  private Boolean success;

  /** Human-readable message describing the result. */
  private String message;

  /** Optional data payload (only included for successful responses). */
  private T data;

  /** Optional error code for failed responses. */
  private String errorCode;

  /** Timestamp when the response was generated. */
  private Long timestamp;

  /**
   * Creates a successful response with data.
   *
   * @param data the response data
   * @param message success message
   * @param <T> type of response data
   * @return successful API response
   */
  public static <T> ApiResponse<T> success(T data, String message) {
    return ApiResponse.<T>builder()
        .success(true)
        .message(message)
        .data(data)
        .timestamp(System.currentTimeMillis())
        .build();
  }

  /**
   * Creates a successful response without data.
   *
   * @param message success message
   * @param <T> type of response data
   * @return successful API response
   */
  public static <T> ApiResponse<T> success(String message) {
    return ApiResponse.<T>builder()
        .success(true)
        .message(message)
        .timestamp(System.currentTimeMillis())
        .build();
  }

  /**
   * Creates an error response.
   *
   * @param message error message
   * @param errorCode error code
   * @param <T> type of response data
   * @return error API response
   */
  public static <T> ApiResponse<T> error(String message, String errorCode) {
    return ApiResponse.<T>builder()
        .success(false)
        .message(message)
        .errorCode(errorCode)
        .timestamp(System.currentTimeMillis())
        .build();
  }

  /**
   * Creates an error response without error code.
   *
   * @param message error message
   * @param <T> type of response data
   * @return error API response
   */
  public static <T> ApiResponse<T> error(String message) {
    return error(message, null);
  }
}
