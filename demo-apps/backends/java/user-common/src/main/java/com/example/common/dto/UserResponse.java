package com.example.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import java.time.LocalDateTime;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Response DTO for user information.
 *
 * <p>This class represents user data returned by API endpoints. Sensitive information like password
 * hash is excluded from this DTO.
 *
 * @author Claude Code
 * @since 1.0.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UserResponse {

  /** Unique identifier for the user. */
  private Long id;

  /** Username for display and identification. */
  private String username;

  /** User's email address. */
  private String email;

  /** User's full name. */
  @JsonProperty("full_name")
  private String fullName;

  /** User's phone number. */
  @JsonProperty("phone_number")
  private String phoneNumber;

  /** Account status indicator. */
  @JsonProperty("is_active")
  private Boolean isActive;

  /** Account creation timestamp. */
  @JsonProperty("created_at")
  private LocalDateTime createdAt;

  /** Last update timestamp. */
  @JsonProperty("updated_at")
  private LocalDateTime updatedAt;

  /** User who created this account. */
  @JsonProperty("created_by")
  private String createdBy;

  /** User who last updated this account. */
  @JsonProperty("updated_by")
  private String updatedBy;

  /** Version for optimistic locking. */
  private Integer version;
}
