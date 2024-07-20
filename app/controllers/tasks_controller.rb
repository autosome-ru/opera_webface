require 'yaml'
require 'ostruct'

# to work from box, params should be saved into task_params.yaml (in overture), results - into task_results.yaml (in opera)
class TasksController < ApplicationController
  # rescue_from SubmissionParameters::Error do |e|
  #   render action: 'new'
  # end

  before_action :get_ticket, only: [:perform, :show]

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
    SMBSMCore.perform_opera(@ticket, model_class.task_type)
    redirect_to action: 'show', id: @ticket
  end

  def show
    @status = SMBSMCore.get_status(@ticket)
    render action: 'ticket_not_found' and return  unless @status

    if self.class != choose_opera_controller(@status.opera_name)
      redirect_to controller: choose_opera_controller(@status.opera_name).controller_path, action: 'show', id: @ticket
      return
    end

    if @status.finished?
      render template: 'tasks/show', locals: {ticket: @ticket, status: @status, task_params: task_params(@ticket), task_results: task_results(@ticket)}
    else
      SMBSMCore.perform_opera(@ticket, model_class.task_type)  unless @status.start_time
      render template: 'tasks/in_process', locals: {ticket: @ticket, status: @status}
    end
  end

protected

  def choose_opera_controller(opera_name)
    task_controllers = [Macroape::ScansController, Macroape::ComparesController, Perfectosape::ScansController, Chipmunk::Discovery::DiController, Chipmunk::Discovery::MonoController]
    task_controllers.detect{|cntrl| cntrl.model_class.task_type == opera_name}
  end

  def permitted_params
    # params.permit(:task => model_class.permitted_params_list)
    params.permit!
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
    OpenStruct.new(YAML.load(SMBSMCore.get_content(ticket, 'task_params.yaml').force_encoding('UTF-8')))  if SMBSMCore.check_content(ticket, 'task_params.yaml')
  end

  def task_results(ticket)
    OpenStruct.new(YAML.load(SMBSMCore.get_content(ticket, 'task_results.yaml').force_encoding('UTF-8')))  if SMBSMCore.check_content(ticket, 'task_results.yaml')
  end

  def reload_page_time
    5
  end

  def get_ticket
    @ticket = params[:id].try(&:strip).tap{|x| puts "ticket #{x.inspect}"}
  end

  # path to task logo
  def task_logo
    nil
  end

  helper_method :reload_page_time, :task_logo
end
