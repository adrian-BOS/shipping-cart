#!/bin/bash

echo "🚀 Deploying Cash Register to Heroku with PostgreSQL"

# Check if Heroku CLI is installed
if ! command -v heroku &> /dev/null; then
    echo "❌ Heroku CLI not found. Please install it first."
    exit 1
fi

# Check if logged in
if ! heroku auth:whoami &> /dev/null; then
    echo "🔐 Please login to Heroku..."
    heroku login
fi

echo "📱 Adding Heroku remote..."
heroku git:remote -a shopping-cart-adrian

echo "🗄️ Adding PostgreSQL database..."
heroku addons:create heroku-postgresql:mini

echo "⚙️ Setting environment variables..."
heroku config:set RAILS_ENV=production
heroku config:set RAILS_SERVE_STATIC_FILES=true
heroku config:set RAILS_LOG_TO_STDOUT=true

echo "💾 Committing changes..."
git add .
git commit -m "Switch to PostgreSQL for production"

echo "🚀 Deploying..."
git push heroku main

echo "🗄️ Setting up database..."
heroku run rails db:migrate
heroku run rails db:seed

echo "🌐 Opening app..."
heroku open

echo "✅ Done! Your app is live at: https://quiet-wave-05593.herokuapp.com"
echo "🗄️ Database: PostgreSQL (persistent)"
