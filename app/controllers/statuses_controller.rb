class StatusesController < ControllerBase
  def index
    @statuses = Status.all
  end

  def new
  end

  def create
   @status = Status.new(params["status"])
   @status.save
   redirect_to "http://localhost:8080/statuses/#{@status.id}"
  end

  def show
    @status = Status.find(params["id"])
  end
end
