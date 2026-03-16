#!/bin/bash
# Transformers Project Detector v2
# Analyzes a project directory and outputs structured context
# Pure bash — no AI, runs in seconds
# Covers: Flutter, React, Next.js, React Native, Vue, Nuxt, Angular, Svelte,
#         Node.js, Python, Go, Rust, iOS/Swift, Android/Kotlin, Ruby/Rails,
#         PHP/Laravel, .NET/C#, Monorepos

set -euo pipefail

PROJECT_DIR="${1:-.}"
cd "$PROJECT_DIR"

# Helper: grep a file for a package name safely
pkg_exists() {
  local file="$1" pkg="$2"
  grep -q "$pkg" "$file" 2>/dev/null
}

# Helper: print JSON array item
json_arr_item() {
  local first_var="$1" value="$2"
  if [ "${!first_var}" = true ]; then eval "$first_var=false"; else echo ","; fi
  printf '      "%s"' "$value"
}

echo "{"

# ============================================================
# 1. TECH STACK DETECTION
# ============================================================
echo '  "techStack": {'

STACK="unknown"
LANGUAGE="unknown"
FRAMEWORK="unknown"
PACKAGE_MANAGER="unknown"

detect_js_pm() {
  [ -f "yarn.lock" ] && echo "yarn" && return
  [ -f "pnpm-lock.yaml" ] && echo "pnpm" && return
  [ -f "bun.lockb" ] && echo "bun" && return
  echo "npm"
}

# Flutter/Dart
if [ -f "pubspec.yaml" ]; then
  STACK="flutter"; LANGUAGE="dart"; FRAMEWORK="flutter"; PACKAGE_MANAGER="pub"
# React Native
elif [ -f "metro.config.js" ] || [ -f "metro.config.ts" ] || ([ -f "package.json" ] && pkg_exists package.json "react-native"); then
  STACK="react-native"; LANGUAGE="javascript/typescript"; FRAMEWORK="react-native"; PACKAGE_MANAGER=$(detect_js_pm)
# Next.js
elif [ -f "next.config.js" ] || [ -f "next.config.ts" ] || [ -f "next.config.mjs" ]; then
  STACK="nextjs"; LANGUAGE="javascript/typescript"; FRAMEWORK="nextjs"; PACKAGE_MANAGER=$(detect_js_pm)
# Nuxt
elif [ -f "nuxt.config.js" ] || [ -f "nuxt.config.ts" ]; then
  STACK="nuxt"; LANGUAGE="javascript/typescript"; FRAMEWORK="nuxt"; PACKAGE_MANAGER=$(detect_js_pm)
# Angular
elif [ -f "angular.json" ]; then
  STACK="angular"; LANGUAGE="typescript"; FRAMEWORK="angular"; PACKAGE_MANAGER=$(detect_js_pm)
# Svelte/SvelteKit
elif [ -f "svelte.config.js" ] || [ -f "svelte.config.ts" ]; then
  STACK="svelte"; LANGUAGE="javascript/typescript"; FRAMEWORK="svelte"; PACKAGE_MANAGER=$(detect_js_pm)
# React (plain)
elif [ -f "package.json" ] && pkg_exists package.json '"react"'; then
  STACK="react"; LANGUAGE="javascript/typescript"; FRAMEWORK="react"; PACKAGE_MANAGER=$(detect_js_pm)
# Vue
elif [ -f "package.json" ] && pkg_exists package.json '"vue"'; then
  STACK="vue"; LANGUAGE="javascript/typescript"; FRAMEWORK="vue"; PACKAGE_MANAGER=$(detect_js_pm)
# Ruby/Rails
elif [ -f "Gemfile" ]; then
  STACK="ruby"; LANGUAGE="ruby"
  FRAMEWORK=$([ -f "config/routes.rb" ] && echo "rails" || (pkg_exists Gemfile "sinatra" && echo "sinatra" || echo "ruby"))
  PACKAGE_MANAGER="bundler"
