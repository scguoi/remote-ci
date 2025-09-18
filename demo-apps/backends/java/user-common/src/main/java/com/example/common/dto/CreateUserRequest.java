package com.example.common.dto;

import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;
import jakarta.validation.constraints.Size;
import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;

/**
 * Request DTO for creating a new user.
 *
 * <p>This class contains all required and optional fields for user creation, with proper validation
 * annotations to ensure data integrity.
 *
 * @author Claude Code
 * @since 1.0.0
 */
@Data
@Builder
@NoArgsConstructor
@AllArgsConstructor
public class CreateUserRequest {

  /** Username for the new user account (3-50 characters, alphanumeric and underscore only). */
  @NotBlank(message = "Username cannot be empty")
  @Size(min = 3, max = 50, message = "Username length must be between 3-50 characters")
  @Pattern(
      regexp = "^[a-zA-Z0-9_]+$",
      message = "Username can only contain letters, numbers and underscores")
  private String username;

  /** Email address for the user (must be valid email format). */
  @NotBlank(message = "Email cannot be empty")
  @Email(message = "Invalid email format")
  @Size(max = 100, message = "Email length cannot exceed 100 characters")
  private String email;

  /** Full name of the user (2-100 characters). */
  @NotBlank(message = "Full name cannot be empty")
  @Size(min = 2, max = 100, message = "Full name length must be between 2-100 characters")
  @JsonProperty("full_name")
  private String fullName;

  /** Password for the user account (8-128 characters, must contain letters and numbers). */
  @NotBlank(message = "Password cannot be empty")
  @Size(min = 8, max = 128, message = "Password length must be between 8-128 characters")
  @Pattern(
      regexp = "^(?=.*[a-zA-Z])(?=.*\\d).*$",
      message = "Password must contain at least one letter and one number")
  private String password;

  /** Phone number (optional, must be valid format if provided). */
  @Pattern(regexp = "^(\\+?86)?1[3-9]\\d{9}$|^$", message = "Invalid phone number format")
  @JsonProperty("phone_number")
  private String phoneNumber;
}
