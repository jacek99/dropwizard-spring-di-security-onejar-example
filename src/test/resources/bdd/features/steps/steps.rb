require "net/http"
require "json"

SKIP = "_"

###### GIVEN #############

Given(/^"(.+):(.+)" sends POST "([^"]+)":/) do |user, password, url, table|

  table.hashes.each do |hash|
    http, request = get_http_request("POST",url,user,password)
    # support SKIP
    hash.each do |doc|
      if doc[1] == SKIP
        hash.delete(doc[0])
      end
    end
    request.set_form_data(hash)
    execute_http_request(http, request)
    begin
      @response.code.should == "201"
    rescue RSpec::Expectations::ExpectationNotMetError => error
      # better error msg with actual JSON vs just the diff from json_spec
      full_error = "#{error}\nHTTP response: #{@response.body}\n#{@response.header}"
      raise RSpec::Expectations::ExpectationNotMetError.new(full_error)
    end
  end
end


###### WHEN ##############

When /^"(.+):(.+)" sends (POST|PUT|PATCH) "(.+)" with "([^"]+)"$/ do |user,password,method,url,parameters|

  http, request = get_http_request(method,url, user, password)
  apply_form_parameters(request,parameters)
  execute_http_request(http,request)
end


When /^"(.+):(.+)" sends (OPTIONS|GET|DELETE|POST|PUT|PATCH) "([^"]+)"$/ do |user,password,method,url|
  http, request = get_http_request(method,url, user, password)
  execute_http_request(http,request)
end

When /^"(.+):(.+)" sends (POST|PUT|PATCH) "([^"]+)" with (CSV|text) file "([^"]+)"$/ do |user,password,method,url,content_type,file_name|
  http, request = get_http_request(method,url, user, password)
  case content_type
    when "CSV"
      request["content-type"] = "text/csv"
    when "text"
      request["content-type"] = "text/plain"
  end

  request.body = File.read(file_name)
  execute_http_request(http,request)
end

When /^"(.+):(.+)" sends (POST|PUT|PATCH) "([^"]+)" with (text|json|JSON|csv)$/ do |user,password,method,url,content_type,text|
  http, request = get_http_request(method,url, user, password)
  case content_type
    when "json","JSON"
      request["content-type"] = "application/json"
    when "text"
      request["content-type"] = "text/plain"
    when "csv"
      request["content-type"] = "text/csv"
  end
  request.body = text
  execute_http_request(http,request)
end


When /^I set HTTP header "([^"]*)" to "([^"]*)"$/ do |header_name, header_value|
  @http_headers[header_name] = header_value
end

When(/^"(.+):(.+)" sends (GET|POST) "([^"]+)" on admin port$/) do |user,password,method,url|
  # send it to all apps registered in the $config
  $config["http"].each do |doc|
    app_context = doc[0]
    http, request = get_http_request(method,url,user,password,true,app_context)
    execute_http_request(http, request)
  end
end

# executed against all admin ports in an app
When(/^"(.+):(.+)" sends POST "([^"]+)" with "([^"]+)" on admin port$/) do |user,password,url,parameters|
  $config["http"].each do |doc|
    app_context = doc[0]
    http, request = get_http_request("POST", url, user, password, true, app_context)
    apply_form_parameters(request,parameters)
    execute_http_request(http, request)
  end
end

# application-specific, executed on a single app admin port only
When(/^"(.+):(.+)" sends (GET|POST) "([^"]+)" on "(.+)" admin port$/) do |user,password,method,url,app_context|
  # send it to all apps registered in the $config 
  http, request = get_http_request(method,url,user,password,true,app_context)
  execute_http_request(http, request)
end

# application-specific, executed on a single app admin port only
When /^"(.+):(.+)" sends (POST|PUT|PATCH) "([^"]+)" with (text|JSON|form) on "(.+)" admin port$/ do |user,password,method,url,content_type,app_context,text|
  http, request = get_http_request(method,url, user, password,true,app_context)
  case content_type
    when "JSON"
      request["content-type"] = "application/json"
      request.body = text
    when "text"
      request["content-type"] = "text/plain"
      request.body = text
    when "form"
      request["content-type"] = "application/x-www-form-urlencoded"
      apply_form_parameters(request,text)
  end

  execute_http_request(http,request)
end


When(/^I sleep for (\d+)\s* seconds$/) do |seconds|
  sleep(seconds.to_i)
end

###### THEN #############

Then /^I expect HTTP code (\d+)\s*$/ do |code|
  begin
    @response.code.should == code
  rescue RSpec::Expectations::ExpectationNotMetError => error
    # better error msg with actual JSON vs just the diff from json_spec
    full_error = "#{error}\nHTTP response: #{@response.body}\n#{@response.header}"
    raise RSpec::Expectations::ExpectationNotMetError.new(full_error)
  end
end

