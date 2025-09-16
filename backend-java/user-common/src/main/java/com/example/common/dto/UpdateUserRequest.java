package com.example.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for updating an existing user.
 *
 * <p>This class contains optional fields for user updates. Only non-null fields will be updated in
 * the database.
 *
 * @author Claude Code
 * @since 1.0.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class UpdateUserRequest {

  /** Updated email address (optional). */
  @Email(message = "Invalid email format")
  @Size(max = 100, message = "Email length cannot exceed 100 characters")
  private String email;

  /** Updated full name (optional). */
  @Size(min = 2, max = 100, message = "Full name length must be between 2-100 characters")
  @JsonProperty("full_name")
  private String fullName;

  /** Updated phone number (optional). */
  @Pattern(regexp = "^(\\+?86)?1[3-9]\\d{9}$|^$", message = "Invalid phone number format")
  @JsonProperty("phone_number")
  private String phoneNumber;

  /** Updated password (optional, 8-128 characters with letters and numbers). */
  @Size(min = 8, max = 128, message = "Password length must be between 8-128 characters")
  @Pattern(
      regexp = "^(?=.*[a-zA-Z])(?=.*\\d).*$",
      message = "Password must contain at least one letter and one number")
  private String password;

  /** Updated account status (optional). */
  @JsonProperty("is_active")
  private Boolean isActive;

  /** Version for optimistic locking (required for updates). */
  private Integer version;
}
