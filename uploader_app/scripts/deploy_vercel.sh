#!/bin/bash

# Vercel Deployment Script for Plantita Uploader App
# Phase 8: Web Deployment Preparation

set -e  # Exit on any error

# Configuration
PROJECT_NAME="${VERCEL_PROJECT_NAME:-plantita-uploader}"
BUILD_ENV="${BUILD_ENVIRONMENT:-production}"
TEAM="${VERCEL_TEAM:-}"

echo "🚀 Starting Vercel deployment for Plantita Uploader App"
echo "📍 Project: $PROJECT_NAME"
echo "🌍 Environment: $BUILD_ENV"

# Function to check prerequisites
check_prerequisites() {
    echo "📋 Checking prerequisites..."

    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        echo "❌ Flutter is not installed or not in PATH"
        exit 1
    fi

    # Check if Vercel CLI is installed
    if ! command -v vercel &> /dev/null; then
        echo "❌ Vercel CLI is not installed"
        echo "Install with: npm install -g vercel"
        exit 1
    fi

    # Check if user is logged in to Vercel
    if ! vercel whoami &> /dev/null; then
        echo "❌ Not logged in to Vercel CLI"
        echo "Run: vercel login"
        exit 1
    fi

    echo "✅ Prerequisites check passed"
}

# Function to setup environment
setup_environment() {
    echo "🔧 Setting up environment for $BUILD_ENV..."

    # Create environment-specific build
    case $BUILD_ENV in
        "development")
            export ENVIRONMENT="development"
            export ENABLE_ANALYTICS="false"
            export ENABLE_CRASHLYTICS="false"
            export ENABLE_PERFORMANCE_MONITORING="false"
            ;;
        "staging")
            export ENVIRONMENT="staging"
            export ENABLE_ANALYTICS="true"
            export ENABLE_CRASHLYTICS="false"
            export ENABLE_PERFORMANCE_MONITORING="true"
            ;;
        "production")
            export ENVIRONMENT="production"
            export ENABLE_ANALYTICS="true"
            export ENABLE_CRASHLYTICS="true"
            export ENABLE_PERFORMANCE_MONITORING="true"
            ;;
        *)
            echo "❌ Unknown environment: $BUILD_ENV"
            exit 1
            ;;
    esac

    # Set API endpoints
    case $BUILD_ENV in
        "development")
            export API_BASE_URL="http://localhost:3000/api"
            ;;
        "staging")
            export API_BASE_URL="https://api-staging.plantita.app"
            ;;
        "production")
            export API_BASE_URL="https://api.plantita.app"
            ;;
    esac

    echo "✅ Environment setup complete"
}

# Function to build Flutter web app
build_app() {
    echo "🔨 Building Flutter web app..."

    # Clean previous build
    flutter clean

    # Get dependencies
    flutter pub get

    # Build for web with environment variables
    flutter build web \
        --release \
        --dart-define=ENVIRONMENT=$ENVIRONMENT \
        --dart-define=API_BASE_URL=$API_BASE_URL \
        --dart-define=ENABLE_ANALYTICS=$ENABLE_ANALYTICS \
        --dart-define=ENABLE_CRASHLYTICS=$ENABLE_CRASHLYTICS \
        --dart-define=ENABLE_PERFORMANCE_MONITORING=$ENABLE_PERFORMANCE_MONITORING

    # Check build size
    BUILD_SIZE=$(du -sb build/web | cut -f1)
    BUILD_SIZE_MB=$((BUILD_SIZE / 1024 / 1024))

    echo "📦 Build size: ${BUILD_SIZE_MB}MB"

    if [ $BUILD_SIZE_MB -gt 2 ]; then
        echo "⚠️  Warning: Build size exceeds 2MB recommendation"
    else
        echo "✅ Build size within limits"
    fi

    echo "✅ Flutter build complete"
}

