#!/bin/bash
# Docker Development Environment Management Script

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if docker and docker-compose are available
check_dependencies() {
    if ! command -v docker &> /dev/null; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi

    if ! command -v docker-compose &> /dev/null; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
}

# Start all services
start_services() {
    print_info "Starting all services..."
    docker-compose up -d
    print_info "Services started successfully!"
    print_info "Frontend: http://localhost"
    print_info "Go Backend: http://localhost:8080"
    print_info "Java Backend: http://localhost:8081"
    print_info "Python Backend: http://localhost:8000"
}

# Stop all services
stop_services() {
    print_info "Stopping all services..."
    docker-compose down
    print_info "Services stopped successfully!"
}

# Build all images
build_images() {
    print_info "Building all Docker images..."
    docker-compose build --no-cache
    print_info "All images built successfully!"
}

# Show logs
show_logs() {
    if [ -n "$1" ]; then
        print_info "Showing logs for service: $1"
        docker-compose logs -f "$1"
    else
        print_info "Showing logs for all services..."
        docker-compose logs -f
    fi
}

# Show status
show_status() {
    print_info "Service status:"
    docker-compose ps
}

# Clean up
cleanup() {
    print_warning "Cleaning up containers, networks, and volumes..."
    docker-compose down -v --remove-orphans
    docker system prune -f
    print_info "Cleanup completed!"
}

# Health check
health_check() {
    print_info "Performing health checks..."
    
    services=("backend-go:8080/health" "backend-java:8081/actuator/health" "backend-python:8000/health" "frontend-ts:80/health")
    
    for service in "${services[@]}"; do
        IFS=':' read -r name port_path <<< "$service"
        print_info "Checking $name..."
        if curl -f "http://localhost:$port_path" &> /dev/null; then
            print_info "✓ $name is healthy"
        else
            print_error "✗ $name is not responding"
        fi
    done
}

# Main script
case "$1" in
    "start")
        check_dependencies
        start_services
        ;;
    "stop")
        check_dependencies
        stop_services
        ;;
    "restart")
        check_dependencies
        stop_services
        start_services
        ;;
    "build")
        check_dependencies
        build_images
        ;;
    "logs")
        check_dependencies
        show_logs "$2"
        ;;
    "status")
        check_dependencies
        show_status
        ;;
    "health")
        health_check
        ;;
    "cleanup")
        check_dependencies
        cleanup
        ;;
    *)
        echo "Usage: $0 {start|stop|restart|build|logs [service]|status|health|cleanup}"
        echo ""
        echo "Commands:"
        echo "  start    - Start all services"
        echo "  stop     - Stop all services"
        echo "  restart  - Restart all services"
        echo "  build    - Build all Docker images"
        echo "  logs     - Show logs (optionally for specific service)"
        echo "  status   - Show service status"
        echo "  health   - Perform health checks"
        echo "  cleanup  - Stop services and clean up resources"
        exit 1
        ;;
esac