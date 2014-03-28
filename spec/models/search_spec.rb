require 'spec_helper'

describe Search do

  context '#load_search_parameters' do 
    it 'should return an hash' do
      allow(Search).to receive(:get_from_API).and_return({'value' => 'whatever'})
      expect(Search.load_search_parameters()).to be_a(Hash)
    end
  end

  context '#get_from_API' do 
    it ('should return answer if httparty return 200') do
      allow(HTTParty).to receive(:get).and_return(double({code: 200}))
      allow(Search).to receive(:answer_json).and_return({'whatever'=>'whatever'})
      expect(Search).to_not eq('')
      Search.get_from_API('parameter')
    end

    it "should call HTTParty.get" do 
      allow(Search).to receive(:yummly_parameter_url).and_return('whatever')
      allow(Search).to receive(:answer_json).and_return({'whatever'=>'whatever'})
      expect(HTTParty).to receive(:get).with("whatever").and_return(double({code: 200}))
      Search.get_from_API('parameter')
    end

    it "should call yummly_parameter_url with parameter" do
      allow(HTTParty).to receive(:get).and_return(double({code: 200}))
      allow(Search).to receive(:answer_json).and_return({'whatever'=>'whatever'})
      expect(Search).to receive(:yummly_parameter_url).with('parameter').and_return('whatever')
      Search.get_from_API('parameter')
    end
  end

  context '#answer_json' do

    it "should return [{whatever=>whatever}] if pass 'set_metadata('course', [{whatever=>whatever}]);' " do
      expect(Search.answer_json("set_metadata('course', [{whatever=>whatever}]);")).to eq('[{whatever=>whatever}]')
    end      

  end

  context '#yummly_parameter_url' do
    it 'call URI.escape with any arguments' do 
      expect(URI).to receive(:escape)
      Search.yummly_parameter_url('id')
    end
    context 'the result' do 
      it 'should match api.yummly.com ' do 
        expect(Search.yummly_parameter_url('id')).to match(/api.yummly.com/)
      end
      it 'should match parameter' do 
        expect(Search.yummly_parameter_url('Blablabla')).to match(/Blablabla/)
      end
    end
  end


end