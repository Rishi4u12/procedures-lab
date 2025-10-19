#!/usr/bin/make -f
# Convenience Makefile for WSL/Linux
# Examples:
#   make install   # create venv and install deps
#   make test      # run pytest
#   make run       # start Flask server on 127.0.0.1:8000
#   make clean     # remove venv and caches

.PHONY: help venv install test run serve build clean doctor
.DEFAULT_GOAL := run
SHELL := /bin/bash

VENV_DIR := venv
# Auto-detect python executable (prefer python3)
PY := $(shell command -v python3 >/dev/null 2>&1 && echo python3 || (command -v python >/dev/null 2>&1 && echo python || echo python3))

help:
	@echo "Targets:"
	@echo "  make install   - create venv (WSL) and install requirements"
	@echo "  make build     - install + quick sanity check"
	@echo "  make test      - run pytest (use V=-v for verbose)"
	@echo "  make run       - start Flask dev server (set HOST/PORT)"
	@echo "  make serve     - alias for run"
	@echo "  make clean     - remove venv and caches"
	@echo "  make doctor    - show detected python and versions"

# Create a Linux-style venv (with bin/) even if a Windows venv already exists
venv:
	@if [ ! -f $(VENV_DIR)/bin/activate ]; then \
		echo "[venv] Creating virtual environment using $(PY)..."; \
		rm -rf $(VENV_DIR); \
		set -e; \
		$(PY) -m venv $(VENV_DIR) || { \
			echo "[venv] Failed to create venv."; \
			echo "       On Ubuntu/WSL, install venv support:"; \
			echo "         sudo apt update && sudo apt install -y python3-venv python3-pip"; \
			exit 1; \
		}; \
		echo "[venv] Created at $(VENV_DIR)"; \
	else \
		echo "[venv] Using existing $(VENV_DIR)"; \
	fi

install: venv
	@echo "[pip] Installing requirements..."
	@$(VENV_DIR)/bin/python -m pip install -r requirements.txt
	@echo "[pip] Done."

# Runs the tests quietly; use `make test V=-v` for verbose
V ?= -q
test: install
	@echo "[pytest] Running tests $(V)"
	@$(VENV_DIR)/bin/python -m pytest $(V)

PORT ?= 8000
HOST ?= 127.0.0.1

build: install
	@echo "[build] Verifying Flask app import..."
	@$(VENV_DIR)/bin/python -c "from importlib import import_module; mod = import_module('app.server'); assert getattr(mod, 'app', None) is not None, 'Flask app not found as app'; print('[build] OK: app.server:app found')"

run: build
	@echo "[flask] Starting server on http://$(HOST):$(PORT)"
	@FLASK_APP=app.server FLASK_ENV=development $(VENV_DIR)/bin/python -m flask run --host=$(HOST) --port=$(PORT)

serve: run

clean:
	rm -rf $(VENV_DIR) .pytest_cache **/__pycache__ __pycache__

doctor:
	@echo "Detected python: $(PY)"
	@$(PY) --version || true
	@echo "Venv python (if exists):"
	@([ -f $(VENV_DIR)/bin/python ] && $(VENV_DIR)/bin/python --version) || echo "venv not created yet"
	@echo "make: $$(command -v make)"