require 'spec_helper'

describe Squirrell do
  class Example
    include Squirrell

    required :id

    def finder
      @id
    end
  end

  describe 'required' do
    it 'makes an instance variable' do
      expect(Example.find(id: 5)).to eq(5)
    end
  end
end
