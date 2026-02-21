SHELL := bash

.DEFAULT_GOAL := help

JAVA_MIN_MAJOR := 25
APP_PORT ?= 8080
DOCKER_COMPOSE_FILE ?= docker/compose.observability.yml
RUNTIME_DIR ?= .runtime
INTEGRATION_PID_FILE ?= $(RUNTIME_DIR)/integration.pid
INTEGRATION_LOG_FILE ?= $(RUNTIME_DIR)/integration.log
INTEGRATION_API_BASE_URL ?= http://localhost:$(APP_PORT)/api/v1
INTEGRATION_INTERVAL_SECONDS ?= 1

.PHONY: help setup install-deps check-deps check-docker build run down observability-up observability-down observability-logs observability-smoke observability-dashboards integration integration-stop integration-status test clean package jar doctor

help:
	@echo "Available targets:"
	@echo "  make setup         Install missing system dependencies and download Maven deps"
	@echo "  make install-deps  Install Java 25+ and Maven when missing"
	@echo "  make check-deps    Validate Java/Maven versions"
	@echo "  make check-docker  Validate Docker and Docker Compose availability"
	@echo "  make build         Build JAR (mvn clean package)"
	@echo "  make run           Run API locally on APP_PORT=$(APP_PORT) (clean start)"
	@echo "  make down          Stop API process running on APP_PORT=$(APP_PORT)"
	@echo "  make observability-up    Start OTEL Collector + Grafana LGTM stack"
	@echo "  make observability-down  Stop observability stack"
	@echo "  make observability-logs  Tail observability stack logs"
	@echo "  make observability-smoke Verify collector and Grafana endpoints"
	@echo "  make observability-dashboards Apply Grafana dashboard compatibility patch"
	@echo "  make integration         Start continuous API traffic generator in background"
	@echo "  make integration-stop    Stop continuous API traffic generator"
	@echo "  make integration-status  Show integration process and recent logs"
	@echo "  make test          Run tests"
	@echo "  make clean         Clean build artifacts"
	@echo "  make jar           Build and run the generated JAR"
	@echo "  make doctor        Alias for check-deps"

setup: install-deps check-deps check-docker
	@mvn -q -DskipTests dependency:go-offline
	@echo "Environment ready."

