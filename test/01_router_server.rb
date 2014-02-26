require 'active_support/core_ext'
require 'json'
require 'webrick'
require 'rails_lite'

# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPRequest.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/HTTPResponse.html
# http://www.ruby-doc.org/stdlib-2.0/libdoc/webrick/rdoc/WEBrick/Cookie.html
server = WEBrick::HTTPServer.new :Port => 8080
trap('INT') { server.shutdown }

class StatusesController < ControllerBase
  def index
    statuses = ["s1", "s2", "s3"]

    render_content(statuses.to_json, "text/json")
  end

  def new
  end

  def create
    @status = params
    render "show"
  end

  def show

  end
end

class UsersController < ControllerBase
  def index
    users = ["u1", "u2", "u3"]

    render_content(users.to_json, "text/json")
  end
end

server.mount_proc '/' do |req, res|
  router = Router.new
  router.draw do
    get Regexp.new("^/statuses$"), StatusesController, :index
    post Regexp.new("^/statuses$"), StatusesController, :create
    get Regexp.new("^/statuses/new$"), StatusesController, :new
    get Regexp.new("^/users$"), UsersController, :index
    get Regexp.new("^/statuses/(?<id>\\d+)$"), StatusesController, :show
    # uncomment this when you get to route params

  end

  route = router.run(req, res)
end

server.start
