package com.example.service.impl;

import com.example.common.constants.ErrorCodes;
import com.example.common.dto.CreateUserRequest;
import com.example.common.dto.UpdateUserRequest;
import com.example.common.dto.UserResponse;
import com.example.common.entity.User;
import com.example.dao.UserMapper;
import com.example.service.UserService;
import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Implementation of UserService interface.
 *
 * <p>This service provides business logic for user management operations including validation,
 * password hashing, and data transformation between DTOs and entities.
 *
 * @author Claude Code
 * @since 1.0.0
 */
@Slf4j
@Service
@RequiredArgsConstructor
@Transactional(readOnly = true)
public class UserServiceImpl implements UserService {

  private final UserMapper userMapper;

  @Override
  @Transactional
  public UserResponse createUser(CreateUserRequest request, String createdBy) {
    log.info("Creating new user with username: {}", request.getUsername());

    // Validate username uniqueness
    if (existsByUsername(request.getUsername(), null)) {
      throw new IllegalArgumentException(
          "用户名已存在: " + request.getUsername() + " [" + ErrorCodes.USERNAME_ALREADY_EXISTS + "]");
    }

    // Validate email uniqueness
    if (existsByEmail(request.getEmail(), null)) {
      throw new IllegalArgumentException(
          "邮箱已存在: " + request.getEmail() + " [" + ErrorCodes.EMAIL_ALREADY_EXISTS + "]");
    }

    // Create user entity
    User user =
        User.builder()
            .username(request.getUsername())
            .email(request.getEmail())
            .fullName(request.getFullName())
            .passwordHash(hashPassword(request.getPassword()))
            .phoneNumber(request.getPhoneNumber())
            .isActive(true)
            .createdBy(createdBy)
            .updatedBy(createdBy)
            .version(1)
            .build();

    // Insert user
    int result = userMapper.insertUser(user);
    if (result != 1) {
      throw new RuntimeException("用户创建失败 [" + ErrorCodes.DATABASE_ERROR + "]");
    }

    log.info(
        "Successfully created user with ID: {} and username: {}", user.getId(), user.getUsername());
    return convertToResponse(user);
  }

  @Override
  public Optional<UserResponse> findUserById(Long id) {
    log.debug("Finding user by ID: {}", id);
    return userMapper.findById(id).map(this::convertToResponse);
  }

  @Override
  public Optional<UserResponse> findUserByUsername(String username) {
    log.debug("Finding user by username: {}", username);
    return userMapper.findByUsername(username).map(this::convertToResponse);
  }

  @Override
  public Optional<UserResponse> findUserByEmail(String email) {
    log.debug("Finding user by email: {}", email);
    return userMapper.findByEmail(email).map(this::convertToResponse);
  }

  @Override
  public List<UserResponse> findUsers(Boolean isActive, int page, int size) {
    log.debug("Finding users with isActive: {}, page: {}, size: {}", isActive, page, size);

    int offset = page * size;
    List<User> users = userMapper.findUsers(isActive, offset, size);

    return users.stream().map(this::convertToResponse).collect(Collectors.toList());
  }

  @Override
  public int countUsers(Boolean isActive) {
    log.debug("Counting users with isActive: {}", isActive);
    return userMapper.countUsers(isActive);
  }

  @Override
  @Transactional
  public UserResponse updateUser(Long id, UpdateUserRequest request, String updatedBy) {
    log.info("Updating user with ID: {}", id);

    // Find existing user
    User existingUser =
        userMapper
            .findById(id)
            .orElseThrow(
                () ->
                    new IllegalArgumentException(
                        "用户不存在: " + id + " [" + ErrorCodes.USER_NOT_FOUND + "]"));

    // Validate email uniqueness if email is being updated
    if (request.getEmail() != null
        && !request.getEmail().equals(existingUser.getEmail())
        && existsByEmail(request.getEmail(), id)) {
      throw new IllegalArgumentException(
          "邮箱已存在: " + request.getEmail() + " [" + ErrorCodes.EMAIL_ALREADY_EXISTS + "]");
    }

    // Build updated user entity (only set non-null fields)
    User updatedUser =
        User.builder()
            .id(id)
            .version(request.getVersion())
            .email(request.getEmail())
            .fullName(request.getFullName())
            .phoneNumber(request.getPhoneNumber())
            .passwordHash(
                request.getPassword() != null ? hashPassword(request.getPassword()) : null)
            .isActive(request.getIsActive())
            .updatedBy(updatedBy)
            .build();

    // Update user
    int result = userMapper.updateUser(updatedUser);
    if (result != 1) {
      throw new RuntimeException("用户更新失败，可能是版本冲突 [" + ErrorCodes.OPTIMISTIC_LOCKING_FAILURE + "]");
    }

    // Fetch and return updated user
    User refreshedUser =
        userMapper
            .findById(id)
            .orElseThrow(
                () -> new RuntimeException("更新后无法找到用户 [" + ErrorCodes.DATABASE_ERROR + "]"));

    log.info("Successfully updated user with ID: {}", id);
    return convertToResponse(refreshedUser);
  }

  @Override
  @Transactional
  public void deleteUser(Long id, Integer version, String deletedBy) {
    log.info("Soft deleting user with ID: {}", id);

    // Verify user exists
    if (!userMapper.findById(id).isPresent()) {
      throw new IllegalArgumentException("用户不存在: " + id + " [" + ErrorCodes.USER_NOT_FOUND + "]");
    }

    // Soft delete user
    int result = userMapper.softDeleteUser(id, version, deletedBy);
    if (result != 1) {
      throw new RuntimeException("用户删除失败，可能是版本冲突 [" + ErrorCodes.OPTIMISTIC_LOCKING_FAILURE + "]");
    }

    log.info("Successfully soft deleted user with ID: {}", id);
  }

  @Override
  public boolean existsByUsername(String username, Long excludeUserId) {
    return userMapper.existsByUsername(username, excludeUserId);
  }

  @Override
  public boolean existsByEmail(String email, Long excludeUserId) {
    return userMapper.existsByEmail(email, excludeUserId);
  }

  /**
   * Convert User entity to UserResponse DTO.
   *
   * @param user the user entity
   * @return user response DTO
   */
  private UserResponse convertToResponse(User user) {
    return UserResponse.builder()
        .id(user.getId())
        .username(user.getUsername())
        .email(user.getEmail())
        .fullName(user.getFullName())
        .phoneNumber(user.getPhoneNumber())
        .isActive(user.getIsActive())
        .createdAt(user.getCreatedAt())
        .updatedAt(user.getUpdatedAt())
        .createdBy(user.getCreatedBy())
        .updatedBy(user.getUpdatedBy())
        .version(user.getVersion())
        .build();
  }

  /**
   * Hash password using a secure hashing algorithm. In a real application, this should use BCrypt
   * or similar.
   *
   * @param password the plain text password
   * @return the hashed password
   */
  private String hashPassword(String password) {
    // FUTURE ENHANCEMENT: In production, use BCrypt or similar secure hashing
    // For now, using a simple hash for demonstration
    return "HASHED_" + password.hashCode() + "_" + System.currentTimeMillis();
  }
}
