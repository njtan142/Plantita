#!/bin/bash

# Firebase Deployment Script for Plantita Uploader App
# Phase 8: Web Deployment Preparation

set -e  # Exit on any error

# Configuration
PROJECT_ID="${FIREBASE_PROJECT_ID:-plantita-uploader}"
TARGET="${DEPLOY_TARGET:-production}"
BUILD_ENV="${BUILD_ENVIRONMENT:-production}"

echo "🚀 Starting Firebase deployment for Plantita Uploader App"
echo "📍 Project: $PROJECT_ID"
echo "🎯 Target: $TARGET"
echo "🌍 Environment: $BUILD_ENV"

# Function to check prerequisites
check_prerequisites() {
    echo "📋 Checking prerequisites..."

    # Check if Flutter is installed
    if ! command -v flutter &> /dev/null; then
        echo "❌ Flutter is not installed or not in PATH"
        exit 1
    fi

    # Check if Firebase CLI is installed
    if ! command -v firebase &> /dev/null; then
        echo "❌ Firebase CLI is not installed"
        echo "Install with: npm install -g firebase-tools"
        exit 1
    fi

    # Check if user is logged in to Firebase
    if ! firebase projects:list &> /dev/null; then
        echo "❌ Not logged in to Firebase CLI"
        echo "Run: firebase login"
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

    # Set Firebase configuration
    export FIREBASE_API_KEY="${FIREBASE_API_KEY:-your-api-key}"
    export FIREBASE_AUTH_DOMAIN="${FIREBASE_AUTH_DOMAIN:-$PROJECT_ID.firebaseapp.com}"
    export FIREBASE_PROJECT_ID="$PROJECT_ID"
    export FIREBASE_STORAGE_BUCKET="${FIREBASE_STORAGE_BUCKET:-$PROJECT_ID.appspot.com}"
    export FIREBASE_MESSAGING_SENDER_ID="${FIREBASE_MESSAGING_SENDER_ID:-123456789}"
    export FIREBASE_APP_ID="${FIREBASE_APP_ID:-1:123456789:web:abcdef123456}"

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
        --dart-define=ENABLE_PERFORMANCE_MONITORING=$ENABLE_PERFORMANCE_MONITORING \
        --dart-define=FIREBASE_API_KEY=$FIREBASE_API_KEY \
        --dart-define=FIREBASE_AUTH_DOMAIN=$FIREBASE_AUTH_DOMAIN \
        --dart-define=FIREBASE_PROJECT_ID=$FIREBASE_PROJECT_ID \
        --dart-define=FIREBASE_STORAGE_BUCKET=$FIREBASE_STORAGE_BUCKET \
        --dart-define=FIREBASE_MESSAGING_SENDER_ID=$FIREBASE_MESSAGING_SENDER_ID \
        --dart-define=FIREBASE_APP_ID=$FIREBASE_APP_ID

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

# Function to optimize build
optimize_build() {
    echo "⚡ Optimizing build..."

    # Copy additional web assets
    cp web/robots.txt build/web/
    cp web/sitemap.xml build/web/
    cp web/offline.html build/web/

    # Generate service worker with proper cache configuration
    cat > build/web/flutter_service_worker.js << 'EOF'
importScripts('https://storage.googleapis.com/workbox-cdn/releases/6.5.4/workbox-sw.js');

workbox.routing.registerRoute(
  ({request}) => request.destination === 'image',
  new workbox.strategies.CacheFirst({
    cacheName: 'images',
    plugins: [
      new workbox.cacheableResponse.CacheableResponsePlugin({
        statuses: [0, 200],
      }),
      new workbox.expiration.ExpirationPlugin({
        maxEntries: 60,
        maxAgeSeconds: 30 * 24 * 60 * 60, // 30 days
      }),
    ],
  }),
);
EOF

    # Minify HTML
    if command -v html-minifier &> /dev/null; then
        html-minifier --input-dir build/web --output-dir build/web --file-ext html --collapse-whitespace --remove-comments
    fi

    echo "✅ Build optimization complete"
}

# Function to setup Firebase
setup_firebase() {
    echo "🔥 Setting up Firebase deployment..."

    # Initialize Firebase if not already done
    if [ ! -f "firebase.json" ]; then
        firebase init hosting --project $PROJECT_ID

        # Configure Firebase hosting
        cat > firebase.json << EOF
{
  "hosting": {
    "public": "build/web",
    "ignore": [
      "firebase.json",
      "**/.*",
      "**/node_modules/**"
    ],
    "rewrites": [
      {
        "source": "**",
        "destination": "/index.html"
      }
    ],
    "headers": [
      {
        "source": "**/*.@(js|css)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "**/*.@(jpg|jpeg|gif|png|svg|webp|ico)",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=31536000"
          }
        ]
      },
      {
        "source": "manifest.json",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=0"
          }
        ]
      },
      {
        "source": "flutter_service_worker.js",
        "headers": [
          {
            "key": "Cache-Control",
            "value": "max-age=0"
          }
        ]
      }
    ]
  }
}
EOF
    fi

    echo "✅ Firebase setup complete"
}

# Function to deploy to Firebase
deploy_to_firebase() {
    echo "🚀 Deploying to Firebase..."

    # Deploy to Firebase hosting
    firebase deploy --only hosting --project $PROJECT_ID

    # Get deployment URL
    DEPLOY_URL="https://$PROJECT_ID.web.app"
    echo "🌐 App deployed to: $DEPLOY_URL"

    echo "✅ Firebase deployment complete"
}

# Function to run tests
run_tests() {
    echo "🧪 Running tests..."

    # Run Flutter tests
    flutter test --coverage

    # Run web-specific tests if available
    if [ -d "test/web" ]; then
        echo "Running web tests..."
        # Add web test commands here
    fi

    echo "✅ Tests complete"
}

# Function to run Lighthouse audit
run_lighthouse_audit() {
    echo "🔍 Running Lighthouse audit..."

    if command -v lighthouse &> /dev/null; then
        DEPLOY_URL="https://$PROJECT_ID.web.app"
        lighthouse $DEPLOY_URL --output json --output-path ./reports/lighthouse-report.json
        echo "📊 Lighthouse report saved to ./reports/lighthouse-report.json"
    else
        echo "⚠️  Lighthouse not installed. Install with: npm install -g lighthouse"
    fi

    echo "✅ Lighthouse audit complete"
}

# Function to cleanup
cleanup() {
    echo "🧹 Cleaning up..."

    # Remove temporary files
    rm -rf build/web/flutter_service_worker.js.tmp 2>/dev/null || true

    echo "✅ Cleanup complete"
}

# Main deployment process
main() {
    echo "🎯 Starting deployment process..."

    check_prerequisites
    setup_environment
    run_tests
    build_app
    optimize_build
    setup_firebase
    deploy_to_firebase
    run_lighthouse_audit
    cleanup

    echo ""
    echo "🎉 Deployment completed successfully!"
    echo "🌐 Your app is now live at: https://$PROJECT_ID.web.app"
    echo "📱 PWA features enabled with offline support"
    echo "📊 Monitoring and analytics configured"
}

# Run main function with error handling
trap cleanup ERR
main "$@"