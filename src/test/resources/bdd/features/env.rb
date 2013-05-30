require "json_spec/cucumber"
require "rspec/expectations"
require 'pathname'
require "yaml"
require "net/http"

AfterConfiguration do |config|
  # read config file
  $config = {}
  load_app_config_file("myapp.yml")

  wait_for_apps_to_start()
end


Before do
  # truncate Cassandra
  truncate_data("myapp")
  # clear out headers list
  @http_headers = {}
end

# Loads the config file for an app and stores it in $config base on app context URL
def load_app_config_file(filename)
  config_file = find_config_file(filename)
  config = YAML.load_file(config_file)
  app_context = config["http"]["rootPath"].split("/")[1]

  $config[app_context] = config
end

# Walks up the directory tree looking for the specified file
def find_config_file(filename)
  root = Pathname.pwd
  while not root.root?
    root.find do |path|
      if path.file? and path.basename.to_s == filename
        return path.to_s
      end
    end
    root = root.parent
  end
  raise "Configuration file '#{filename}' not found!"
end

# clears out the cache for an app
def truncate_data(app_context)
  http = Net::HTTP.new("127.0.0.1", $config[app_context]["http"]["adminPort"])
  request = Net::HTTP::Post.new("/tasks/clearData")
  request.basic_auth("ops","password")
  response = http.request(request)
  response.code.should == "200"
end

def wait_for_apps_to_start
  # ping the health checks to wait until it returns 200
  $config.each do |doc|
    app_context= doc[0]
    http = Net::HTTP.new("127.0.0.1", $config[app_context]["http"]["adminPort"])
    request = Net::HTTP::Get.new("/healthcheck")
    request.basic_auth("ops","password")

    begin
      response = http.request(request)
      while response.code != "200"
        sleep(1.0)
        response = http.request(request)
      end
    rescue
      # call itself again in case of connection error
      sleep(1.0)
      wait_for_apps_to_start()
    end
  end
end