# PHP/Laravel
elif [ -f "composer.json" ]; then
  STACK="php"; LANGUAGE="php"
  FRAMEWORK=$([ -f "artisan" ] && echo "laravel" || (pkg_exists composer.json "symfony" && echo "symfony" || echo "php"))
  PACKAGE_MANAGER="composer"
# .NET/C#
elif find . -maxdepth 2 -name "*.csproj" -o -name "*.sln" 2>/dev/null | head -1 | grep -q .; then
  STACK="dotnet"; LANGUAGE="csharp"
  FRAMEWORK=$(find . -maxdepth 2 -name "*.csproj" -exec grep -l "Microsoft.AspNetCore" {} \; 2>/dev/null | head -1 | grep -q . && echo "aspnet" || echo "dotnet")
  PACKAGE_MANAGER="nuget"
# Python
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ] || [ -f "Pipfile" ]; then
  STACK="python"; LANGUAGE="python"
  FRAMEWORK="python"
  [ -f "manage.py" ] && FRAMEWORK="django"
  [ -f "requirements.txt" ] && pkg_exists requirements.txt "fastapi" && FRAMEWORK="fastapi"
  [ -f "requirements.txt" ] && pkg_exists requirements.txt "flask" && FRAMEWORK="flask"
  [ -f "pyproject.toml" ] && pkg_exists pyproject.toml "fastapi" && FRAMEWORK="fastapi"
  [ -f "pyproject.toml" ] && pkg_exists pyproject.toml "flask" && FRAMEWORK="flask"
  PACKAGE_MANAGER=$([ -f "Pipfile" ] && echo "pipenv" || ([ -f "poetry.lock" ] && echo "poetry" || ([ -f "uv.lock" ] && echo "uv" || echo "pip")))
# Go
elif [ -f "go.mod" ]; then
  STACK="go"; LANGUAGE="go"; PACKAGE_MANAGER="go-modules"
  FRAMEWORK="go"
  pkg_exists go.mod "gin-gonic/gin" && FRAMEWORK="gin"
  pkg_exists go.mod "labstack/echo" && FRAMEWORK="echo"
  pkg_exists go.mod "gofiber/fiber" && FRAMEWORK="fiber"
  pkg_exists go.mod "go-chi/chi" && FRAMEWORK="chi"
# Rust
elif [ -f "Cargo.toml" ]; then
  STACK="rust"; LANGUAGE="rust"; PACKAGE_MANAGER="cargo"
  FRAMEWORK="rust"
  pkg_exists Cargo.toml "actix-web" && FRAMEWORK="actix"
  pkg_exists Cargo.toml "axum" && FRAMEWORK="axum"
  pkg_exists Cargo.toml "rocket" && FRAMEWORK="rocket"
  pkg_exists Cargo.toml "warp" && FRAMEWORK="warp"
# Swift/iOS
elif [ -f "Package.swift" ] || find . -maxdepth 2 \( -name "*.xcodeproj" -o -name "*.xcworkspace" \) 2>/dev/null | head -1 | grep -q .; then
  STACK="ios"; LANGUAGE="swift"
  FRAMEWORK=$([ -f "Package.swift" ] && echo "spm" || echo "xcode")
  PACKAGE_MANAGER=$([ -f "Podfile" ] && echo "cocoapods" || ([ -f "Package.swift" ] && echo "spm" || echo "xcode"))
# Kotlin/Android
elif [ -f "build.gradle" ] || [ -f "build.gradle.kts" ]; then
  STACK="android"; LANGUAGE="kotlin/java"
  GRADLE_FILE=$([ -f "build.gradle.kts" ] && echo "build.gradle.kts" || echo "build.gradle")
  FRAMEWORK=$(pkg_exists "$GRADLE_FILE" "compose" && echo "jetpack-compose" || echo "android")
  PACKAGE_MANAGER="gradle"
