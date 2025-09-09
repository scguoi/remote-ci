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
  @NotBlank(message = "用户名不能为空")
  @Size(min = 3, max = 50, message = "用户名长度必须在3-50个字符之间")
  @Pattern(regexp = "^[a-zA-Z0-9_]+$", message = "用户名只能包含字母、数字和下划线")
  private String username;

  /** Email address for the user (must be valid email format). */
  @NotBlank(message = "邮箱不能为空")
  @Email(message = "邮箱格式不正确")
  @Size(max = 100, message = "邮箱长度不能超过100个字符")
  private String email;

  /** Full name of the user (2-100 characters). */
  @NotBlank(message = "姓名不能为空")
  @Size(min = 2, max = 100, message = "姓名长度必须在2-100个字符之间")
  @JsonProperty("full_name")
  private String fullName;

  /** Password for the user account (8-128 characters, must contain letters and numbers). */
  @NotBlank(message = "密码不能为空")
  @Size(min = 8, max = 128, message = "密码长度必须在8-128个字符之间")
  @Pattern(regexp = "^(?=.*[a-zA-Z])(?=.*\\d).*$", message = "密码必须包含至少一个字母和一个数字")
  private String password;

  /** Phone number (optional, must be valid format if provided). */
  @Pattern(regexp = "^(\\+?86)?1[3-9]\\d{9}$|^$", message = "手机号格式不正确")
  @JsonProperty("phone_number")
  private String phoneNumber;
}
