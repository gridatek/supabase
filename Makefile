.PHONY: help
help:
	@echo "Available commands:"
	@echo "  make up          - Start all services"
	@echo "  make down        - Stop all services"
	@echo "  make reset       - Reset database and run migrations"
	@echo "  make migrate     - Run migrations"
	@echo "  make seed        - Seed database"
	@echo "  make logs        - Show logs"
	@echo "  make shell-db    - Open PostgreSQL shell"
	@echo "  make test        - Run tests"

.PHONY: up
up:
	docker compose -f docker/compose.yml up -d
	@echo "Waiting for services to be ready..."
	@sleep 5
	@echo "Services running at:"
	@echo "  - API:      http://localhost:8000"
	@echo "  - Auth:     http://localhost:9999"
	@echo "  - Database: postgresql://localhost:5432"
	@echo "  - Mail:     http://localhost:8025"

.PHONY: down
down:
	docker compose -f docker/compose.yml down

.PHONY: reset
reset:
	docker compose -f docker/compose.yml down -v
	docker compose -f docker/compose.yml up -d
	@sleep 5
	./scripts/migrate.sh
	./scripts/seed.sh

.PHONY: migrate
migrate:
	./scripts/migrate.sh

.PHONY: seed
seed:
	./scripts/seed.sh

.PHONY: logs
logs:
	docker compose -f docker/compose.yml logs -f

.PHONY: shell-db
shell-db:
	docker exec -it supabase-db psql -U postgres -d supabase

.PHONY: test
test:
	npm test