# Node.js (fallback)
elif [ -f "package.json" ]; then
  STACK="nodejs"; LANGUAGE="javascript/typescript"; PACKAGE_MANAGER=$(detect_js_pm)
  FRAMEWORK="nodejs"
  pkg_exists package.json '"express"' && FRAMEWORK="express"
  pkg_exists package.json '"fastify"' && FRAMEWORK="fastify"
  pkg_exists package.json '"@nestjs/core"' && FRAMEWORK="nestjs"
  pkg_exists package.json '"hono"' && FRAMEWORK="hono"
  pkg_exists package.json '"koa"' && FRAMEWORK="koa"
fi

# TypeScript check
HAS_TS="false"
if [ -f "tsconfig.json" ]; then
  HAS_TS="true"
  [ "$LANGUAGE" = "javascript/typescript" ] && LANGUAGE="typescript"
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
for dir in $(find . -maxdepth 1 -type d ! -name '.' ! -name '.git' ! -name 'node_modules' ! -name '.dart_tool' ! -name 'build' ! -name '.gradle' ! -name '.idea' ! -name '.vscode' ! -name '__pycache__' ! -name '.next' ! -name '.nuxt' ! -name 'dist' ! -name '.claude' ! -name 'vendor' ! -name '.bundle' ! -name 'target' ! -name 'bin' ! -name 'obj' 2>/dev/null | sort | sed 's|^\./||'); do
  if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
  printf '      "%s"' "$dir"
done
echo ''
echo '    ],'

# Source directory
SRC_DIR="unknown"
for d in lib src app pages server api cmd internal; do
  if [ -d "$d" ]; then SRC_DIR="$d"; break; fi
done
echo "    \"sourceDir\": \"$SRC_DIR\","

# Architecture directories (2 levels deep)
echo '    "architectureDirs": ['
if [ "$SRC_DIR" != "unknown" ] && [ -d "$SRC_DIR" ]; then
  FIRST=true
  for dir in $(find "$SRC_DIR" -maxdepth 2 -type d 2>/dev/null | sort | head -40 | sed 's|^\./||'); do
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '      "%s"' "$dir"
  done
  echo ''
fi
echo '    ],'

# File counts
echo '    "fileCounts": {'
FIRST=true
for ext in dart ts tsx js jsx py go rs swift kt java vue svelte rb php cs; do
  COUNT=$(find . -name "*.$ext" -not -path '*/node_modules/*' -not -path '*/.dart_tool/*' -not -path '*/build/*' -not -path '*/.next/*' -not -path '*/dist/*' -not -path '*/vendor/*' -not -path '*/target/*' -not -path '*/bin/*' -not -path '*/obj/*' 2>/dev/null | wc -l | tr -d ' ')
  if [ "$COUNT" -gt 0 ]; then
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '      "%s": %s' "$ext" "$COUNT"
  fi
done
echo ''
echo '    }'
echo '  },'

# ============================================================
# 3. ARCHITECTURE PATTERNS
# ============================================================
echo '  "architecture": {'

# Detect architecture pattern from directory names
ARCH_PATTERN="unknown"
if [ -d "lib/domain" ] && [ -d "lib/infrastructure" ]; then ARCH_PATTERN="clean-architecture"
elif [ -d "lib/features" ] || [ -d "src/features" ]; then ARCH_PATTERN="feature-first"
elif [ -d "app/models" ] && [ -d "app/views" ] && [ -d "app/controllers" ]; then ARCH_PATTERN="mvc"
elif [ -d "src/models" ] && [ -d "src/views" ]; then ARCH_PATTERN="mvvm"
elif [ -d "src/components" ] && [ -d "src/pages" ]; then ARCH_PATTERN="component-based"
elif [ -d "src/modules" ]; then ARCH_PATTERN="modular"
elif [ -d "internal" ] && [ -d "cmd" ]; then ARCH_PATTERN="go-standard"
elif [ -d "src/handlers" ] || [ -d "src/routes" ]; then ARCH_PATTERN="route-handler"
fi
echo "    \"pattern\": \"$ARCH_PATTERN\","

