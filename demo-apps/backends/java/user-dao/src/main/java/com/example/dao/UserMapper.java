package com.example.dao;

import com.example.common.entity.User;
import java.util.List;
import java.util.Optional;
import org.apache.ibatis.annotations.Delete;
import org.apache.ibatis.annotations.Insert;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Options;
import org.apache.ibatis.annotations.Param;
import org.apache.ibatis.annotations.Select;
import org.apache.ibatis.annotations.Update;

/**
 * MyBatis mapper interface for User entity database operations.
 *
 * <p>This mapper provides CRUD operations and custom queries for the User entity. All operations
 * are implemented using MyBatis annotations for better maintainability and performance.
 *
 * @author Claude Code
 * @since 1.0.0
 */
@Mapper
public interface UserMapper {

  /**
   * Insert a new user into the database.
   *
   * @param user the user entity to insert
   * @return number of rows affected (should be 1 for successful insert)
   */
  @Insert({
    "INSERT INTO users(",
    "username, email, full_name, password_hash, phone_number,",
    "is_active, created_by, updated_by)",
    "VALUES(",
    "#{username}, #{email}, #{fullName}, #{passwordHash}, #{phoneNumber},",
    "#{isActive}, #{createdBy}, #{updatedBy})"
  })
  @Options(useGeneratedKeys = true, keyProperty = "id")
  int insertUser(User user);

  /**
   * Find a user by their unique ID.
   *
   * @param id the user ID
   * @return Optional containing the user if found, empty otherwise
   */
  @Select({
    "SELECT id, username, email, full_name, password_hash, phone_number,",
    "is_active, created_at, updated_at, created_by, updated_by, version",
    "FROM users WHERE id = #{id}"
  })
  Optional<User> findById(@Param("id") Long id);

  /**
   * Find a user by their username.
   *
   * @param username the username to search for
   * @return Optional containing the user if found, empty otherwise
   */
  @Select({
    "SELECT id, username, email, full_name, password_hash, phone_number,",
    "is_active, created_at, updated_at, created_by, updated_by, version",
    "FROM users WHERE username = #{username}"
  })
  Optional<User> findByUsername(@Param("username") String username);

  /**
   * Find a user by their email address.
   *
   * @param email the email address to search for
   * @return Optional containing the user if found, empty otherwise
   */
  @Select({
    "SELECT id, username, email, full_name, password_hash, phone_number,",
    "is_active, created_at, updated_at, created_by, updated_by, version",
    "FROM users WHERE email = #{email}"
  })
  Optional<User> findByEmail(@Param("email") String email);

  /**
   * Find all users with optional filtering by active status.
   *
   * @param isActive filter by active status (null to get all users)
   * @param offset pagination offset
   * @param limit pagination limit
   * @return list of users matching the criteria
   */
  @Select({
    "<script>",
    "SELECT id, username, email, full_name, password_hash, phone_number,",
    "is_active, created_at, updated_at, created_by, updated_by, version",
    "FROM users",
    "<where>",
    "<if test='isActive != null'>",
    "AND is_active = #{isActive}",
    "</if>",
    "</where>",
    "ORDER BY created_at DESC",
    "LIMIT #{limit} OFFSET #{offset}",
    "</script>"
  })
  List<User> findUsers(
      @Param("isActive") Boolean isActive, @Param("offset") int offset, @Param("limit") int limit);

  /**
   * Count total number of users with optional filtering by active status.
   *
   * @param isActive filter by active status (null to count all users)
   * @return total count of users
   */
  @Select({
    "<script>",
    "SELECT COUNT(*) FROM users",
    "<where>",
    "<if test='isActive != null'>",
    "AND is_active = #{isActive}",
    "</if>",
    "</where>",
    "</script>"
  })
  int countUsers(@Param("isActive") Boolean isActive);

  /**
   * Update an existing user. Only non-null fields will be updated.
   *
   * @param user the user entity with updated values
   * @return number of rows affected (should be 1 for successful update)
   */
  @Update({
    "<script>",
    "UPDATE users",
    "<set>",
    "<if test='email != null'>email = #{email},</if>",
    "<if test='fullName != null'>full_name = #{fullName},</if>",
    "<if test='passwordHash != null'>password_hash = #{passwordHash},</if>",
    "<if test='phoneNumber != null'>phone_number = #{phoneNumber},</if>",
    "<if test='isActive != null'>is_active = #{isActive},</if>",
    "<if test='updatedBy != null'>updated_by = #{updatedBy},</if>",
    "version = version + 1,",
    "updated_at = CURRENT_TIMESTAMP",
    "</set>",
    "WHERE id = #{id} AND version = #{version}",
    "</script>"
  })
  int updateUser(User user);

  /**
   * Soft delete a user by setting is_active to false.
   *
   * @param id the user ID
   * @param version the current version for optimistic locking
   * @param updatedBy the user performing the deletion
   * @return number of rows affected (should be 1 for successful update)
   */
  @Update({
    "UPDATE users SET",
    "is_active = 0,",
    "updated_by = #{updatedBy},",
    "version = version + 1,",
    "updated_at = CURRENT_TIMESTAMP",
    "WHERE id = #{id} AND version = #{version}"
  })
  int softDeleteUser(
      @Param("id") Long id,
      @Param("version") Integer version,
      @Param("updatedBy") String updatedBy);

  /**
   * Hard delete a user from the database (use with caution).
   *
   * @param id the user ID
   * @return number of rows affected (should be 1 for successful deletion)
   */
  @Delete("DELETE FROM users WHERE id = #{id}")
  int deleteUser(@Param("id") Long id);

  /**
   * Check if a username already exists (case-insensitive).
   *
   * @param username the username to check
   * @param excludeId optional user ID to exclude from the check (for updates)
   * @return true if username exists, false otherwise
   */
  @Select({
    "<script>",
    "SELECT COUNT(*) > 0 FROM users",
    "WHERE LOWER(username) = LOWER(#{username})",
    "<if test='excludeId != null'>",
    "AND id != #{excludeId}",
    "</if>",
    "</script>"
  })
  boolean existsByUsername(@Param("username") String username, @Param("excludeId") Long excludeId);

  /**
   * Check if an email already exists (case-insensitive).
   *
   * @param email the email to check
   * @param excludeId optional user ID to exclude from the check (for updates)
   * @return true if email exists, false otherwise
   */
  @Select({
    "<script>",
    "SELECT COUNT(*) > 0 FROM users",
    "WHERE LOWER(email) = LOWER(#{email})",
    "<if test='excludeId != null'>",
    "AND id != #{excludeId}",
    "</if>",
    "</script>"
  })
  boolean existsByEmail(@Param("email") String email, @Param("excludeId") Long excludeId);
}
