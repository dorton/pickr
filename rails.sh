#!/usr/bin/env bash
git pull &&
./stop_server.sh &&
./start_server.sh