# Detect naming convention from source files
NAMING="unknown"
if [ "$SRC_DIR" != "unknown" ]; then
  SAMPLE=$(find "$SRC_DIR" -maxdepth 3 -type f \( -name "*.dart" -o -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" -o -name "*.py" -o -name "*.go" -o -name "*.rs" -o -name "*.rb" -o -name "*.php" \) 2>/dev/null | head -20 | xargs -I {} basename {} 2>/dev/null)
  if echo "$SAMPLE" | grep -q '_'; then NAMING="snake_case"
  elif echo "$SAMPLE" | grep -qE '^[A-Z]'; then NAMING="PascalCase"
  elif echo "$SAMPLE" | grep -q '-'; then NAMING="kebab-case"
  else NAMING="camelCase"
  fi
fi
echo "    \"namingConvention\": \"$NAMING\","

# Entry points
echo '    "entryPoints": ['
FIRST=true
for f in lib/main.dart lib/main_dev.dart lib/main_alpha.dart src/index.ts src/index.js src/main.ts src/main.js app/page.tsx app/page.js pages/index.tsx pages/index.js pages/_app.tsx manage.py main.go cmd/main.go src/main.rs src/lib.rs Package.swift app/build.gradle Gemfile config.ru index.php artisan Program.cs; do
  if [ -f "$f" ]; then
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '      "%s"' "$f"
  fi
done
echo ''
echo '    ],'

# Test structure
echo '    "testStructure": {'
TEST_LOCATION="none"
TEST_PATTERN="unknown"
if [ -d "test" ]; then TEST_LOCATION="test/"
elif [ -d "tests" ]; then TEST_LOCATION="tests/"
elif [ -d "__tests__" ]; then TEST_LOCATION="__tests__/"
elif [ -d "spec" ]; then TEST_LOCATION="spec/"
elif find . -maxdepth 3 -name "*.test.*" -o -name "*.spec.*" 2>/dev/null | head -1 | grep -q .; then TEST_LOCATION="co-located"
fi

if [ "$TEST_LOCATION" = "co-located" ]; then
  TEST_PATTERN="co-located (tests beside source files)"
elif [ "$TEST_LOCATION" != "none" ]; then
  TEST_PATTERN="separate directory ($TEST_LOCATION)"
fi

TEST_COUNT=$(find . -name "*_test.*" -o -name "*.test.*" -o -name "*.spec.*" -o -name "*_spec.*" 2>/dev/null | grep -v node_modules | grep -v .dart_tool | wc -l | tr -d ' ')
echo "      \"location\": \"$TEST_LOCATION\","
echo "      \"pattern\": \"$TEST_PATTERN\","
echo "      \"testFileCount\": $TEST_COUNT"
echo '    },'

# Monorepo detection
echo '    "monorepo": {'
IS_MONOREPO="false"
MONOREPO_TOOL="none"
if [ -f "turbo.json" ]; then IS_MONOREPO="true"; MONOREPO_TOOL="turborepo"
elif [ -f "nx.json" ]; then IS_MONOREPO="true"; MONOREPO_TOOL="nx"
elif [ -f "lerna.json" ]; then IS_MONOREPO="true"; MONOREPO_TOOL="lerna"
elif [ -f "pnpm-workspace.yaml" ]; then IS_MONOREPO="true"; MONOREPO_TOOL="pnpm-workspaces"
elif [ -f "package.json" ] && pkg_exists package.json '"workspaces"'; then IS_MONOREPO="true"; MONOREPO_TOOL="npm-workspaces"
elif [ -d "packages" ] && [ -f "package.json" ]; then IS_MONOREPO="true"; MONOREPO_TOOL="inferred"
elif [ -f "melos.yaml" ]; then IS_MONOREPO="true"; MONOREPO_TOOL="melos"
fi
echo "      \"detected\": $IS_MONOREPO,"
echo "      \"tool\": \"$MONOREPO_TOOL\""
echo '    }'
echo '  },'

# ============================================================
# 4. STATE MANAGEMENT
# ============================================================
echo '  "stateManagement": ['
FIRST=true

# Flutter
if [ -f "pubspec.yaml" ]; then
  for pkg in flutter_bloc bloc provider riverpod get getx mobx redux freezed; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
# JS/TS
if [ -f "package.json" ]; then
  for pkg in redux @reduxjs/toolkit zustand jotai recoil mobx vuex pinia @ngrx/store signals @preact/signals; do
    pkg_exists package.json "\"$pkg\"" && { json_arr_item FIRST "$pkg"; }
  done
fi
# Ruby/Rails
if [ -f "Gemfile" ]; then
  for pkg in stimulus turbo-rails hotwire-rails; do
    pkg_exists Gemfile "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '  ],'

# ============================================================
# 5. ROUTING / NAVIGATION
# ============================================================
echo '  "routing": ['
FIRST=true

if [ -f "pubspec.yaml" ]; then
  for pkg in auto_route go_router beamer; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "package.json" ]; then
  for pkg in react-router react-router-dom next/router @angular/router vue-router react-navigation expo-router; do
    pkg_exists package.json "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
  # Next.js app router
  if [ -d "app" ] && ([ -f "next.config.js" ] || [ -f "next.config.ts" ] || [ -f "next.config.mjs" ]); then
    json_arr_item FIRST "nextjs-app-router"
  fi
fi
# Rails
if [ -f "config/routes.rb" ]; then json_arr_item FIRST "rails-routes"; fi
# Laravel
if [ -f "routes/web.php" ] || [ -f "routes/api.php" ]; then json_arr_item FIRST "laravel-routes"; fi
# Go
if [ -f "go.mod" ]; then
  for pkg in gorilla/mux go-chi/chi; do
    pkg_exists go.mod "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '  ],'

# ============================================================
# 6. DATA LAYER
# ============================================================
echo '  "dataLayer": {'

# API clients
echo '    "apiClients": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in dio http retrofit chopper graphql_flutter; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "package.json" ]; then
  for pkg in axios @tanstack/react-query swr apollo-client @apollo/client graphql-request @trpc/client urql got node-fetch ky; do
    pkg_exists package.json "\"$pkg\"" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  for pkg in requests httpx aiohttp urllib3; do
    ([ -f "requirements.txt" ] && pkg_exists requirements.txt "$pkg") || ([ -f "pyproject.toml" ] && pkg_exists pyproject.toml "$pkg") && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "go.mod" ]; then
  for pkg in net/http resty grpc; do
    pkg_exists go.mod "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "Gemfile" ]; then
  for pkg in faraday httparty rest-client; do
    pkg_exists Gemfile "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '    ],'

