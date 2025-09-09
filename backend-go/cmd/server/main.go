package main

import (
	"log"
	"net/http"
	"os"
	"time"

	"github.com/gin-gonic/gin"
	_ "github.com/go-sql-driver/mysql"
	"github.com/jmoiron/sqlx"
	"github.com/joho/godotenv"

	"github.com/scguoi/remote-ci/backend-go/internal/dao"
	"github.com/scguoi/remote-ci/backend-go/internal/handler"
	"github.com/scguoi/remote-ci/backend-go/internal/service"
)

func mustGetEnv(key, def string) string {
	if v := os.Getenv(key); v != "" {
		return v
	}
	return def
}

func initDB(dsn string) *sqlx.DB {
	db, err := sqlx.Open("mysql", dsn)
	if err != nil {
		log.Fatalf("failed to open db: %v", err)
	}
	db.SetMaxOpenConns(25)
	db.SetMaxIdleConns(25)
	db.SetConnMaxLifetime(5 * time.Minute)
	if err := db.Ping(); err != nil {
		log.Fatalf("failed to ping db: %v", err)
	}
	return db
}

func setupRouter(svc service.UserService) *gin.Engine {
	r := gin.Default()
	// Health check
	r.GET("/healthz", func(c *gin.Context) {
		c.JSON(http.StatusOK, gin.H{"status": "ok", "time": time.Now().Format(time.RFC3339)})
	})

	h := handler.NewUserHandler(svc)
	h.RegisterRoutes(r)
	return r
}

func main() {
	// Load .env if present
	_ = godotenv.Load()

	// Environment
	port := mustGetEnv("PORT", "8080")
	dsn := os.Getenv("MYSQL_DSN")
	if dsn == "" {
		log.Fatalf("MYSQL_DSN is required. Example: user:pass@tcp(127.0.0.1:3306)/demo?parseTime=true&charset=utf8mb4")
	}

	// Database
	db := initDB(dsn)
	defer func() {
		if err := db.Close(); err != nil {
			log.Printf("db close error: %v", err)
		}
	}()

	// Wiring
	userDAO := dao.NewUserDAO(db)
	userSvc := service.NewUserService(userDAO)
	router := setupRouter(userSvc)

	log.Printf("Go user service listening on :%s", port)
	if err := router.Run(":" + port); err != nil {
		log.Fatalf("server error: %v", err)
	}
}
