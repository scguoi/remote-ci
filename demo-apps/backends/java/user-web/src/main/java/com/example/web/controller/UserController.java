package com.example.web.controller;

import com.example.common.constants.ErrorCodes;
import com.example.common.dto.ApiResponse;
import com.example.common.dto.CreateUserRequest;
import com.example.common.dto.UpdateUserRequest;
import com.example.common.dto.UserResponse;
import com.example.service.UserService;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotNull;
import java.util.List;
import java.util.Optional;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

/**
 * REST Controller for user management operations.
 *
 * <p>This controller provides HTTP endpoints for CRUD operations on users, including pagination,
 * filtering, and proper error handling with consistent API responses.
 *
 * @author Claude Code
 * @since 1.0.0
 */
@Slf4j
@RestController
@RequestMapping("/api/v1/users")
@RequiredArgsConstructor
@Validated
public class UserController {

  private final UserService userService;

  /**
   * Create a new user.
   *
   * @param request the user creation request
   * @return API response with created user data
   */
  @PostMapping
  public ResponseEntity<ApiResponse<UserResponse>> createUser(
      @Valid @RequestBody CreateUserRequest request) {
    log.info("Creating user with username: {}", request.getUsername());

    try {
      UserResponse user = userService.createUser(request, "api-user");
      return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.success(user, "用户创建成功"));
    } catch (IllegalArgumentException e) {
      log.warn("User creation failed: {}", e.getMessage());
      return ResponseEntity.status(HttpStatus.CONFLICT)
          .body(ApiResponse.error(e.getMessage(), ErrorCodes.USER_ALREADY_EXISTS));
    } catch (Exception e) {
      log.error("Unexpected error during user creation", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("用户创建失败", ErrorCodes.INTERNAL_SERVER_ERROR));
    }
  }

  /**
   * Get a user by ID.
   *
   * @param id the user ID
   * @return API response with user data or 404 if not found
   */
  @GetMapping("/{id}")
  public ResponseEntity<ApiResponse<UserResponse>> getUserById(
      @PathVariable @NotNull @Min(1) Long id) {
    log.info("Fetching user with ID: {}", id);

    Optional<UserResponse> user = userService.findUserById(id);
    if (user.isPresent()) {
      return ResponseEntity.ok(ApiResponse.success(user.get(), "用户查询成功"));
    } else {
      return ResponseEntity.status(HttpStatus.NOT_FOUND)
          .body(ApiResponse.error("用户不存在", ErrorCodes.USER_NOT_FOUND));
    }
  }

  /**
   * Get a user by username.
   *
   * @param username the username
   * @return API response with user data or 404 if not found
   */
  @GetMapping("/username/{username}")
  public ResponseEntity<ApiResponse<UserResponse>> getUserByUsername(
      @PathVariable @NotNull String username) {
    log.info("Fetching user with username: {}", username);

    Optional<UserResponse> user = userService.findUserByUsername(username);
    if (user.isPresent()) {
      return ResponseEntity.ok(ApiResponse.success(user.get(), "用户查询成功"));
    } else {
      return ResponseEntity.status(HttpStatus.NOT_FOUND)
          .body(ApiResponse.error("用户不存在", ErrorCodes.USER_NOT_FOUND));
    }
  }

  /**
   * Get a paginated list of users with optional filtering.
   *
   * @param isActive filter by active status (optional)
   * @param page page number (default: 0)
   * @param size page size (default: 10, max: 100)
   * @return API response with list of users
   */
  @GetMapping
  public ResponseEntity<ApiResponse<List<UserResponse>>> getUsers(
      @RequestParam(required = false) Boolean isActive,
      @RequestParam(defaultValue = "0") @Min(0) int page,
      @RequestParam(defaultValue = "10") @Min(1) int size) {

    // Limit page size to prevent abuse
    size = Math.min(size, 100);

    log.info("Fetching users with isActive: {}, page: {}, size: {}", isActive, page, size);

    try {
      List<UserResponse> users = userService.findUsers(isActive, page, size);
      int totalCount = userService.countUsers(isActive);

      log.info(
          "Found {} users (page {}/{}, total: {})",
          users.size(),
          page + 1,
          (totalCount + size - 1) / size,
          totalCount);

      return ResponseEntity.ok(
          ApiResponse.success(users, String.format("用户列表查询成功，共%d条记录，第%d页", totalCount, page + 1)));
    } catch (Exception e) {
      log.error("Error fetching users", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("用户列表查询失败", ErrorCodes.INTERNAL_SERVER_ERROR));
    }
  }

  /**
   * Update an existing user.
   *
   * @param id the user ID
   * @param request the update request
   * @return API response with updated user data
   */
  @PutMapping("/{id}")
  public ResponseEntity<ApiResponse<UserResponse>> updateUser(
      @PathVariable @NotNull @Min(1) Long id, @Valid @RequestBody UpdateUserRequest request) {
    log.info("Updating user with ID: {}", id);

    try {
      UserResponse user = userService.updateUser(id, request, "api-user");
      return ResponseEntity.ok(ApiResponse.success(user, "用户更新成功"));
    } catch (IllegalArgumentException e) {
      log.warn("User update failed: {}", e.getMessage());
      if (e.getMessage().contains(ErrorCodes.USER_NOT_FOUND)) {
        return ResponseEntity.status(HttpStatus.NOT_FOUND)
            .body(ApiResponse.error(e.getMessage(), ErrorCodes.USER_NOT_FOUND));
      } else {
        return ResponseEntity.status(HttpStatus.CONFLICT)
            .body(ApiResponse.error(e.getMessage(), ErrorCodes.EMAIL_ALREADY_EXISTS));
      }
    } catch (RuntimeException e) {
      log.warn("User update failed due to optimistic locking: {}", e.getMessage());
      return ResponseEntity.status(HttpStatus.CONFLICT)
          .body(ApiResponse.error(e.getMessage(), ErrorCodes.OPTIMISTIC_LOCKING_FAILURE));
    } catch (Exception e) {
      log.error("Unexpected error during user update", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("用户更新失败", ErrorCodes.INTERNAL_SERVER_ERROR));
    }
  }

  /**
   * Soft delete a user.
   *
   * @param id the user ID
   * @param version the version for optimistic locking
   * @return API response confirming deletion
   */
  @DeleteMapping("/{id}")
  public ResponseEntity<ApiResponse<Void>> deleteUser(
      @PathVariable @NotNull @Min(1) Long id, @RequestParam @NotNull @Min(1) Integer version) {
    log.info("Deleting user with ID: {} and version: {}", id, version);

    try {
      userService.deleteUser(id, version, "api-user");
      return ResponseEntity.ok(ApiResponse.success("用户删除成功"));
    } catch (IllegalArgumentException e) {
      log.warn("User deletion failed: {}", e.getMessage());
      return ResponseEntity.status(HttpStatus.NOT_FOUND)
          .body(ApiResponse.error(e.getMessage(), ErrorCodes.USER_NOT_FOUND));
    } catch (RuntimeException e) {
      log.warn("User deletion failed due to optimistic locking: {}", e.getMessage());
      return ResponseEntity.status(HttpStatus.CONFLICT)
          .body(ApiResponse.error(e.getMessage(), ErrorCodes.OPTIMISTIC_LOCKING_FAILURE));
    } catch (Exception e) {
      log.error("Unexpected error during user deletion", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("用户删除失败", ErrorCodes.INTERNAL_SERVER_ERROR));
    }
  }

  /**
   * Check if a username exists.
   *
   * @param username the username to check
   * @return API response with boolean result
   */
  @GetMapping("/check-username/{username}")
  public ResponseEntity<ApiResponse<Boolean>> checkUsername(
      @PathVariable @NotNull String username) {
    log.info("Checking if username exists: {}", username);

    try {
      boolean exists = userService.existsByUsername(username, null);
      return ResponseEntity.ok(ApiResponse.success(exists, exists ? "用户名已存在" : "用户名可用"));
    } catch (Exception e) {
      log.error("Error checking username", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("用户名检查失败", ErrorCodes.INTERNAL_SERVER_ERROR));
    }
  }

  /**
   * Check if an email exists.
   *
   * @param email the email to check
   * @return API response with boolean result
   */
  @GetMapping("/check-email")
  public ResponseEntity<ApiResponse<Boolean>> checkEmail(@RequestParam @NotNull String email) {
    log.info("Checking if email exists: {}", email);

    try {
      boolean exists = userService.existsByEmail(email, null);
      return ResponseEntity.ok(ApiResponse.success(exists, exists ? "邮箱已存在" : "邮箱可用"));
    } catch (Exception e) {
      log.error("Error checking email", e);
      return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
          .body(ApiResponse.error("邮箱检查失败", ErrorCodes.INTERNAL_SERVER_ERROR));
    }
  }
}