# Database / Storage
echo '    "storage": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in objectbox hive sqflite shared_preferences drift floor isar; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "package.json" ]; then
  for pkg in prisma mongoose sequelize typeorm drizzle-orm knex @supabase/supabase-js firebase @redis/client ioredis better-sqlite3 pg mysql2 @planetscale/database; do
    pkg_exists package.json "\"$pkg\"" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  for pkg in sqlalchemy django peewee tortoise-orm redis pymongo motor asyncpg psycopg2 alembic; do
    ([ -f "requirements.txt" ] && pkg_exists requirements.txt "$pkg") || ([ -f "pyproject.toml" ] && pkg_exists pyproject.toml "$pkg") && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "go.mod" ]; then
  for pkg in gorm database/sql sqlx ent pgx go-redis mongo-driver; do
    pkg_exists go.mod "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "Cargo.toml" ]; then
  for pkg in diesel sqlx sea-orm rusqlite; do
    pkg_exists Cargo.toml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "Gemfile" ]; then
  for pkg in activerecord sequel pg mysql2 redis sidekiq; do
    pkg_exists Gemfile "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "composer.json" ]; then
  for pkg in eloquent doctrine predis; do
    pkg_exists composer.json "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '    ],'

# Real-time
echo '    "realtime": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in web_socket_channel socket_io_client nats firebase_messaging livekit_client flutter_webrtc; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "package.json" ]; then
  for pkg in socket.io ws @socket.io/client pusher-js ably firebase @supabase/realtime-js livekit-client; do
    pkg_exists package.json "\"$pkg\"" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "go.mod" ]; then
  for pkg in gorilla/websocket nhooyr.io/websocket; do
    pkg_exists go.mod "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '    ],'

