require "erb"
require "codebreaker"

class Racker
  @@secret_code = nil
  @@step = 0
  @@results = {}
  def self.call(env)
    new(env).response.finish
  end
   
  def initialize(env)
    unless @@secret_code
      @@computer = Codebreaker::Computer.new
      @@computer.generate_codes
      @@secret_code = @@computer.instance_variable_get(:@secret_code)
      @@result = nil
      @@hint = nil
      @@user_win = false
      @@error_code = nil
      @@results = {}
      @@compare = Codebreaker::Compare.new(@@secret_code)
    end
    @request = Rack::Request.new(env)
  end
   
  def response
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/create_username"
      Rack::Response.new do |response|
        @@username = @request.params["username"]
        @@step = 1
        response.redirect("/")
      end
    when "/create_attempts"
      Rack::Response.new do |response|
        @@attempts = @request.params["attempts"].to_i
        @@turns = @@attempts
        @@step = 2
        response.redirect("/")
      end
    when "/new_trying"
      Rack::Response.new do |response|
        if @request.params["new_code"].match(/^[1-6]{4}$/)
          result_array = @@compare.compare_codes(@request.params["new_code"].split('').map{|item| item.to_i})
          @@results[@request.params["new_code"]] = result_array.join
          if result_array.join == '++++'
            @@user_win = true
            @@step = 3
            write_to_file 'result_file', "\n\nPlayer: #{@@username}\nUsed #{@@turns - @@attempts} turns.\nYour result code is: [#{result_array.join}]"
          end
          @@result = result_array.join
          @@attempts -= 1
          if @@attempts == 0
            @@step = 3
            write_to_file 'result_file', "\n\nPlayer: #{@@username}\nUsed #{@@turns - @@attempts} turns.\nYour result code is: [#{result_array.join}]"
          end
        else
          @@error_code = "Error! You must dial four digits ranging from 1 to 6."
        end
        response.redirect("/")
      end
    when "/hint"
      Rack::Response.new do |response|
        @@hint = @@computer.hint
        response.redirect("/")
      end
    when "/play_again"
      Rack::Response.new do |response|
        if @request.params["play_again"] == 'yes'
          @@secret_code = nil
          @@step = 1
        else
          @@results = {}
          @@step = 4
        end
        response.redirect("/")
      end
    when "/new_game"
      Rack::Response.new do |response|
        @@secret_code = nil
        @@username = nil
        @@step = 0
        response.redirect("/")
      end
    else Rack::Response.new("Not Found", 404)
    end
  end
   
  def render(template)
    path = File.expand_path("../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  def result
    @@result
  end

  def hint_for_user
    @@hint
  end

  def step
    @@step
  end

  def user_win
    @@user_win
  end

  def username
    @@username
  end

  def error_code
    @@error_code
  end

  def results
    @@results
  end

  def write_to_file(file_name, text)
    File.open("#{file_name}.txt", 'a'){|file| file.write text}
  end
end