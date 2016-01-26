#!/bin/bash

echo "Updating security advisories"
bundle-audit update

echo "checking Gemfile.lock for security vulnerabilities"
ruby ./execute.rb