install-deps:
	@set -euo pipefail; \
	need_java=0; \
	need_maven=0; \
	if command -v java >/dev/null 2>&1; then \
		java_version="$$(java -version 2>&1 | awk -F'\"' '/version/ {print $$2; exit}')"; \
		java_major="$$(echo "$$java_version" | awk -F. '{if ($$1 == "1") print $$2; else print $$1}')"; \
		if [ -z "$$java_major" ] || [ "$$java_major" -lt "$(JAVA_MIN_MAJOR)" ]; then \
			need_java=1; \
		fi; \
	else \
		need_java=1; \
	fi; \
	if ! command -v mvn >/dev/null 2>&1; then \
		need_maven=1; \
	fi; \
	if [ "$$need_java" -eq 0 ] && [ "$$need_maven" -eq 0 ]; then \
		echo "Java and Maven are already installed."; \
		exit 0; \
	fi; \
	SUDO=""; \
	if [ "$$(id -u)" -ne 0 ]; then \
		if command -v sudo >/dev/null 2>&1; then \
			SUDO="sudo"; \
		else \
			echo "Root privileges are required to install packages. Run as root or install sudo."; \
			exit 1; \
		fi; \
	fi; \
	if command -v apt-get >/dev/null 2>&1; then \
		pkgs=""; \
		[ "$$need_java" -eq 1 ] && pkgs="$$pkgs openjdk-25-jdk"; \
		[ "$$need_maven" -eq 1 ] && pkgs="$$pkgs maven"; \
		$$SUDO apt-get update; \
		$$SUDO apt-get install -y $$pkgs; \
	elif command -v dnf >/dev/null 2>&1; then \
		pkgs=""; \
		[ "$$need_java" -eq 1 ] && pkgs="$$pkgs java-25-openjdk-devel"; \
		[ "$$need_maven" -eq 1 ] && pkgs="$$pkgs maven"; \
		$$SUDO dnf install -y $$pkgs; \
	elif command -v yum >/dev/null 2>&1; then \
		pkgs=""; \
		[ "$$need_java" -eq 1 ] && pkgs="$$pkgs java-25-openjdk-devel"; \
		[ "$$need_maven" -eq 1 ] && pkgs="$$pkgs maven"; \
		$$SUDO yum install -y $$pkgs; \
	elif command -v pacman >/dev/null 2>&1; then \
		pkgs=""; \
		[ "$$need_java" -eq 1 ] && pkgs="$$pkgs jdk-openjdk"; \
		[ "$$need_maven" -eq 1 ] && pkgs="$$pkgs maven"; \
		$$SUDO pacman -Sy --noconfirm $$pkgs; \
	elif command -v zypper >/dev/null 2>&1; then \
		pkgs=""; \
		[ "$$need_java" -eq 1 ] && pkgs="$$pkgs java-25-openjdk-devel"; \
		[ "$$need_maven" -eq 1 ] && pkgs="$$pkgs maven"; \
		$$SUDO zypper --non-interactive install $$pkgs; \
	elif command -v apk >/dev/null 2>&1; then \
		pkgs=""; \
		[ "$$need_java" -eq 1 ] && pkgs="$$pkgs openjdk25"; \
		[ "$$need_maven" -eq 1 ] && pkgs="$$pkgs maven"; \
		$$SUDO apk add --no-cache $$pkgs; \
	elif command -v brew >/dev/null 2>&1; then \
		[ "$$need_java" -eq 1 ] && brew install openjdk@25; \
		[ "$$need_maven" -eq 1 ] && brew install maven; \
		if [ "$$need_java" -eq 1 ] && ! command -v java >/dev/null 2>&1; then \
			echo "openjdk@25 installed, but 'java' is not on PATH yet."; \
			echo "Run: brew link --force --overwrite openjdk@25"; \
		fi; \
	else \
		echo "Unsupported package manager."; \
		echo "Install Java $(JAVA_MIN_MAJOR)+ and Maven manually, then run 'make setup' again."; \
		exit 1; \
	fi; \
	echo "Dependency installation finished."

check-deps:
	@set -euo pipefail; \
	if ! command -v java >/dev/null 2>&1; then \
		echo "Java not found. Run 'make install-deps'."; \
		exit 1; \
	fi; \
	java_version="$$(java -version 2>&1 | awk -F'\"' '/version/ {print $$2; exit}')"; \
	java_major="$$(echo "$$java_version" | awk -F. '{if ($$1 == "1") print $$2; else print $$1}')"; \
	if [ -z "$$java_major" ] || [ "$$java_major" -lt "$(JAVA_MIN_MAJOR)" ]; then \
		echo "Java $(JAVA_MIN_MAJOR)+ is required. Current version: $$java_version"; \
		exit 1; \
	fi; \
	if ! command -v mvn >/dev/null 2>&1; then \
		echo "Maven not found. Run 'make install-deps'."; \
		exit 1; \
	fi; \
	mvn_version="$$(mvn -version 2>/dev/null | awk 'NR==1 {print $$3}')"; \
	echo "Java $$java_version and Maven $$mvn_version detected."

check-docker:
	@set -euo pipefail; \
	if ! command -v docker >/dev/null 2>&1; then \
		echo "Docker not found."; \
		echo "Install Docker Engine and Docker Compose plugin, then retry."; \
		echo "Ubuntu example: https://docs.docker.com/engine/install/ubuntu/"; \
		exit 1; \
	fi; \
	if ! docker info >/dev/null 2>&1; then \
		echo "Docker daemon is not running or current user has no permission."; \
		echo "Start Docker service and/or add your user to the docker group."; \
		exit 1; \
	fi; \
	compose_version=""; \
	if docker compose version >/dev/null 2>&1; then \
		compose_version="$$(docker compose version --short 2>/dev/null || docker compose version | head -n 1)"; \
	elif command -v docker-compose >/dev/null 2>&1; then \
		compose_version="$$(docker-compose version --short 2>/dev/null || docker-compose version | head -n 1)"; \
	else \
		echo "Docker Compose not found."; \
		echo "Install Docker Compose plugin or docker-compose binary."; \
		exit 1; \
	fi; \
	echo "Docker and Docker Compose detected ($$compose_version)."