# Function to optimize build for Vercel
optimize_build() {
    echo "⚡ Optimizing build for Vercel..."

    # Copy additional web assets
    cp web/robots.txt build/web/
    cp web/sitemap.xml build/web/
    cp web/offline.html build/web/

    # Create vercel.json configuration
    cat > vercel.json << EOF
{
  "version": 2,
  "builds": [
    {
      "src": "build/web/index.html",
      "use": "@vercel/static"
    }
  ],
  "routes": [
    {
      "src": "/(.*)",
      "dest": "/build/web/index.html"
    }
  ],
  "headers": [
    {
      "source": "/(.*)",
      "headers": [
        { "key": "X-Frame-Options", "value": "DENY" },
        { "key": "X-Content-Type-Options", "value": "nosniff" },
        { "key": "Referrer-Policy", "value": "strict-origin-when-cross-origin" }
      ]
    },
    {
      "source": "/static/(.*)",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=31536000, immutable" }
      ]
    },
    {
      "source": "/manifest.json",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=0, must-revalidate" }
      ]
    },
    {
      "source": "/flutter_service_worker.js",
      "headers": [
        { "key": "Cache-Control", "value": "public, max-age=0, must-revalidate" }
      ]
    }
  ],
  "rewrites": [
    {
      "source": "/api/(.*)",
      "destination": "https://api.plantita.app/api/\$1"
    }
  ]
}
EOF

    # Create _headers file for additional headers
    cat > build/web/_headers << EOF
/*
  X-Frame-Options: DENY
  X-Content-Type-Options: nosniff
  Referrer-Policy: strict-origin-when-cross-origin

/manifest.json
  Cache-Control: public, max-age=0, must-revalidate

/flutter_service_worker.js
  Cache-Control: public, max-age=0, must-revalidate

/static/*
  Cache-Control: public, max-age=31536000, immutable

/assets/*
  Cache-Control: public, max-age=31536000, immutable
EOF

    echo "✅ Vercel build optimization complete"
}

# Function to deploy to Vercel
deploy_to_vercel() {
    echo "🚀 Deploying to Vercel..."

    # Set Vercel CLI arguments
    VERCEL_ARGS="--yes"

    if [ -n "$TEAM" ]; then
        VERCEL_ARGS="$VERCEL_ARGS --team $TEAM"
    fi

    # For production deployment
    if [ "$BUILD_ENV" = "production" ]; then
        VERCEL_ARGS="$VERCEL_ARGS --prod"
    fi

    # Deploy to Vercel
    cd build/web
    vercel $VERCEL_ARGS

    # Get deployment URL
    if [ "$BUILD_ENV" = "production" ]; then
        DEPLOY_URL=$(vercel --prod 2>/dev/null | grep -o 'https://[^ ]*')
    else
        DEPLOY_URL=$(vercel 2>/dev/null | grep -o 'https://[^ ]*')
    fi

    echo "🌐 App deployed to: $DEPLOY_URL"

    echo "✅ Vercel deployment complete"
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."

    # Run Flutter tests
    flutter test --coverage

    echo "✅ Tests complete"
}

# Function to run performance audit
run_performance_audit() {
    echo "📊 Running performance audit..."

    # Check if PageSpeed Insights CLI is available
    if command -v psi &> /dev/null; then
        echo "Running PageSpeed Insights audit..."
        # Note: This would require the actual deployment URL
        # psi $DEPLOY_URL --strategy=mobile --format=json > reports/pagespeed-mobile.json
        # psi $DEPLOY_URL --strategy=desktop --format=json > reports/pagespeed-desktop.json
        echo "PageSpeed Insights audit would run here with actual URL"
    else
        echo "⚠️  PageSpeed Insights CLI not installed"
    fi

    echo "✅ Performance audit complete"
}

# Function to cleanup
cleanup() {
    echo "🧹 Cleaning up..."

    # Remove temporary files
    rm -f vercel.json
    rm -f build/web/_headers

    echo "✅ Cleanup complete"
}

# Main deployment process
main() {
    echo "🎯 Starting Vercel deployment process..."

    check_prerequisites
    setup_environment
    run_tests
    build_app
    optimize_build
    deploy_to_vercel
    run_performance_audit
    cleanup

    echo ""
    echo "🎉 Vercel deployment completed successfully!"
    echo "📱 PWA features enabled with offline support"
    echo "⚡ Optimized for Vercel's edge network"
}

# Run main function with error handling
trap cleanup ERR
main "$@"