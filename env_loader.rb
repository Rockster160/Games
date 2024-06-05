# gem install dotenv

# env_loader.rb
require "dotenv"

def load_env
  file_name = File.basename($PROGRAM_NAME, ".rb")
  env_file = "#{file_name}.env"
  Dotenv.load(env_file) if File.exist?(env_file)
end

load_env

=begin
```
require_relative "env_loader"

# Your existing code goes here
puts ENV["YOUR_ENV_VAR"]
```
=end
