#!/usr/bin/env bash

lsof -t -i:3004 | xargs kill -9