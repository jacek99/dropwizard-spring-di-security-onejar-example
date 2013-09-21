require "json_spec/cucumber"
require "rspec/expectations"
require 'pathname'
require "yaml"
require "net/http"

AfterConfiguration do |config|
  # read config file
  $config = load_environment("env.yml")
  wait_for_apps_to_start()
end

Before do
  clear_cache()
  @http_headers = {}
end


# Loads the config file for an app and stores it in $config base on app context URL
def load_environment(filename)
  config_file = Pathname.new(__FILE__).dirname.parent + filename
  config = YAML.load_file(config_file)
  puts "Loaded environment file #{config_file}"
  return config
end

# clears out the cache for an app
def clear_cache()

  $config["http"].each do |doc|

    port = doc[1]["adminPort"]
    host = doc[1]["host"]

    http = Net::HTTP.new(host, port)
    request = Net::HTTP::Post.new("/tasks/clearData")
    request.basic_auth("ops","password")
    response = http.request(request)
    response.code.should == "200"
  end

end

def wait_for_apps_to_start
  # ping the health checks to wait until it returns 200
  $config["http"].each do |doc|

    app_name = doc[0]
    http = Net::HTTP.new(doc[1]["host"], doc[1]["adminPort"])
    request = Net::HTTP::Get.new("/healthcheck")
    request.basic_auth("ops","password")

    started = false

    # try for X sec max
    for i in 1..120 do

      begin
        response = http.request(request)
        if response.code == "200"
          started = true
          break
        end
      rescue
        # do nothing in case of connection error
      end

      $stdout.puts "Waiting for '#{app_name}' to start..."
      sleep(1.0)

    end

    if started
      $stdout.puts "'#{app_name}' started!"
    else
      $stdout.puts "'#{app_name}' failed to start!"
      raise "'#{app_name}' failed to start!"
    end

  end

end

