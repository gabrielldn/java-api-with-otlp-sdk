SHELL := bash

.DEFAULT_GOAL := help

JAVA_MIN_MAJOR := 25
APP_PORT ?= 8080

.PHONY: help setup install-deps check-deps build run down test clean package jar doctor

help:
	@echo "Available targets:"
	@echo "  make setup         Install missing system dependencies and download Maven deps"
	@echo "  make install-deps  Install Java 25+ and Maven when missing"
	@echo "  make check-deps    Validate Java/Maven versions"
	@echo "  make build         Build JAR (mvn clean package)"
	@echo "  make run           Run API locally on APP_PORT=$(APP_PORT) (clean start)"
	@echo "  make down          Stop API process running on APP_PORT=$(APP_PORT)"
	@echo "  make test          Run tests"
	@echo "  make clean         Clean build artifacts"
	@echo "  make jar           Build and run the generated JAR"
	@echo "  make doctor        Alias for check-deps"

setup: install-deps check-deps
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
