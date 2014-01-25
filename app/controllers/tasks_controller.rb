require 'yaml'
require 'ostruct'

# to work from box, params should be saved into task_params.yaml (in overture), results - into task_results.yaml (in opera)
class TasksController < ApplicationController
  rescue_from SubmissionParameters::Error do |e|
    render action: 'new'
  end

  def new
    @task = model_class.new( default_params.merge(permitted_params[:task] || {}) )
  end

  def create
    @task = model_class.new(permitted_params[:task] || {})
    unless @task.valid?
      render action: 'new'
      return
    end
    @ticket = SMBSMCore.get_ticket
    SMBSMCore.perform_overture(@ticket, @task.task_type, @task.task_params)
  end

  def perform
    @ticket = params[:id]
    SMBSMCore.perform_opera(@ticket, model_class.task_type)
    redirect_to action: 'show', id: @ticket
  end

  def show
    @ticket = params[:id]
    @status = SMBSMCore.get_status(params[:id])
    render action: 'ticket_not_found' and return  unless @status

    if model_class.task_type != @status.opera_name
      redirect_to controller: choose_opera_controller(@status.opera_name).controller_path, action: 'show', id: @ticket
      return
    end

    if @status.finished?
      render template: 'tasks/show', locals: {ticket: @ticket, status: @status, task_params: task_params(@ticket), task_results: task_results(@ticket)}
    else
      render template: 'tasks/in_process', locals: {ticket: @ticket, status: @status}
    end
  end

protected

  def choose_opera_controller(opera_name)
    [Macroape::ScansController, Macroape::ComparesController, Perfectosape::ScansController].detect{|cntrl| cntrl.model_class.task_type == opera_name}
  end

  def permitted_params
    params.permit(:task => model_class.permitted_params_list)
  end

  def default_params
    {}
  end

  # Task.new or Macroape.new for MacroapesController
  def self.model_class
    (parent_name ? Object.const_get(parent_name) : Object).const_get(controller_name.classify)
  end

  def model_class
    self.class.model_class
  end

  def task_params(ticket)
    OpenStruct.new(YAML.load(SMBSMCore.get_content(ticket, 'task_params.yaml')))  if SMBSMCore.check_content(ticket, 'task_params.yaml')
  end

  def task_results(ticket)
    OpenStruct.new(YAML.load(SMBSMCore.get_content(ticket, 'task_results.yaml')))  if SMBSMCore.check_content(ticket, 'task_results.yaml')
  end
end
