require 'active_support/core_ext'
require 'json'
require 'webrick'
require_relative 'lib/ruby_tram'

server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }
# 
# class StatusesController < ControllerBase
#   def index
#     @statuses = Status.all
#   end
# 
#   def new
#   end
# 
#   def create
#    @status = Status.new(params["status"])
#    @status.save
#    redirect_to "http://localhost:8080/statuses/#{@status.id}"
#   end
# 
#   def show
#     @status = Status.find(params["id"])
#   end
# end

# 
# class UsersController < ControllerBase
#   def index
#     users = ["u1", "u2", "u3"]
# 
#     render_content(users.to_json, "text/json")
#   end
# end

server.mount_proc '/' do |req, res|
  router = Router.new
  router.draw do
    get Regexp.new("^/statuses$"), StatusesController, :index
    get Regexp.new("^//?$"), StatusesController, :index
    post Regexp.new("^/statuses$"), StatusesController, :create
    get Regexp.new("^/statuses/new$"), StatusesController, :new    # 
    # get Regexp.new("^/users$"), UsersController, :index
    get Regexp.new("^/statuses/(?<id>\\d+)$"), StatusesController, :show

  end

  route = router.run(req, res)
end

server.start
