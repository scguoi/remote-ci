"""User API integration tests."""

from fastapi.testclient import TestClient


class TestUsersAPI:
    """User API integration test class."""

    def test_health_check(self, client: TestClient):
        """Test health check endpoint."""
        response = client.get("/healthz")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"

    def test_create_user_success(self, client: TestClient):
        """Test successful user creation."""
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "full_name": "Test User",
            "password": "password123",
        }

        response = client.post("/api/v1/users/", json=user_data)
        assert response.status_code == 201

        data = response.json()
        assert data["success"] is True
        assert data["message"] == "User created successfully"
        assert data["data"]["username"] == "testuser"
        assert data["data"]["email"] == "test@example.com"

    def test_create_user_invalid_email(self, client: TestClient):
        """Test creating user with invalid email format."""
        user_data = {
            "username": "testuser",
            "email": "invalid-email",  # Invalid email format
            "password": "password123",
        }

        response = client.post("/api/v1/users/", json=user_data)
        assert response.status_code == 422  # Validation error

    def test_create_user_duplicate(self, client: TestClient):
        """Test creating duplicate user."""
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }

        # Create first user
        response1 = client.post("/api/v1/users/", json=user_data)
        assert response1.status_code == 201

        # Try to create duplicate user
        response2 = client.post("/api/v1/users/", json=user_data)
        assert response2.status_code == 400

    def test_get_user_by_id(self, client: TestClient):
        """Test getting user by ID."""
        # Create user first
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        response = client.post("/api/v1/users/", json=user_data)
        user_id = response.json()["data"]["id"]

        # Get user
        response = client.get(f"/api/v1/users/{user_id}")
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["data"]["id"] == user_id

    def test_get_user_not_found(self, client: TestClient):
        """Test getting non-existent user."""
        response = client.get("/api/v1/users/999")
        assert response.status_code == 404

    def test_get_user_by_username(self, client: TestClient):
        """Test getting user by username."""
        # Create user first
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        client.post("/api/v1/users/", json=user_data)

        # Get user by username
        response = client.get("/api/v1/users/username/testuser")
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["data"]["username"] == "testuser"

    def test_list_users(self, client: TestClient):
        """Test user list query."""
        # Create multiple users
        for i in range(3):
            user_data = {
                "username": f"user{i}",
                "email": f"user{i}@example.com",
                "password": "password123",
            }
            client.post("/api/v1/users/", json=user_data)

        # Query user list
        response = client.get("/api/v1/users/?page=0&size=10")
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["data"]["total"] == 3
        assert len(data["data"]["users"]) == 3

    def test_update_user(self, client: TestClient):
        """Test updating user."""
        # Create user first
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        response = client.post("/api/v1/users/", json=user_data)
        created_user = response.json()["data"]

        # Update user
        update_data = {
            "email": "updated@example.com",
            "full_name": "Updated Name",
            "version": created_user["version"],
        }

        response = client.put(f"/api/v1/users/{created_user['id']}", json=update_data)
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["data"]["email"] == "updated@example.com"
        assert data["data"]["version"] == created_user["version"] + 1

    def test_delete_user(self, client: TestClient):
        """Test deleting user."""
        # Create user first
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        response = client.post("/api/v1/users/", json=user_data)
        created_user = response.json()["data"]

        # Delete user
        response = client.delete(
            f"/api/v1/users/{created_user['id']}?version={created_user['version']}"
        )
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True

        # Verify user has been deleted
        response = client.get(f"/api/v1/users/{created_user['id']}")
        assert response.status_code == 404

    def test_check_username_exists(self, client: TestClient):
        """Test checking if username exists."""
        # Create user first
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        client.post("/api/v1/users/", json=user_data)

        # Check existing username
        response = client.get("/api/v1/users/check-username/testuser")
        assert response.status_code == 200
        data = response.json()
        assert data["data"]["exists"] is True

        # Check non-existing username
        response = client.get("/api/v1/users/check-username/nonexistent")
        assert response.status_code == 200
        data = response.json()
        assert data["data"]["exists"] is False

    def test_check_email_exists(self, client: TestClient):
        """Test checking if email exists."""
        # Create user first
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        client.post("/api/v1/users/", json=user_data)

        # Check existing email
        response = client.get("/api/v1/users/check-email?email=test@example.com")
        assert response.status_code == 200
        data = response.json()
        assert data["data"]["exists"] is True

        # Check non-existing email
        response = client.get("/api/v1/users/check-email?email=nonexistent@example.com")
        assert response.status_code == 200
        data = response.json()
        assert data["data"]["exists"] is False
