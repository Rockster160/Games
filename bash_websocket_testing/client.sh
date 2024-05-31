#!/bin/bash

# Check if websocat is installed
if ! command -v websocat &> /dev/null; then
  echo "websocat could not be found. Please install it first."
  exit 1
fi

# Define the server's WebSocket URL
SERVER_URL="ws://localhost:8191"

# Connect to the WebSocket server and enable user input
echo "Connecting to $SERVER_URL"
echo "Type messages and press enter to send. Ctrl+C to quit."
websocat --ws-c-uri "$SERVER_URL" -b -
