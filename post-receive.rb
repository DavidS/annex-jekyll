#!/usr/bin/env ruby

require "open3"

pushed_refs = $stdin.readlines

output, status = Open3.capture2e("git annex post-receive", stdin_data: pushed_refs.join("\n"))

puts output

system("bundle config set --local path ../gems")
system("bundle install")
system("bundle clean")
system("JEKYLL_ENV=production bundle exec jekyll build --strict --trace --destination ../site --verbose --incremental")
