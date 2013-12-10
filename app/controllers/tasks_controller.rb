class TasksController < ApplicationController
  respond_to :json, only: [:status, :create]
  respond_to :js, only: [:create]
  def new
    @task = model_class.new( default_params.merge(permitted_params[:task] || {}) )
  end

  def create
    ticket = SMBSMCore.get_ticket
    @task = model_class.new(permitted_params[:task] || {})
    if @task.valid?
      SMBSMCore.perform_opera(ticket, @task.task_type, @task.task_params)
    end
    respond_with do |format|
      format.js { 
        render :js => "window.location = '#{url_for(action: 'show', id: ticket)}'"
      }
    end
  end

  def show
    @status = SMBSMCore.get_status(params[:id])
  end

  def status
    @status = SMBSMCore.get_status(params[:id])
    respond_with do |format|
      format.json{ render(json: {finished: @task.finished?, message: @task.message} ) }
    end
  end

protected

  def permitted_params
    params.permit(:task => [])
  end

  def default_params
    {}
  end

  # Task.new or Macroape.new for MacroapesController
  def model_class
    Object.const_get(controller_name.classify)
  end
end