build: check-deps
	@mvn clean package

run: check-deps
	@$(MAKE) --no-print-directory down APP_PORT=$(APP_PORT)
	@mvn clean spring-boot:run -Dspring-boot.run.arguments="--server.port=$(APP_PORT)"

down:
	@set -euo pipefail; \
	pids=""; \
	if command -v lsof >/dev/null 2>&1; then \
		pids="$$(lsof -ti tcp:$(APP_PORT) || true)"; \
	fi; \
	if [ -z "$$pids" ] && command -v ss >/dev/null 2>&1; then \
		pids="$$(ss -lptn 'sport = :$(APP_PORT)' 2>/dev/null | awk 'NR>1 {line=$$0; if (match(line, /pid=[0-9]+/)) {pid=substr(line, RSTART+4, RLENGTH-4); print pid}}' | sort -u)"; \
	fi; \
	if [ -z "$$pids" ] && command -v fuser >/dev/null 2>&1; then \
		pids="$$(fuser -n tcp $(APP_PORT) 2>/dev/null || true)"; \
	fi; \
	if [ -z "$$pids" ]; then \
		echo "No process found listening on port $(APP_PORT)."; \
		exit 0; \
	fi; \
	echo "Stopping process(es) on port $(APP_PORT): $$pids"; \
	kill $$pids || true; \
	sleep 1; \
	still_running=""; \
	for pid in $$pids; do \
		if kill -0 $$pid >/dev/null 2>&1; then \
			still_running="$$still_running $$pid"; \
		fi; \
	done; \
	if [ -n "$$still_running" ]; then \
		echo "Force killing process(es):$$still_running"; \
		kill -9 $$still_running || true; \
	fi; \
	echo "Application stopped."

observability-up: check-docker
	@set -euo pipefail; \
	compose_cmd=""; \
	if docker compose version >/dev/null 2>&1; then \
		compose_cmd="docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then \
		compose_cmd="docker-compose"; \
	else \
		echo "Docker Compose not found."; \
		exit 1; \
	fi; \
	$$compose_cmd -f "$(DOCKER_COMPOSE_FILE)" up -d; \
	echo "Observability stack started."; \
	echo "Grafana: http://localhost:3000 (admin/admin)"; \
	echo "Collector health: http://localhost:13133"
	@$(MAKE) --no-print-directory observability-dashboards

observability-down:
	@set -euo pipefail; \
	compose_cmd=""; \
	if docker compose version >/dev/null 2>&1; then \
		compose_cmd="docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then \
		compose_cmd="docker-compose"; \
	else \
		echo "Docker Compose not found."; \
		exit 1; \
	fi; \
	$$compose_cmd -f "$(DOCKER_COMPOSE_FILE)" down --remove-orphans

observability-logs:
	@set -euo pipefail; \
	compose_cmd=""; \
	if docker compose version >/dev/null 2>&1; then \
		compose_cmd="docker compose"; \
	elif command -v docker-compose >/dev/null 2>&1; then \
		compose_cmd="docker-compose"; \
	else \
		echo "Docker Compose not found."; \
		exit 1; \
	fi; \
	$$compose_cmd -f "$(DOCKER_COMPOSE_FILE)" logs -f otel-collector lgtm

observability-smoke:
	@set -euo pipefail; \
	collector_ok=0; \
	grafana_ok=0; \
	for attempt in $$(seq 1 30); do \
		if curl -fsS http://localhost:13133/ >/dev/null 2>&1; then \
			collector_ok=1; \
		fi; \
		if curl -fsS http://localhost:3000/login >/dev/null 2>&1; then \
			grafana_ok=1; \
		fi; \
		if [ "$$collector_ok" -eq 1 ] && [ "$$grafana_ok" -eq 1 ]; then \
			echo "Observability smoke check passed (collector + grafana reachable)."; \
			exit 0; \
		fi; \
		sleep 1; \
	done; \
	echo "Observability smoke check failed: collector_ok=$$collector_ok grafana_ok=$$grafana_ok"; \
	exit 1

