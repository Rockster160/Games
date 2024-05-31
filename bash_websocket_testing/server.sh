#!/bin/bash

# Check if websocat is installed
if ! command -v websocat &> /dev/null; then
  echo "websocat could not be found. Please install it first."
  exit 1
fi

# Start a WebSocket server that broadcasts all received messages to all clients
echo "Starting WebSocket server on ws://0.0.0.0:8191"
websocat --binary reuse-l:0.0.0.0:8191 reuse-reusebroadcast:
