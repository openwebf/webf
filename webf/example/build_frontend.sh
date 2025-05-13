#!/bin/bash

echo "Building all front-end projects..."

# List of directories with package.json files
PROJECTS=(
  "cupertino_gallery"
  "echarts"
  "hybrid_router"
  "news_miracleplus"
  "react_project"
  "tailwind_react"
  "use_cases"
  "vue_project"
)

# Total number of projects for progress tracking
TOTAL=${#PROJECTS[@]}
CURRENT=0

for project in "${PROJECTS[@]}"; do
  CURRENT=$((CURRENT + 1))
  echo "[$CURRENT/$TOTAL] Building $project..."

  # Enter project directory
  cd "$project" || { echo "Failed to enter $project directory"; continue; }

  # Install dependencies and build
  echo "Installing dependencies for $project..."
  npm install

  echo "Building $project..."
  npm run build

  # Return to main directory
  cd ..

  echo "✅ Completed $project"
  echo "----------------------------------------"
done

echo "All projects built successfully!"
