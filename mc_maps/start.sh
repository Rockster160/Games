#!/bin/bash
# Make sure to run the below!
# `chmod a+x GroupGame/demo/js/puzzle.sh`

# python3 -c "import webbrowser; webbrowser.open('http://localhost:8080')"

script_directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# python3 -m http.server 8081 -d $script_directory
python3 $script_directory/server.py

# http://localhost:8000/worlds/ronaya/nether.js