# Auth
echo '    "auth": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in firebase_auth google_sign_in; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "package.json" ]; then
  for pkg in next-auth @auth/core @clerk/nextjs firebase passport jsonwebtoken @supabase/auth-helpers lucia bcrypt; do
    pkg_exists package.json "\"$pkg\"" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  for pkg in djangorestframework-jwt pyjwt python-jose authlib; do
    ([ -f "requirements.txt" ] && pkg_exists requirements.txt "$pkg") || ([ -f "pyproject.toml" ] && pkg_exists pyproject.toml "$pkg") && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "Gemfile" ]; then
  for pkg in devise omniauth jwt; do
    pkg_exists Gemfile "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '    ]'
echo '  },'

# ============================================================
# 7. TOOLING
# ============================================================
echo '  "tooling": {'

# DI
echo '    "di": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in get_it injectable; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "package.json" ]; then
  for pkg in inversify tsyringe @nestjs/core; do
    pkg_exists package.json "\"$pkg\"" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '    ],'

# Code gen
echo '    "codeGen": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in build_runner json_serializable freezed auto_route lean_builder; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '    ],'

# Testing
echo '    "testing": ['
FIRST=true
if [ -f "pubspec.yaml" ]; then
  for pkg in flutter_test mockito bloc_test integration_test; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "package.json" ]; then
  for pkg in jest vitest mocha @testing-library cypress playwright @playwright/test storybook supertest; do
    pkg_exists package.json "\"$pkg\"" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "requirements.txt" ] || [ -f "pyproject.toml" ]; then
  for pkg in pytest unittest coverage; do
    ([ -f "requirements.txt" ] && pkg_exists requirements.txt "$pkg") || ([ -f "pyproject.toml" ] && pkg_exists pyproject.toml "$pkg") && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "go.mod" ]; then
  for pkg in testify gomock; do
    pkg_exists go.mod "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "Cargo.toml" ]; then
  pkg_exists Cargo.toml "\\[dev-dependencies\\]" && { json_arr_item FIRST "cargo-test"; }
fi
if [ -f "Gemfile" ]; then
  for pkg in rspec minitest capybara factory_bot; do
    pkg_exists Gemfile "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '    ],'

# Linting
echo '    "linting": ['
FIRST=true
if [ -f ".eslintrc" ] || [ -f ".eslintrc.js" ] || [ -f ".eslintrc.json" ] || [ -f "eslint.config.js" ] || [ -f "eslint.config.mjs" ]; then
  json_arr_item FIRST "eslint"
fi
if [ -f ".prettierrc" ] || [ -f ".prettierrc.js" ] || [ -f ".prettierrc.json" ] || [ -f "prettier.config.js" ]; then
  json_arr_item FIRST "prettier"
fi
[ -f "analysis_options.yaml" ] && json_arr_item FIRST "dart-analyzer"
[ -f ".rubocop.yml" ] && json_arr_item FIRST "rubocop"
[ -f ".pylintrc" ] || [ -f "pyproject.toml" ] && pkg_exists pyproject.toml "ruff" 2>/dev/null && json_arr_item FIRST "ruff"
[ -f ".golangci.yml" ] || [ -f ".golangci.yaml" ] && json_arr_item FIRST "golangci-lint"
[ -f "clippy.toml" ] && json_arr_item FIRST "clippy"
[ -f ".php-cs-fixer.php" ] || [ -f "phpstan.neon" ] && json_arr_item FIRST "phpstan"
[ -f "biome.json" ] && json_arr_item FIRST "biome"
echo ''
echo '    ],'

