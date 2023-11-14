#!/usr/bin/env bash

RAILS_ENV=production rails assets:precompile && rails s -b 192.168.86.173 -p 3004 -e production -d
