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
  @Email(message = "邮箱格式不正确")
  @Size(max = 100, message = "邮箱长度不能超过100个字符")
  private String email;

  /** Updated full name (optional). */
  @Size(min = 2, max = 100, message = "姓名长度必须在2-100个字符之间")
  @JsonProperty("full_name")
  private String fullName;

  /** Updated phone number (optional). */
  @Pattern(regexp = "^(\\+?86)?1[3-9]\\d{9}$|^$", message = "手机号格式不正确")
  @JsonProperty("phone_number")
  private String phoneNumber;

  /** Updated password (optional, 8-128 characters with letters and numbers). */
  @Size(min = 8, max = 128, message = "密码长度必须在8-128个字符之间")
  @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d).*$", message = "密码必须包含至少一个字母和一个数字")
  private String password;

  /** Updated account status (optional). */
  @JsonProperty("is_active")
  private Boolean isActive;

  /** Version for optimistic locking (required for updates). */
  private Integer version;
}