Then /^I expect HTTP header "([^"]*)" equals "([^"]*)"$/ do |header_name, header_value|
  header_value = replace_memorized_variables(header_value)
  if header_name != SKIP and header_value != SKIP then
    @response[header_name].should == header_value
  end
end

Then(/^I expect JSON equivalent to$/) do |string|
  string = replace_memorized_variables(string,false)
  expected = JSON.parse(string)
  expected_field_names = get_unique_field_names(expected)

  actual = JSON.parse(last_json())
  actual_compare = remove_field_names(JSON.parse(last_json()), expected_field_names)

  # use json_spec comparison with diff built in
  begin
    JSON.dump(actual_compare).should be_json_eql(string)
  rescue RSpec::Expectations::ExpectationNotMetError => json_error
    # better error msg with actual JSON vs just the diff from json_spec
    full_error = "Actual full JSON:\n" + JSON.pretty_generate(actual) +
        "\n------------------------------\nActual JSON with expected fields only:\n" + JSON.pretty_generate(actual_compare) +
        "\n------------------------------\n" + json_error.to_s
    raise RSpec::Expectations::ExpectationNotMetError.new(full_error)
  end

end

Then(/^I expect JSON equal to$/) do |string|
  begin
    last_json.should be_json_eql(string)
  rescue RSpec::Expectations::ExpectationNotMetError => json_error
    # better error msg with actual JSON vs just the diff from json_spec
    full_error = "Actual JSON:\n" + JSON.pretty_generate(last_json) + "\n" + json_error.to_s
    raise RSpec::Expectations::ExpectationNotMetError.new(full_error)
  end
end


Then(/^I expect HTTP content contains "(.*)"$/) do |string|
  string = replace_memorized_variables(string)
  @response.body.should include(string)
end

Then(/^I expect HTTP content does not contain "(.*)"$/) do |string|
  if @response.body[string] != nil
    full_error = "Text '#{string}' found in response body:\n#{@response.body}"
    raise RSpec::Expectations::ExpectationNotMetError.new(full_error)
  end
end


Then(/^I expect HTTP content contains$/) do |string|
  string = replace_memorized_variables(string)
  begin
    @response.body.should include(string)
  rescue RSpec::Expectations::ExpectationNotMetError => json_error
    # better error msg with actual JSON vs just the diff from json_spec
    full_error = "Actual text:\n" + @response.body + "\n" + json_error.to_s
    raise RSpec::Expectations::ExpectationNotMetError.new(full_error)
  end
end

Then(/^I expect HTTP content matches/) do |string|
  begin
    /#{string}/.should match(@response.body)
  rescue RSpec::Expectations::ExpectationNotMetError => json_error
    # better error msg with actual JSON vs just the diff from json_spec
    full_error = "Actual text:\n" + @response.body + "\n" + json_error.to_s
    raise RSpec::Expectations::ExpectationNotMetError.new(full_error)
  end
end


# UTILITY METHODS

# loads the host and port from the app-specific context in the URL
def get_http(url, admin_port = false, app_context = nil)

  app_context = url.split("/")[1] if app_context == nil
  host = $config["http"][app_context]["host"]
  port = $config["http"][app_context]["port"]
  if admin_port
    port = $config["http"][app_context]["adminPort"]
  end

  http = Net::HTTP.new(host, port)

  # for large perf files
  http.continue_timeout = 30 * 60
  http.read_timeout = 30 * 60

  return http
end

# generates the appropriate HTTP request based on method
def get_http_request(method,url,user,password, admin_port = false, app_context = nil)
  http = get_http(url, admin_port, app_context)

  url = replace_memorized_variables(url)

  request = nil
  case method
    when "GET"
      request = Net::HTTP::Get.new(url)
    when "OPTIONS"
      request = Net::HTTP::Options.new(url)
    when "POST"
      request = Net::HTTP::Post.new(url)
    when "PUT"
      request = Net::HTTP::Put.new(url)
    when "PATCH"
      request = Net::HTTP::Patch.new(url)
    when "DELETE"
      request = Net::HTTP::Delete.new(url)
  end

  request.basic_auth(user,password)
  # default content type for all request, can be overriden
  request["content-type"] = "application/x-www-form-urlencoded"
  request["accept"] = "*/*"

  return http, request
end

# standard logic for all HTTP Request steps
def execute_http_request(http, request)
  @http_headers.each do |header|
    request[header[0]] = header[1]
  end

  @response = http.request(request)
  @http_headers = {}
end

def apply_form_parameters(request,parameters)
  # convert parameters to Ruby hash
  form = {}
  splitparams = parameters.split "&"
  splitparams.each do |part|
    keyValue = part.split "="
    key = keyValue[0].strip()
    value = keyValue[1]
    # support multiple parameters -> turn it into an array
    if !form.has_key?(key)
      form[key] = [value]
    else
      form[key] << value
    end
  end
  request.set_form_data(form)
end

# required by json_spec
def last_json
  @response.body
end

# find all the unique field names in a JSON document
def get_unique_field_names(json_doc, fields_set = SortedSet.new([]))

  json_doc.each{|k,v| fields_set.add(k)} if json_doc.is_a?(Hash)
  json_doc.each{|k,v| get_unique_field_names(json_doc[k],fields_set)} if json_doc.is_a?(Hash)
  json_doc.each {|doc| get_unique_field_names(doc, fields_set)} if json_doc.is_a?(Array)
  return fields_set
end

# removes the field names from the JSON doc that are not in the allowed list
def remove_field_names(json_doc, fields_set)

  json_doc.reject!{|k,v| not fields_set.include?(k)} if json_doc.is_a?(Hash)
  json_doc.each{|k,v| remove_field_names(json_doc[k],fields_set)} if json_doc.is_a?(Hash)
  json_doc.each {|doc| remove_field_names(doc, fields_set)} if json_doc.is_a?(Array)

  return json_doc
end

# takes a string and replaces all references to JsonSpec memory variables with actual values
def replace_memorized_variables(string_value, remove_quotes = true)
  # if JsonSpec variables are present, replace any potential references to them in the URL
  JsonSpec.memory.each do |doc|
    var_name = doc[0]
    # doc[1] is stored with quotes "....." so we have to remove them if told to (usually yes)
    var_value = doc[1]
    var_value = var_value.gsub('"',"") if remove_quotes
    string_value = string_value.gsub("%{#{var_name}}",var_value)
  end

  return string_value
end