"""用户API集成测试."""

from fastapi.testclient import TestClient


class TestUsersAPI:
    """用户API集成测试类."""

    def test_health_check(self, client: TestClient):
        """测试健康检查端点."""
        response = client.get("/healthz")
        assert response.status_code == 200
        data = response.json()
        assert data["status"] == "healthy"

    def test_create_user_success(self, client: TestClient):
        """测试成功创建用户."""
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
        assert data["message"] == "用户创建成功"
        assert data["data"]["username"] == "testuser"
        assert data["data"]["email"] == "test@example.com"

    def test_create_user_invalid_email(self, client: TestClient):
        """测试创建用户时邮箱格式无效."""
        user_data = {
            "username": "testuser",
            "email": "invalid-email",  # 无效邮箱格式
            "password": "password123",
        }

        response = client.post("/api/v1/users/", json=user_data)
        assert response.status_code == 422  # 验证错误

    def test_create_user_duplicate(self, client: TestClient):
        """测试创建重复用户."""
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }

        # 创建第一个用户
        response1 = client.post("/api/v1/users/", json=user_data)
        assert response1.status_code == 201

        # 尝试创建重复用户
        response2 = client.post("/api/v1/users/", json=user_data)
        assert response2.status_code == 400

    def test_get_user_by_id(self, client: TestClient):
        """测试根据ID获取用户."""
        # 先创建用户
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        response = client.post("/api/v1/users/", json=user_data)
        user_id = response.json()["data"]["id"]

        # 获取用户
        response = client.get(f"/api/v1/users/{user_id}")
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["data"]["id"] == user_id

    def test_get_user_not_found(self, client: TestClient):
        """测试获取不存在的用户."""
        response = client.get("/api/v1/users/999")
        assert response.status_code == 404

    def test_get_user_by_username(self, client: TestClient):
        """测试根据用户名获取用户."""
        # 先创建用户
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        client.post("/api/v1/users/", json=user_data)

        # 根据用户名获取用户
        response = client.get("/api/v1/users/username/testuser")
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["data"]["username"] == "testuser"

    def test_list_users(self, client: TestClient):
        """测试用户列表查询."""
        # 创建多个用户
        for i in range(3):
            user_data = {
                "username": f"user{i}",
                "email": f"user{i}@example.com",
                "password": "password123",
            }
            client.post("/api/v1/users/", json=user_data)

        # 查询用户列表
        response = client.get("/api/v1/users/?page=0&size=10")
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True
        assert data["data"]["total"] == 3
        assert len(data["data"]["users"]) == 3

    def test_update_user(self, client: TestClient):
        """测试更新用户."""
        # 先创建用户
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        response = client.post("/api/v1/users/", json=user_data)
        created_user = response.json()["data"]

        # 更新用户
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
        """测试删除用户."""
        # 先创建用户
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        response = client.post("/api/v1/users/", json=user_data)
        created_user = response.json()["data"]

        # 删除用户
        response = client.delete(
            f"/api/v1/users/{created_user['id']}?version={created_user['version']}"
        )
        assert response.status_code == 200

        data = response.json()
        assert data["success"] is True

        # 验证用户已被删除
        response = client.get(f"/api/v1/users/{created_user['id']}")
        assert response.status_code == 404

    def test_check_username_exists(self, client: TestClient):
        """测试检查用户名是否存在."""
        # 先创建用户
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        client.post("/api/v1/users/", json=user_data)

        # 检查存在的用户名
        response = client.get("/api/v1/users/check-username/testuser")
        assert response.status_code == 200
        data = response.json()
        assert data["data"]["exists"] is True

        # 检查不存在的用户名
        response = client.get("/api/v1/users/check-username/nonexistent")
        assert response.status_code == 200
        data = response.json()
        assert data["data"]["exists"] is False

    def test_check_email_exists(self, client: TestClient):
        """测试检查邮箱是否存在."""
        # 先创建用户
        user_data = {
            "username": "testuser",
            "email": "test@example.com",
            "password": "password123",
        }
        client.post("/api/v1/users/", json=user_data)

        # 检查存在的邮箱
        response = client.get("/api/v1/users/check-email?email=test@example.com")
        assert response.status_code == 200
        data = response.json()
        assert data["data"]["exists"] is True

        # 检查不存在的邮箱
        response = client.get("/api/v1/users/check-email?email=nonexistent@example.com")
        assert response.status_code == 200
        data = response.json()
        assert data["data"]["exists"] is False
