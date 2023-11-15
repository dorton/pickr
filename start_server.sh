#!/usr/bin/env bash
RAILS_ENV=production rails db:migrate &&
RAILS_ENV=production rails assets:precompile && 
bundle exec sidekiq -e production &
rails s -b 192.168.86.173 -p 3004 -e production -d
