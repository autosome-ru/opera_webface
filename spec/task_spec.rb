require 'rspec'
require 'app/models/task'

# params --> (add_permitted_task_param) --> raw value --> (submission_task_param) -> typecasted value
#                                                     --> (send) --> typecasted value
#                                                     --> before_type_cast --> raw value

describe ::Task do
  describe '#add_permitted_task_param' do
    let(:task) { klass.new }
    context 'with any parameter' do
      let :klass do
        Class.new(::Task) do
          add_task_permitted_param :param_to_permit
        end
      end
      it 'adds parameter to permitted_params_list of the class' do
        expect(klass.permitted_params_list).to include(:param_to_permit)
      end
    end

    context 'without typecast block' do
      let(:value_to_store) { 'input value' }
      let :klass do
        Class.new(::Task) do
          add_task_permitted_param :param_to_permit
        end
      end
      it 'allows reading stored parameter' do
        task.param_to_permit = value_to_store
        expect(task.param_to_permit).to eq(value_to_store)
      end
      it 'allows reading stored parameter with {attribute}_before_type_cast' do
        task.param_to_permit = value_to_store
        expect(task.param_to_permit_before_type_cast).to eq(value_to_store)
      end
    end

    context 'with typecast block' do
      let(:value_to_store) { 'input value' }
      let(:typecasted_value) { 'INPUT VALUE' }
      let :klass do
        Class.new(::Task) do
          add_task_permitted_param :param_to_permit, &:upcase
        end
      end
      it 'allows reading stored parameter typecasted with a method specified by parameter name' do
        task.param_to_permit = value_to_store
        expect(task.param_to_permit).to eq(typecasted_value)
      end
      it 'allows reading stored parameter non-casted with {attribute}_before_type_cast' do
        task.param_to_permit = value_to_store
        expect(task.param_to_permit_before_type_cast).to eq(value_to_store)
      end
    end
  end


  describe '#add_submission_task_param' do
    let(:task) { klass.new }
    context 'with some parameter' do
      let :klass do
        Class.new(::Task) do
          define_method(:param_to_submit) { 'value to submit' }
          add_task_submission_param :param_to_submit
        end
      end
      it 'adds parameter to task_params' do
        expect(task.task_params).to have_key(:param_to_submit)
      end
      it 'task_params parameter value is equal to result of call of a method specified by parameter name' do
        expect(task.task_params[:param_to_submit]).to eq(task.param_to_submit)
      end
    end

    context 'with block' do
      context 'when parameter exists' do
        let :klass do
          Class.new(::Task) do
            define_method(:param_to_submit) { 'value of attribute' }
          end
        end

        it 'task_params parameter value is equal to result of calling a block' do
          klass.class_eval { add_task_submission_param(:param_to_submit){|obj, val| 'value of block'}  }
          expect(task.task_params[:param_to_submit]).to eq('value of block')
        end

        it 'task_params parameter block\'s first parameter is object' do
          klass.class_eval { add_task_submission_param(:param_to_submit){|obj, val| obj }  }
          expect(task.task_params[:param_to_submit]).to eq(task)
        end

        it 'task_params parameter block\'s second parameter is parameter value' do
          klass.class_eval { add_task_submission_param(:param_to_submit){|obj, val| val }  }
          expect(task.task_params[:param_to_submit]).to eq('value of attribute')
        end
      end

      context 'when parameter is virtual' do
        let :klass do
          Class.new(::Task) do
          end
        end

        it 'task_params parameter value is equal to result of calling a block' do
          klass.class_eval { add_task_submission_param(:param_to_submit){|obj, val| 'value of block' }  }
          expect(task.task_params[:param_to_submit]).to eq('value of block')
        end

        it 'task_params parameter block\'s first parameter is object' do
          klass.class_eval { add_task_submission_param(:param_to_submit){|obj, val| obj }  }
          expect(task.task_params[:param_to_submit]).to eq(task)
        end

        it 'task_params parameter block\'s second parameter is nil' do
          klass.class_eval { add_task_submission_param(:param_to_submit){|obj, val| val }  }
          expect(task.task_params[:param_to_submit]).to eq(nil)
        end
      end
    end

  end
end
