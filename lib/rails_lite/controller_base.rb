require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require 'debugger'

$PROJECT_ROOT = File.join(File.dirname(__FILE__), '../../')

class ControllerBase
  attr_reader :params, :req, :res

  # setup the controller
  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  # populate the response with content
  # set the responses content type to the given type
  # later raise an error if the developer tries to double render
  def render_content(content, type)
    handle_already_rendered
    res.body = content
    res.content_type = type
    session.store_session(@res)
  end

  def handle_already_rendered
    raise Exception if already_rendered?
    @already_rendered = true
  end


  # helper method to alias @already_rendered
  def already_rendered?
    @already_rendered
  end

  # set the response status code and header
  def redirect_to(url)
    handle_already_rendered
    res["Location"] = url
    res.status = 302
    session.store_session(@res)
  end

  # use ERB and binding to evaluate templates
  # pass the rendered html to render_content
  def render(template_name)
    handle_already_rendered
    path = File.join("views",self.class.name.underscore, "#{template_name}.html.erb")
    # path = File.expand_path(
      # "./views/#{self.class.name.underscore}/#{template_name}.html.erb",
      # $PROJECT_ROOT
      # )
    erb = ERB.new(File.read(path))
    res.content_type = "text/html"
    res.body = erb.result(binding)
    session.store_session(@res)
  end

  # method exposing a `Session` object
  def session
    @session ||= Session.new(@req)
  end

  # use this with the router to call action_name (:index, :show, :create...)
  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end
end
