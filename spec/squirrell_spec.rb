require 'spec_helper'

describe Squirrell do
  it 'has a version number' do
    expect(Squirrell::VERSION).not_to be nil
  end

  let(:good_executor) { -> (x) { x }  }

  describe '.configure' do
    let(:good) { good_executor }
    let(:bad) { 'asdf' }

    it 'succeeds when executor responds to execute' do
      expect do
        Squirrell.configure do |c|
          c.executor = good
        end
      end.to_not raise_error Squirrell::ExecutorError
    end

    it 'errors when executor does not respond to execute' do
      expect do
        Squirrell.configure do |c|
          c.executor = bad
        end
      end.to raise_error(Squirrell::ExecutorError)

      Squirrell.executor = good_executor
    end
  end

  describe '.find' do
    context 'ex has finder' do
      class FinderExample
        include Squirrell

        required :id

        def finder
          @id
        end
      end

      describe 'required' do
        it 'makes an instance variable' do
          expect(FinderExample.find(id: 5)).to eq(5)
        end

        it 'does not permit non-required values' do
          expect do
            FinderExample.find(id: 5, lol: 2)
          end.to raise_error ArgumentError
        end

        it 'fails if required value blank' do
          expect do
            FinderExample.find(lol: 2)
          end.to raise_error ArgumentError
        end
      end
    end

    context 'ex has arel' do
      class ArelExample
        include Squirrell

        required :lol, :wat

        def arel
          Struct.new(:to_sql).new(@lol)
        end
      end

      it 'knows to call arel if arel exists' do
        expect(ArelExample.find(lol: 5, wat: 6)).to eq(5)
      end

      it 'expects result of arel to respond to to_sql' do
      end
    end

    context 'ex has raw_sql' do
      class SqlExample
        include Squirrell

        required :thing

        def raw_sql
          "SELECT * FROM #{@thing}"
        end
      end

      it 'knows to call raw_sql' do
        expect(SqlExample.find(thing: 123)).to eq('SELECT * FROM 123')
      end
    end
  end
end
