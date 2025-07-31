#!/bin/bash

# Football Stats Firebase Deployment Script

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
PROJECT_ID=${1:-"football-stats-app"}
ENVIRONMENT=${2:-"development"}

echo -e "${BLUE}🚀 Starting deployment for Football Stats App${NC}"
echo -e "${BLUE}Project: ${PROJECT_ID}${NC}"
echo -e "${BLUE}Environment: ${ENVIRONMENT}${NC}"
echo ""

# Function to print status
print_status() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    print_error "Firebase CLI is not installed. Please install it first:"
    echo "npm install -g firebase-tools"
    exit 1
fi

# Check if user is logged in
if ! firebase projects:list &> /dev/null; then
    print_error "You are not logged in to Firebase. Please run 'firebase login' first."
    exit 1
fi

# Set the active project
echo -e "${BLUE}📋 Setting active Firebase project...${NC}"
firebase use $PROJECT_ID --quiet
print_status "Active project set to $PROJECT_ID"

# Install functions dependencies
echo -e "${BLUE}📦 Installing Cloud Functions dependencies...${NC}"
cd functions
npm install
print_status "Dependencies installed"

# Run linting
echo -e "${BLUE}🔍 Running ESLint...${NC}"
npm run lint
print_status "Linting completed"

# Build TypeScript
echo -e "${BLUE}🏗️  Building TypeScript...${NC}"
npm run build
print_status "TypeScript build completed"

# Run tests if they exist
if [ -f "package.json" ] && grep -q "\"test\"" package.json; then
    echo -e "${BLUE}🧪 Running tests...${NC}"
    npm test
    print_status "Tests passed"
else
    print_warning "No tests found, skipping test phase"
fi

# Go back to root directory
cd ..

# Deploy based on environment
case $ENVIRONMENT in
    "development" | "dev")
        echo -e "${BLUE}🚀 Deploying to development environment...${NC}"
        firebase deploy --only functions,firestore:rules,firestore:indexes,storage
        ;;
    "staging")
        echo -e "${BLUE}🚀 Deploying to staging environment...${NC}"
        firebase use football-stats-staging --quiet
        firebase deploy --only functions,firestore:rules,firestore:indexes,storage
        ;;
    "production" | "prod")
        echo -e "${BLUE}🚀 Deploying to production environment...${NC}"
        firebase use football-stats-prod --quiet
        
        # Additional confirmation for production
        echo -e "${YELLOW}⚠️  You are about to deploy to PRODUCTION. Are you sure? (y/N)${NC}"
        read -r confirmation
        if [[ $confirmation == [yY] || $confirmation == [yY][eE][sS] ]]; then
            firebase deploy --only functions,firestore:rules,firestore:indexes,storage
        else
            print_error "Production deployment cancelled by user"
            exit 1
        fi
        ;;
    *)
        print_error "Unknown environment: $ENVIRONMENT"
        echo "Supported environments: development, staging, production"
        exit 1
        ;;
esac

print_status "Deployment completed successfully!"

# Display useful information
echo ""
echo -e "${BLUE}📋 Deployment Summary:${NC}"
echo -e "${GREEN}  ✅ Cloud Functions deployed${NC}"
echo -e "${GREEN}  ✅ Firestore rules deployed${NC}"
echo -e "${GREEN}  ✅ Firestore indexes deployed${NC}"
echo -e "${GREEN}  ✅ Storage rules deployed${NC}"
echo ""

# Get function URLs
echo -e "${BLUE}🔗 Function URLs:${NC}"
firebase functions:list --filter="api" 2>/dev/null | grep -E "https://" || echo "  No HTTP functions found or not accessible"

echo ""
echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
echo -e "${BLUE}📚 Next steps:${NC}"
echo "  1. Test your API endpoints"
echo "  2. Monitor logs: firebase functions:log"
echo "  3. Check Firebase Console for any issues"
echo ""