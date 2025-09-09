package com.example.service;

import com.example.common.dto.CreateUserRequest;
import com.example.common.dto.UpdateUserRequest;
import com.example.common.dto.UserResponse;
import java.util.List;
import java.util.Optional;

/**
 * Service interface for user management operations.
 *
 * <p>This interface defines all business operations for user management including CRUD operations,
 * validation, and business rules enforcement.
 *
 * @author Claude Code
 * @since 1.0.0
 */
public interface UserService {

  /**
   * Create a new user.
   *
   * @param request the user creation request containing user details
   * @param createdBy the username of the user creating this record
   * @return the created user response
   * @throws IllegalArgumentException if username or email already exists
   * @throws RuntimeException if user creation fails
   */
  UserResponse createUser(CreateUserRequest request, String createdBy);

  /**
   * Find a user by their unique ID.
   *
   * @param id the user ID
   * @return Optional containing the user if found, empty otherwise
   */
  Optional<UserResponse> findUserById(Long id);

  /**
   * Find a user by their username.
   *
   * @param username the username to search for
   * @return Optional containing the user if found, empty otherwise
   */
  Optional<UserResponse> findUserByUsername(String username);

  /**
   * Find a user by their email address.
   *
   * @param email the email address to search for
   * @return Optional containing the user if found, empty otherwise
   */
  Optional<UserResponse> findUserByEmail(String email);

  /**
   * Get a paginated list of users with optional filtering by active status.
   *
   * @param isActive filter by active status (null to get all users)
   * @param page page number (0-based)
   * @param size page size
   * @return list of users matching the criteria
   */
  List<UserResponse> findUsers(Boolean isActive, int page, int size);

  /**
   * Count total number of users with optional filtering by active status.
   *
   * @param isActive filter by active status (null to count all users)
   * @return total count of users
   */
  int countUsers(Boolean isActive);

  /**
   * Update an existing user.
   *
   * @param id the user ID
   * @param request the update request containing fields to update
   * @param updatedBy the username of the user performing the update
   * @return the updated user response
   * @throws IllegalArgumentException if user not found or email already exists
   * @throws RuntimeException if optimistic locking fails or update fails
   */
  UserResponse updateUser(Long id, UpdateUserRequest request, String updatedBy);

  /**
   * Soft delete a user (set is_active to false).
   *
   * @param id the user ID
   * @param version the current version for optimistic locking
   * @param deletedBy the username of the user performing the deletion
   * @throws IllegalArgumentException if user not found
   * @throws RuntimeException if optimistic locking fails or deletion fails
   */
  void deleteUser(Long id, Integer version, String deletedBy);

  /**
   * Check if a username already exists.
   *
   * @param username the username to check
   * @param excludeUserId optional user ID to exclude from the check (for updates)
   * @return true if username exists, false otherwise
   */
  boolean existsByUsername(String username, Long excludeUserId);

  /**
   * Check if an email already exists.
   *
   * @param email the email to check
   * @param excludeUserId optional user ID to exclude from the check (for updates)
   * @return true if email exists, false otherwise
   */
  boolean existsByEmail(String email, Long excludeUserId);
}
