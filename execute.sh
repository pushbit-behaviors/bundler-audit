#!/bin/bash

echo "Setting git defaults"
git config --global user.email "bot@pushbit.co"
git config --global user.name "Pushbit"
git config --global push.default simple

echo "Updating security advisories"
bundle-audit update

echo "cloning git repo"
hub clone https://${GITHUB_TOKEN}@github.com/${GITHUB_USER}/${GITHUB_REPO}.git target 

echo "checking Gemfile.lock for security vulnerabilities"
ruby ./app/execute.rb
