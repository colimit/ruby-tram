require 'erb'
require 'active_support/inflector'
require_relative 'params'
require_relative 'session'
require 'debugger'

$PROJECT_ROOT = File.join(File.dirname(__FILE__), '../../')

class ControllerBase
  attr_reader :params, :req, :res

  def initialize(req, res, route_params = {})
    @req, @res = req, res
    @params = Params.new(req, route_params)
  end

  # populates the response with content
  # sets the responses content type to the given type
  # raises an error if the developer tries to double render
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

  def already_rendered?
    @already_rendered
  end

  # sets the response status code and header
  def redirect_to(url)
    handle_already_rendered
    res["Location"] = url
    res.status = 302
    session.store_session(@res)
  end

  # uses ERB and binding to evaluate templates
  def render(template_name)
    handle_already_rendered
    path = File.join("app/views", self.class.name.underscore, "#{template_name}.html.erb")
    erb = ERB.new(File.read(path))
    res.content_type = "text/html"
    res.body = erb.result(binding)
    session.store_session(@res)
  end

  def fail
    render_content(params.to_s, "text/json")
  end

  def session
    @session ||= Session.new(@req)
  end

  # does an action like :index or :show
  def invoke_action(name)
    self.send(name)
    render(name) unless already_rendered?
  end
end
