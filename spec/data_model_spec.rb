require 'rspec'
require 'app/models/data_model'

describe DataModel do
  let(:model_instance) { DataModel.new(attributes) }
  let(:background) {Background.new(mode: :wordwise)}

  context 'pwm' do
    let(:pwm_matrix) {"1 3.5 2 4\n2.55 7.34 -14.3 -9\r\n15 0 25 1"}
    let(:attributes) { {data_model: :PWM, background: background, matrix: pwm_matrix } }
    it { model_instance.to_hash[:background].should == background.to_hash }
    it { model_instance.to_hash.should_not have_key(:ppm) }
    it { model_instance.to_hash.should_not have_key(:pcm) }
    it { model_instance.to_hash.should have_key(:pwm) }
    it { model_instance.to_hash[:pwm].should match /\A1.0\s+3.5\s+2.0\s+4.0\n2.55\s+7.34\s+-14.3\s+-9.0\n15.0\s+0.0\s+25.0\s+1.0\z/ }
    it 'allows matrix name' do
      DataModel.new({data_model: :PWM, background: background, matrix: "motif_name\n" + pwm_matrix }).data_model_object.matrix.should == model_instance.data_model_object.matrix
    end
    # Fails in bioinform
    # it 'allows matrix name with spaces' do
    #   DataModel.new({data_model: :PWM, background: background, matrix: "motif name\n" + pwm_matrix }).data_model_object.matrix.should == model_instance.data_model_object.matrix
    # end
  end
  context 'pcm' do
    let(:pcm_matrix) {"1 3 3 2\n2 2 2 3\n7 2 0 0"}
    let(:attributes) { {data_model: :PCM, background: background, matrix: pcm_matrix } }
    it { model_instance.to_hash[:background].should == background.to_hash }
    it { model_instance.to_hash.should have_key(:ppm) }
    it { model_instance.to_hash.should have_key(:pcm) }
    it { model_instance.to_hash.should have_key(:pwm) }
    it { model_instance.to_hash[:pcm].should match /\A1.0\s+3.0\s+3.0\s+2.0\n2.0\s+2.0\s+2.0\s+3.0\n7.0\s+2.0\s+0.0\s+0.0\z/ }
  end
  context 'pcm' do
    let(:pcm_matrix) {"0.01 0.33 0.63 0.03\n0.22 0.22 0.22 0.34\n0.70 0.2 0.1 0"}
    let(:attributes) { {data_model: :PPM, background: background, matrix: pcm_matrix, effective_count: 100 } }
    it { model_instance.to_hash[:background].should == background.to_hash }
    it { model_instance.to_hash.should have_key(:ppm) }
    it { model_instance.to_hash.should have_key(:pcm) }
    it { model_instance.to_hash.should have_key(:pwm) }
    it { model_instance.to_hash[:pcm].should match /\A1.0\s+33.0\s+63.0\s+3.0\n22.0\s+22.0\s+22.0\s+34.0\n70.0\s+20.0\s+10.0\s+0.0\z/ }
    it { model_instance.to_hash[:ppm].should match /\A0.01\s+0.33\s+0.63\s+0.03\n0.22\s+0.22\s+0.22\s+0.34\n0.7\s+0.2\s+0.1\s+0.0\z/ }
  end

  it 'raises on bad matrix' do
    expect { DataModel.new data_model: :PWM, background: background, matrix: 'akhsvfew'}.to raise_error
  end

  context 'from text without name' do
    subject { DataModel.new(data_model: :PWM, background: background, matrix: "1 3.5 2 4\n2.55 7.34 -14.3 -9\r\n15 0 25 1").pwm }
    its(:name) { should be_nil  }
    its(:matrix) { should eq [[1, 3.5, 2, 4],[2.55, 7.34, -14.3, -9],[15, 0, 25, 1]] }
  end
  context 'from text with name' do
    subject { DataModel.new(data_model: :PWM, background: background, matrix: "MatrixName\n1 3.5 2 4\n2.55 7.34 -14.3 -9\r\n15 0 25 1").pwm }
    its(:name) { should eq 'MatrixName' }
    its(:matrix) { should eq [[1, 3.5, 2, 4],[2.55, 7.34, -14.3, -9],[15, 0, 25, 1]] }
  end
  context 'from text with name, name with space' do
    subject { DataModel.new(data_model: :PWM, background: background, matrix: "Matrix Name\n1 3.5 2 4\n2.55 7.34 -14.3 -9\r\n15 0 25 1").pwm }
    its(:name) { should eq 'Matrix Name' }
    its(:matrix) { should eq [[1, 3.5, 2, 4],[2.55, 7.34, -14.3, -9],[15, 0, 25, 1]] }
  end
  
  # context 'from gc-content' do
  #   let(:attributes) { {mode: :gc_content, gc_content: 0.6 } }
  #   it{ model_instance.to_hash[:background].should == [0.2, 0.3, 0.3, 0.2] }
  # end
  
  # context 'from wordwise' do
  #   let(:attributes) { {mode: :wordwise} }
  #   it{ model_instance.to_hash[:background].should == [1,1,1,1] }
  # end
end