observability-dashboards:
	@set -euo pipefail; \
	if ! command -v jq >/dev/null 2>&1; then \
		echo "jq not found. Install jq to apply Grafana dashboard patch."; \
		exit 1; \
	fi; \
	bash scripts/grafana-dashboard-compat.sh

integration:
	@mkdir -p "$(RUNTIME_DIR)"
	@set -euo pipefail; \
	if [ -f "$(INTEGRATION_PID_FILE)" ]; then \
		pid="$$(cat "$(INTEGRATION_PID_FILE)")"; \
		if [ -n "$$pid" ] && kill -0 "$$pid" >/dev/null 2>&1; then \
			echo "Integration traffic already running (PID $$pid)."; \
			exit 0; \
		fi; \
		rm -f "$(INTEGRATION_PID_FILE)"; \
	fi; \
	: >"$(INTEGRATION_LOG_FILE)"; \
	if command -v setsid >/dev/null 2>&1; then \
		INTEGRATION_API_BASE_URL="$(INTEGRATION_API_BASE_URL)" \
		INTEGRATION_INTERVAL_SECONDS="$(INTEGRATION_INTERVAL_SECONDS)" \
		setsid nohup bash scripts/integration-loop.sh </dev/null >>"$(INTEGRATION_LOG_FILE)" 2>&1 & \
	else \
		INTEGRATION_API_BASE_URL="$(INTEGRATION_API_BASE_URL)" \
		INTEGRATION_INTERVAL_SECONDS="$(INTEGRATION_INTERVAL_SECONDS)" \
		nohup bash scripts/integration-loop.sh </dev/null >>"$(INTEGRATION_LOG_FILE)" 2>&1 & \
	fi; \
	pid="$$!"; \
	echo "$$pid" >"$(INTEGRATION_PID_FILE)"; \
	echo "Integration traffic started in background (PID $$pid)."; \
	echo "Log file: $(INTEGRATION_LOG_FILE)"

integration-stop:
	@set -euo pipefail; \
	if [ ! -f "$(INTEGRATION_PID_FILE)" ]; then \
		echo "Integration traffic is not running (no PID file)."; \
		exit 0; \
	fi; \
	pid="$$(cat "$(INTEGRATION_PID_FILE)")"; \
	if [ -n "$$pid" ] && kill -0 "$$pid" >/dev/null 2>&1; then \
		kill "$$pid" || true; \
		sleep 1; \
		if kill -0 "$$pid" >/dev/null 2>&1; then \
			kill -9 "$$pid" || true; \
		fi; \
		echo "Integration traffic stopped (PID $$pid)."; \
	else \
		echo "Integration process not running anymore."; \
	fi; \
	rm -f "$(INTEGRATION_PID_FILE)"

integration-status:
	@set -euo pipefail; \
	if [ -f "$(INTEGRATION_PID_FILE)" ]; then \
		pid="$$(cat "$(INTEGRATION_PID_FILE)")"; \
		if [ -n "$$pid" ] && kill -0 "$$pid" >/dev/null 2>&1; then \
			echo "Integration traffic is running (PID $$pid)."; \
		else \
			echo "Integration PID file exists but process is not running."; \
		fi; \
	else \
		echo "Integration traffic is not running."; \
	fi; \
	if [ -f "$(INTEGRATION_LOG_FILE)" ]; then \
		echo "Last log lines from $(INTEGRATION_LOG_FILE):"; \
		tail -n 20 "$(INTEGRATION_LOG_FILE)"; \
	else \
		echo "Integration log file not found yet."; \
	fi

test: check-deps
	@mvn test

clean:
	@if command -v mvn >/dev/null 2>&1; then \
		mvn clean; \
	else \
		rm -rf target; \
	fi

package: build

jar: build
	@java -jar target/java-api-0.0.1-SNAPSHOT.jar

doctor: check-deps
