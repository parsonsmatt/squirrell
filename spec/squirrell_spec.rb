require 'spec_helper'

describe Squirrell do
  it 'has a version number' do
    expect(Squirrell::VERSION).not_to be nil
  end

  it 'does something useful' do
    expect(false).to eq(true)
  end

  it 'can be configured' do
    Squirrell.configure do |config|
      config.executor = "lol"
    end

    expect(Squirrell.executor).to eq("lol")
  end
end
