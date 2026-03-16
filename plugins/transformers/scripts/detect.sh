#!/bin/bash
# Transformers Project Detector
# Analyzes a project directory and outputs structured context
# Pure bash — no AI, runs in seconds

set -euo pipefail

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

echo "{"

# ============================================================
# 1. TECH STACK DETECTION
# ============================================================
echo '  "techStack": {'

# Primary language/framework
STACK="unknown"
LANGUAGE="unknown"
FRAMEWORK="unknown"
PACKAGE_MANAGER="unknown"

# Flutter/Dart
if [ -f "pubspec.yaml" ]; then
  STACK="flutter"
  LANGUAGE="dart"
  FRAMEWORK="flutter"
  PACKAGE_MANAGER="pub"
# React Native
elif [ -f "metro.config.js" ] || [ -f "metro.config.ts" ] || ([ -f "package.json" ] && grep -q "react-native" package.json 2>/dev/null); then
  STACK="react-native"
  LANGUAGE="javascript/typescript"
  FRAMEWORK="react-native"
  PACKAGE_MANAGER=$([ -f "yarn.lock" ] && echo "yarn" || ([ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "npm"))
# Next.js
elif [ -f "next.config.js" ] || [ -f "next.config.ts" ] || [ -f "next.config.mjs" ]; then
  STACK="nextjs"
  LANGUAGE="javascript/typescript"
  FRAMEWORK="nextjs"
  PACKAGE_MANAGER=$([ -f "yarn.lock" ] && echo "yarn" || ([ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "npm"))
# Nuxt
elif [ -f "nuxt.config.js" ] || [ -f "nuxt.config.ts" ]; then
  STACK="nuxt"
  LANGUAGE="javascript/typescript"
  FRAMEWORK="nuxt"
  PACKAGE_MANAGER=$([ -f "yarn.lock" ] && echo "yarn" || ([ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "npm"))
# React (plain)
elif [ -f "package.json" ] && grep -q '"react"' package.json 2>/dev/null; then
  STACK="react"
  LANGUAGE="javascript/typescript"
  FRAMEWORK="react"
  PACKAGE_MANAGER=$([ -f "yarn.lock" ] && echo "yarn" || ([ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "npm"))
# Vue
elif [ -f "package.json" ] && grep -q '"vue"' package.json 2>/dev/null; then
  STACK="vue"
  LANGUAGE="javascript/typescript"
  FRAMEWORK="vue"
  PACKAGE_MANAGER=$([ -f "yarn.lock" ] && echo "yarn" || ([ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "npm"))
# Angular
elif [ -f "angular.json" ]; then
  STACK="angular"
  LANGUAGE="typescript"
  FRAMEWORK="angular"
  PACKAGE_MANAGER=$([ -f "yarn.lock" ] && echo "yarn" || echo "npm")
# Svelte/SvelteKit
elif [ -f "svelte.config.js" ] || [ -f "svelte.config.ts" ]; then
  STACK="svelte"
  LANGUAGE="javascript/typescript"
  FRAMEWORK="svelte"
  PACKAGE_MANAGER=$([ -f "yarn.lock" ] && echo "yarn" || ([ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "npm"))
# Node.js (plain)
elif [ -f "package.json" ]; then
  STACK="nodejs"
  LANGUAGE="javascript/typescript"
  FRAMEWORK=$(grep -q '"express"' package.json 2>/dev/null && echo "express" || (grep -q '"fastify"' package.json 2>/dev/null && echo "fastify" || (grep -q '"nestjs"' package.json 2>/dev/null && echo "nestjs" || echo "nodejs")))
  PACKAGE_MANAGER=$([ -f "yarn.lock" ] && echo "yarn" || ([ -f "pnpm-lock.yaml" ] && echo "pnpm" || echo "npm"))
# Python
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "Pipfile" ]; then
  STACK="python"
  LANGUAGE="python"
  FRAMEWORK=$([ -f "manage.py" ] && echo "django" || (grep -q "fastapi" requirements.txt 2>/dev/null && echo "fastapi" || (grep -q "flask" requirements.txt 2>/dev/null && echo "flask" || echo "python")))
  PACKAGE_MANAGER=$([ -f "Pipfile" ] && echo "pipenv" || ([ -f "pyproject.toml" ] && echo "poetry" || echo "pip"))
# Go
elif [ -f "go.mod" ]; then
  STACK="go"
  LANGUAGE="go"
  FRAMEWORK="go"
  PACKAGE_MANAGER="go-modules"
# Rust
elif [ -f "Cargo.toml" ]; then
  STACK="rust"
  LANGUAGE="rust"
  FRAMEWORK="rust"
  PACKAGE_MANAGER="cargo"
# Swift/iOS
elif [ -f "Package.swift" ] || find . -maxdepth 2 -name "*.xcodeproj" -o -name "*.xcworkspace" 2>/dev/null | head -1 | grep -q .; then
  STACK="ios"
  LANGUAGE="swift"
  FRAMEWORK=$([ -f "Package.swift" ] && echo "spm" || echo "xcode")
  PACKAGE_MANAGER=$([ -f "Podfile" ] && echo "cocoapods" || ([ -f "Package.swift" ] && echo "spm" || echo "xcode"))
# Kotlin/Android
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  STACK="android"
  LANGUAGE="kotlin/java"
  FRAMEWORK=$(grep -q "compose" build.gradle 2>/dev/null && echo "jetpack-compose" || echo "android")
  PACKAGE_MANAGER="gradle"
fi

# Check for TypeScript
HAS_TS="false"
if [ -f "tsconfig.json" ]; then
  HAS_TS="true"
  if [ "$LANGUAGE" = "javascript/typescript" ]; then
    LANGUAGE="typescript"
  fi
fi

echo "    \"stack\": \"$STACK\","
echo "    \"language\": \"$LANGUAGE\","
echo "    \"framework\": \"$FRAMEWORK\","
echo "    \"packageManager\": \"$PACKAGE_MANAGER\","
echo "    \"typescript\": $HAS_TS"
echo '  },'

# ============================================================
# 2. PROJECT STRUCTURE
# ============================================================
echo '  "structure": {'

# Top-level directories
echo '    "topLevelDirs": ['
FIRST=true
for dir in $(find . -maxdepth 1 -type d ! -name '.' ! -name '.git' ! -name 'node_modules' ! -name '.dart_tool' ! -name 'build' ! -name '.gradle' ! -name '.idea' ! -name '.vscode' ! -name '__pycache__' ! -name '.next' ! -name '.nuxt' ! -name 'dist' ! -name '.claude' | sort | sed 's|^\./||'); do
  if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
  printf '      "%s"' "$dir"
done
echo ''
echo '    ],'

# Source directory
SRC_DIR="unknown"
if [ -d "lib" ]; then SRC_DIR="lib"
elif [ -d "src" ]; then SRC_DIR="src"
elif [ -d "app" ]; then SRC_DIR="app"
elif [ -d "pages" ]; then SRC_DIR="pages"
fi
echo "    \"sourceDir\": \"$SRC_DIR\","

# Key architecture directories (2 levels deep in source)
echo '    "architectureDirs": ['
if [ "$SRC_DIR" != "unknown" ] && [ -d "$SRC_DIR" ]; then
  FIRST=true
  for dir in $(find "$SRC_DIR" -maxdepth 2 -type d | sort | head -30 | sed 's|^\./||'); do
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '      "%s"' "$dir"
  done
  echo ''
fi
echo '    ],'

# File counts by extension
echo '    "fileCounts": {'
FIRST=true
for ext in dart ts tsx js jsx py go rs swift kt java vue svelte; do
  COUNT=$(find . -name "*.$ext" -not -path '*/node_modules/*' -not -path '*/.dart_tool/*' -not -path '*/build/*' -not -path '*/.next/*' -not -path '*/dist/*' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$COUNT" -gt 0 ]; then
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '      "%s": %s' "$ext" "$COUNT"
  fi
done
echo ''
echo '    }'
echo '  },'

# ============================================================
# 3. STATE MANAGEMENT
# ============================================================
echo '  "stateManagement": ['
FIRST=true

# Flutter state management
if [ "$STACK" = "flutter" ] && [ -f "pubspec.yaml" ]; then
  for pkg in flutter_bloc bloc provider riverpod get getx mobx redux; do
    if grep -q "$pkg" pubspec.yaml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '    "%s"' "$pkg"
    fi
  done
  # Check for freezed
  if grep -q "freezed" pubspec.yaml 2>/dev/null; then
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '    "freezed"'
  fi
fi

# JS/TS state management
if [ -f "package.json" ]; then
  for pkg in redux @reduxjs/toolkit zustand jotai recoil mobx vuex pinia @ngrx/store; do
    if grep -q "\"$pkg\"" package.json 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '    "%s"' "$pkg"
    fi
  done
fi
echo ''
echo '  ],'

# ============================================================
# 4. ROUTING / NAVIGATION
# ============================================================
echo '  "routing": ['
FIRST=true

if [ "$STACK" = "flutter" ] && [ -f "pubspec.yaml" ]; then
  for pkg in auto_route go_router beamer; do
    if grep -q "$pkg" pubspec.yaml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '    "%s"' "$pkg"
    fi
  done
fi

if [ -f "package.json" ]; then
  for pkg in react-router next/router @angular/router vue-router react-navigation; do
    if grep -q "\"$pkg\"" package.json 2>/dev/null || grep -q "'$pkg'" package.json 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '    "%s"' "$pkg"
    fi
  done
  # Next.js app router detection
  if [ -d "app" ] && ([ -f "next.config.js" ] || [ -f "next.config.ts" ] || [ -f "next.config.mjs" ]); then
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '    "nextjs-app-router"'
  fi
fi
echo ''
echo '  ],'

# ============================================================
# 5. DATA LAYER
# ============================================================
echo '  "dataLayer": {'

# API clients
echo '    "apiClients": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in dio http retrofit chopper; do
    if grep -q "$pkg" pubspec.yaml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
if [ -f "package.json" ]; then
  for pkg in axios fetch @tanstack/react-query swr apollo-client @apollo/client graphql-request; do
    if grep -q "\"$pkg\"" package.json 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
if [ -f "requirements.txt" ]; then
  for pkg in requests httpx aiohttp; do
    if grep -q "$pkg" requirements.txt 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
echo ''
echo '    ],'

# Database / Cache
echo '    "storage": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in objectbox hive sqflite shared_preferences drift floor isar; do
    if grep -q "$pkg" pubspec.yaml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
if [ -f "package.json" ]; then
  for pkg in prisma mongoose sequelize typeorm drizzle knex @supabase/supabase-js firebase @redis/client ioredis; do
    if grep -q "\"$pkg\"" package.json 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  for pkg in sqlalchemy django.db peewee tortoise-orm redis pymongo; do
    if grep -q "$pkg" requirements.txt 2>/dev/null || grep -q "$pkg" pyproject.toml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
echo ''
echo '    ],'

# Real-time / WebSocket
echo '    "realtime": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in web_socket_channel socket_io_client nats firebase_messaging livekit_client flutter_webrtc; do
    if grep -q "$pkg" pubspec.yaml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
if [ -f "package.json" ]; then
  for pkg in socket.io ws @socket.io/client pusher-js ably firebase; do
    if grep -q "\"$pkg\"" package.json 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
echo ''
echo '    ]'
echo '  },'

# ============================================================
# 6. DI / CODE GENERATION
# ============================================================
echo '  "tooling": {'
echo '    "di": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in get_it injectable; do
    if grep -q "$pkg" pubspec.yaml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
echo ''
echo '    ],'

echo '    "codeGen": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in build_runner json_serializable freezed auto_route lean_builder; do
    if grep -q "$pkg" pubspec.yaml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
echo ''
echo '    ],'

echo '    "testing": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in flutter_test mockito bloc_test integration_test; do
    if grep -q "$pkg" pubspec.yaml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
if [ -f "package.json" ]; then
  for pkg in jest vitest mocha @testing-library cypress playwright; do
    if grep -q "\"$pkg\"" package.json 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  for pkg in pytest unittest; do
    if grep -q "$pkg" requirements.txt 2>/dev/null || grep -q "$pkg" pyproject.toml 2>/dev/null; then
      if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
      printf '      "%s"' "$pkg"
    fi
  done
fi
echo ''
echo '    ],'

echo '    "linting": ['
FIRST=true
if [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
  FIRST=false; printf '      "eslint"'
fi
if [ -f ".prettierrc" ] || [ -f ".prettierrc.js" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
  if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
  printf '      "prettier"'
fi
if [ -f "analysis_options.yaml" ]; then
  if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
  printf '      "dart-analyzer"'
fi
echo ''
echo '    ]'
echo '  },'

# ============================================================
# 7. CONFIG FILES
# ============================================================
echo '  "configFiles": ['
FIRST=true
for f in .env .env.example .env.local docker-compose.yml Dockerfile Makefile CI.yml .github/workflows CLAUDE.md .gitignore; do
  if [ -e "$f" ] || find . -maxdepth 2 -path "*/$f" 2>/dev/null | head -1 | grep -q .; then
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '    "%s"' "$f"
  fi
done
echo ''
echo '  ],'

# ============================================================
# 8. GIT INFO
# ============================================================
echo '  "git": {'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  REMOTE=$(git remote get-url origin 2>/dev/null || echo "none")
  COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
  LAST_COMMIT=$(git log -1 --format="%s" 2>/dev/null || echo "none")
  echo "    \"branch\": \"$BRANCH\","
  echo "    \"remote\": \"$REMOTE\","
  echo "    \"commitCount\": $COMMIT_COUNT,"
  echo "    \"lastCommit\": \"$LAST_COMMIT\""
else
  echo "    \"initialized\": false"
fi
echo '  }'

echo "}"
