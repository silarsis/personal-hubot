#!/bin/bash

export HUBOT_LOG_LEVEL=debug

redis-server &
bin/hubot
