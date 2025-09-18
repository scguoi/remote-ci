package com.example;

import org.mybatis.spring.annotation.MapperScan;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.transaction.annotation.EnableTransactionManagement;

/**
 * Main application class for the User Management System.
 *
 * <p>This is a multi-module Spring Boot application that provides REST APIs for user management
 * with MySQL database integration using MyBatis and Flyway for database migrations.
 *
 * <p>Features:
 *
 * <ul>
 *   <li>User CRUD operations with validation
 *   <li>MySQL database with connection pooling
 *   <li>MyBatis for data access with optimistic locking
 *   <li>Flyway for database version management
 *   <li>RESTful API with consistent error handling
 *   <li>Comprehensive code quality checks with Alibaba P3C rules
 * </ul>
 *
 * @author Claude Code
 * @since 1.0.0
 */
@SpringBootApplication
@MapperScan("com.example.dao")
@EnableTransactionManagement
public class UserManagementApplication {

  /**
   * Main method to start the Spring Boot application.
   *
   * @param args command line arguments
   */
  public static void main(String[] args) {
    SpringApplication.run(UserManagementApplication.class, args);
  }
}
