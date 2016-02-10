#!/bin/bash

echo "Updating security advisories"
bundle-audit update

echo "Checking Gemfile.lock for security vulnerabilities"
ruby ./app/execute.rb