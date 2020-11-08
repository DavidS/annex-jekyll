#!/bin/bash

set -evx

git annex post-receive

# reset environment for ruby and gemspecs
unset GIT_DIR
export JEKYLL_ENV=production

bundle config set --local path ../gems
bundle install
bundle exec jekyll build --strict --trace --destination ../site --verbose --incremental
bundle clean
