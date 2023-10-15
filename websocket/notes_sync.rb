require "websocket/driver"
require "socket"
require "uri"
require "json"

# Replace "wss://example.com/socket" with your WebSocket URL
websocket_url = "wss://ardesian.com/socket"
uri = URI.parse(websocket_url)

# Replace "your_auth_token" with the actual authentication token
auth_token = "your_auth_token"

# Replace "file_paths" with a hash where keys are file paths and values are file IDs
file_paths = {
  "path/to/file1.txt" => 1,
  "path/to/file2.txt" => 2
}

def connect_to_websocket(uri, auth_token, file_paths)
  loop do
    begin
      socket = TCPSocket.new(uri.host, uri.port)
      driver = WebSocket::Driver.client(socket)

      # Add authentication headers
      driver.add_header("Authorization", "Bearer #{Base64.urlsafe_encode64("Rockster160:#{ENV["LOCAL_ME_PASS"]}")}")

      driver.on(:message) do |event|
        handle_server_message(event.data, file_paths, driver)
      end

      driver.on(:close) do |_event|
        puts "Connection closed"
        socket.close
        break
      end

      driver.start

      # Send a message after the connection is established to request timestamps
      request_timestamps(driver, file_paths)

      loop do
        # This loop keeps the script running to receive messages asynchronously
        driver.parse(socket.recv(1024))
        sleep 1 # Adjust the sleep time as needed
      end
    rescue StandardError => e
      puts "Error: #{e.message}"
      sleep 5 # wait before attempting to reconnect
    end
  end
end

def request_timestamps(driver, file_paths)
  # Request timestamps for each file from the server
  request = {
    action: "request_timestamps",
    files: file_paths.values
  }

  driver.text(request.to_json)
end

def handle_server_message(message, file_paths, driver)
  data = JSON.parse(message)

  case data["action"]
  when "timestamps_response"
    handle_timestamps_response(data, file_paths, driver)
  when "file_update_request"
    handle_file_update_request(data, file_paths, driver)
  else
    puts "Unknown action: #{data["action"]}"
  end
end

def handle_timestamps_response(data, file_paths, driver)
  timestamps = data["timestamps"]

  file_paths.each do |file_path, file_id|
    local_timestamp = File.mtime(file_path).to_i

    if timestamps[file_id] > local_timestamp
      # Server has a newer version, request the file
      request_file_contents(driver, file_id)
    elsif timestamps[file_id] < local_timestamp
      # Local version is newer, send file contents to the server
      send_file_contents(driver, file_path, file_id)
    end
  end
end

def request_file_contents(driver, file_id)
  request = {
    action: "request_file_contents",
    file_id: file_id
  }

  driver.text(request.to_json)
end

def send_file_contents(driver, file_path, file_id)
  file_contents = File.read(file_path)

  update_request = {
    action: "update_file",
    file_id: file_id,
    contents: file_contents
  }

  driver.text(update_request.to_json)
end

connect_to_websocket(uri, auth_token, file_paths)
