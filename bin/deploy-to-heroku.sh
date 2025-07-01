#!/bin/bash

echo "🚀 Cash Register - Heroku Deployment Script"
echo "=============================================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if Heroku CLI is installed
print_status "Checking Heroku CLI installation..."
if ! command -v heroku &> /dev/null; then
    print_error "Heroku CLI is not installed!"
    echo "Please install it first:"
    echo "  macOS: brew tap heroku/brew && brew install heroku"
    echo "  Ubuntu: curl https://cli-assets.heroku.com/install-ubuntu.sh | sh"
    echo "  Windows: Download from https://devcenter.heroku.com/articles/heroku-cli"
    exit 1
fi
print_success "Heroku CLI is installed"

# Check if user is logged in to Heroku
print_status "Checking Heroku login status..."
if ! heroku auth:whoami &> /dev/null; then
    print_warning "Not logged in to Heroku"
    print_status "Please login to Heroku..."
    heroku login
    if [ $? -ne 0 ]; then
        print_error "Failed to login to Heroku"
        exit 1
    fi
fi
print_success "Logged in as: $(heroku auth:whoami)"

# Get app name
print_status "Getting Heroku app name..."
APP_NAME="shopping-cart-adrian"
print_success "Using app: $APP_NAME"

# Add Heroku remote
print_status "Adding Heroku remote..."
heroku git:remote -a $APP_NAME
if [ $? -ne 0 ]; then
    print_error "Failed to add Heroku remote"
    exit 1
fi
print_success "Heroku remote added"

# Check if PostgreSQL is already added
print_status "Checking PostgreSQL database..."
if ! heroku addons:info heroku-postgresql &> /dev/null; then
    print_warning "PostgreSQL not found, adding it..."
    heroku addons:create heroku-postgresql:mini
    if [ $? -ne 0 ]; then
        print_error "Failed to add PostgreSQL"
        exit 1
    fi
    print_success "PostgreSQL added successfully"
else
    print_success "PostgreSQL already exists"
fi

# Set environment variables
print_status "Setting environment variables..."
heroku config:set RAILS_ENV=production
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set RAILS_LOG_TO_STDOUT=true
print_success "Environment variables set"

# Check if there are uncommitted changes
print_status "Checking for uncommitted changes..."
if ! git diff-index --quiet HEAD --; then
    print_warning "Found uncommitted changes"
    print_status "Committing changes..."
    git add .
    git commit -m "Deploy to Heroku with PostgreSQL - $(date)"
    print_success "Changes committed"
else
    print_success "No uncommitted changes found"
fi

# Deploy to Heroku
print_status "Deploying to Heroku..."
print_status "This may take a few minutes..."
git push heroku main
if [ $? -ne 0 ]; then
    print_error "Deployment failed!"
    exit 1
fi
print_success "Code deployed successfully"

# Setup database
print_status "Setting up database..."
heroku run rails db:migrate
if [ $? -ne 0 ]; then
    print_error "Database migration failed!"
    exit 1
fi

heroku run rails db:seed
if [ $? -ne 0 ]; then
    print_error "Database seeding failed!"
    exit 1
fi
print_success "Database setup complete"

# Open the app
print_status "Opening your app..."
heroku open

echo ""
echo "🎉 ${GREEN}DEPLOYMENT COMPLETE!${NC}"
echo "=============================================="
echo "🌐 Your app is live at: https://$APP_NAME.herokuapp.com"
echo "🗄️ Database: PostgreSQL (persistent)"
echo ""
echo "📊 Useful commands:"
echo "  heroku logs --tail          # View live logs"
echo "  heroku restart              # Restart the app"
echo "  heroku run rails console    # Access Rails console"
echo "  heroku ps                   # Check app status"
echo "  heroku pg:info              # Check database info"
echo ""
echo "🔧 Your Cash Register features:"
echo "  ✅ Product catalog (Green Tea, Strawberries, Coffee)"
echo "  ✅ Shopping cart with real-time updates"
echo "  ✅ Special pricing rules with progress bars"
echo "  ✅ Buy One Get One Free promotions"
echo "  ✅ Bulk discounts"
echo "  ✅ Percentage discounts"
echo ""
print_success "Happy selling! 🛒"
