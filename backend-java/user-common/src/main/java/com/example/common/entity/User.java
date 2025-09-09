package com.example.common.entity;

import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * User entity representing the user table in database.
 *
 * <p>This entity maps to the 'users' table and contains all user-related information including
 * personal details, authentication info, and audit fields.
 *
 * @author Claude Code
 * @since 1.0.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class User {

  /** Primary key - unique identifier for the user. */
  private Long id;

  /** Unique username for login purposes. */
  private String username;

  /** User's email address (unique). */
  private String email;

  /** User's full name for display purposes. */
  private String fullName;

  /** Encrypted password hash (never expose in APIs). */
  private String passwordHash;

  /** User's phone number (optional). */
  private String phoneNumber;

  /** User account status - true if active, false if disabled. */
  private Boolean isActive;

  /** Timestamp when the user account was created. */
  private LocalDateTime createdAt;

  /** Timestamp when the user account was last updated. */
  private LocalDateTime updatedAt;

  /** User who created this record (for audit purposes). */
  private String createdBy;

  /** User who last updated this record (for audit purposes). */
  private String updatedBy;

  /** Version field for optimistic locking. */
  private Integer version;
}
