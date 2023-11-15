#!/usr/bin/env bash

kill `ps aux | grep sidekiq | grep -v grep | awk '{print $2}'` &&
lsof -t -i:3004 | xargs kill -9