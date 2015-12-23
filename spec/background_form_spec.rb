require 'rspec'
require 'app/models/background_form'

describe BackgroundForm do
  let(:background_instance) { BackgroundForm.new(attributes) }

  context 'from frequencies' do
    let(:attributes) { {mode: :frequencies, frequencies_attributes: {a: '0.2', c: '0.3', g: '0.3', t: '0.2'} } }
    it { background_instance.to_hash[:background].should == [0.2, 0.3, 0.3, 0.2] }
  end
  
  context 'from gc-content' do
    let(:attributes) { {mode: :gc_content, gc_content: 0.6 } }
    it{ background_instance.to_hash[:background].should == [0.2, 0.3, 0.3, 0.2] }
  end
  
  context 'from wordwise' do
    let(:attributes) { {mode: :wordwise} }
    it{ background_instance.to_hash[:background].should == [1,1,1,1] }
  end
end