# UI / Design System
echo '    "ui": ['
FIRST=true
if [ -f "package.json" ]; then
  for pkg in tailwindcss @mui/material @chakra-ui/react @mantine/core @radix-ui styled-components @emotion/react antd; do
    pkg_exists package.json "\"$pkg\"" && { json_arr_item FIRST "$pkg"; }
  done
fi
if [ -f "tailwind.config.js" ] || [ -f "tailwind.config.ts" ]; then
  json_arr_item FIRST "tailwindcss" 2>/dev/null || true
fi
if [ -f "pubspec.yaml" ]; then
  for pkg in project_arwen material_design_icons_flutter; do
    pkg_exists pubspec.yaml "$pkg" && { json_arr_item FIRST "$pkg"; }
  done
fi
echo ''
echo '    ]'
echo '  },'

# ============================================================
# 8. CI/CD & INFRA
# ============================================================
echo '  "cicd": {'
echo '    "ci": ['
FIRST=true
[ -d ".github/workflows" ] && json_arr_item FIRST "github-actions"
[ -f ".gitlab-ci.yml" ] && json_arr_item FIRST "gitlab-ci"
[ -f ".circleci/config.yml" ] && json_arr_item FIRST "circleci"
[ -f "Jenkinsfile" ] && json_arr_item FIRST "jenkins"
[ -f "bitbucket-pipelines.yml" ] && json_arr_item FIRST "bitbucket-pipelines"
[ -f ".travis.yml" ] && json_arr_item FIRST "travis-ci"
[ -d "fastlane" ] && json_arr_item FIRST "fastlane"
[ -f "codemagic.yaml" ] && json_arr_item FIRST "codemagic"
echo ''
echo '    ],'

echo '    "containers": ['
FIRST=true
[ -f "Dockerfile" ] && json_arr_item FIRST "docker"
[ -f "docker-compose.yml" ] || [ -f "docker-compose.yaml" ] || [ -f "compose.yml" ] && json_arr_item FIRST "docker-compose"
[ -d "k8s" ] || [ -d "kubernetes" ] || find . -maxdepth 2 -name "*.yaml" -exec grep -l "kind: Deployment" {} \; 2>/dev/null | head -1 | grep -q . && json_arr_item FIRST "kubernetes"
[ -f "fly.toml" ] && json_arr_item FIRST "fly.io"
[ -f "vercel.json" ] && json_arr_item FIRST "vercel"
[ -f "netlify.toml" ] && json_arr_item FIRST "netlify"
[ -f "render.yaml" ] && json_arr_item FIRST "render"
echo ''
echo '    ]'
echo '  },'

# ============================================================
# 9. CONFIG FILES
# ============================================================
echo '  "configFiles": ['
FIRST=true
for f in .env .env.example .env.local docker-compose.yml Dockerfile Makefile CLAUDE.md .gitignore .dockerignore .editorconfig; do
  if [ -e "$f" ]; then
    if [ "$FIRST" = true ]; then FIRST=false; else echo ","; fi
    printf '    "%s"' "$f"
  fi
done
echo ''
echo '  ],'

# ============================================================
# 10. GIT INFO
# ============================================================
echo '  "git": {'
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  BRANCH=$(git branch --show-current 2>/dev/null || echo "unknown")
  REMOTE=$(git remote get-url origin 2>/dev/null || echo "none")
  COMMIT_COUNT=$(git rev-list --count HEAD 2>/dev/null || echo "0")
  LAST_COMMIT=$(git log -1 --format="%s" 2>/dev/null || echo "none")
  # Escape quotes in last commit message
  LAST_COMMIT=$(echo "$LAST_COMMIT" | sed 's/"/\\"/g')
  echo "    \"branch\": \"$BRANCH\","
  echo "    \"remote\": \"$REMOTE\","
  echo "    \"commitCount\": $COMMIT_COUNT,"
  echo "    \"lastCommit\": \"$LAST_COMMIT\""
else
  echo "    \"initialized\": false"
fi
echo '  }'

echo "}"
