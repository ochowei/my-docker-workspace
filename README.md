# my-docker-workspace

A Docker-based workspace environment for development and deployment.

## Overview

This repository contains Docker configurations for creating and managing a containerized workspace environment.

## Features

- 🐳 Containerized development environment
- 📦 Docker-based setup for consistency across systems
- 🚀 Easy to deploy and reproduce

## Prerequisites

- Docker
- Docker Compose (optional, if using docker-compose.yml)

## Quick Start

### Build the Docker Image

```bash
docker build -t my-docker-workspace .
```

### Run the Container

```bash
docker run -it my-docker-workspace
```

## Using Docker Compose

A `docker-compose.yml` is provided to simplify running the workspace with persistent volumes and Git identity pre-configured.

### First-time setup

Copy the example environment file and fill in your Git identity:

```bash
cp .env.example .env
# then edit .env with your name and email
```

`.env` is git-ignored — your personal info stays local. Named volumes (`claude-gh-config`, `claude-code-config`, `claude-zsh-history`) are created automatically on first run and persist gh login, Claude Code config, and zsh history across sessions.

### Build the image

```bash
docker compose build
```

### Start an interactive session

```bash
docker compose run --rm workspace
```

### Or run in the background and attach

```bash
docker compose up -d
docker compose exec workspace zsh
```

### Stop and remove

```bash
docker compose down
```
