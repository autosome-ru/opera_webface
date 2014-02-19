require 'active_support/concern'

module SubmissionParameters
  class Error < StandardError
    attr_accessor :reason
  end
  extend ActiveSupport::Concern
  def task_params
    key_vals = self.class.submission_params_list.map do |param_name, options, block|
      begin
        next nil  if options[:if] && !options[:if].to_proc.call(self)
        if block
          if respond_to?(param_name)
            [param_name.to_sym, block.call(self, send(param_name))]
          else
            [param_name.to_sym, block.call(self, nil)]
          end
        else
          [param_name.to_sym, send(param_name)]
        end
      rescue => e
        exception = SubmissionParameters::Error.new "Submission of task failed due to exception `#{e.to_s}` in evaluating value of #{param_name}"
        errors.add(:base, exception.message)
        exception.reason = e
        raise exception
      end
    end.compact
    Hash[ key_vals ]
  end
  module ClassMethods
     # params to be sent to the task server
    def submission_params_list
      @submission_params_list ||= []
    end
    def add_task_submission_param(param_name, options = {}, &block)
      submission_params_list << [param_name, options, block]
    end
  end
end
