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
      end.to_not raise_error
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

        requires :id

        def finder
          @id
        end
      end

      describe 'requires' do
        it 'makes an instance variable' do
          expect(FinderExample.find(id: 5)).to eq(5)
        end

        it 'does not permit non-requires, non-permitted values' do
          expect do
            FinderExample.find(id: 5, lol: 2)
          end.to raise_error ArgumentError
        end

        it 'fails if requires value blank' do
          expect do
            FinderExample.find(lol: 2)
          end.to raise_error ArgumentError
        end
      end
    end

    context 'with permitted parameters' do
      class PermittedExample
        include Squirrell

        requires :id
        permits :name

        def finder
          @name ? @id + @name : @id
        end
      end

      it 'sets permitted values' do
        expect(PermittedExample.find(id: "5", name: "hey")).to eq("5hey")
      end

      it 'allows missing permitted values' do
        expect(PermittedExample.find(id: 123)).to eq(123)
      end

      it 'errors on unspecified values' do
        expect do
          PermittedExample.find(id: 1, name: 2, face: "wut")
        end.to raise_error ArgumentError
      end
      
    end

    context 'ex has good arel' do
      class ArelExample
        include Squirrell

        requires :lol, :wat

        def arel
          Struct.new(:to_sql).new(@lol)
        end
      end

      it 'knows to call arel if arel exists' do
        expect(ArelExample.find(lol: 5, wat: 6)).to eq(5)
      end

      it 'calls the executor' do
        expect(Squirrell.executor).to receive(:call).and_call_original
        ArelExample.find(lol: 2, wat: 8)
      end
    end

    context 'with bad arel' do
      class BadArelExample
        include Squirrell

        requires :lol, :wat

        def arel
          @lol
        end
      end

      it 'should raise error' do
        expect {
          BadArelExample.find(lol: 'asdf', wat: 'tho')
        }.to raise_error Squirrell::InvalidArelError
      end
    end

    context 'ex has raw_sql' do
      class SqlExample
        include Squirrell

        requires :thing

        def raw_sql
          "SELECT * FROM #{@thing}"
        end
      end

      it 'knows to call raw_sql' do
        expect(SqlExample.find(thing: 123)).to eq('SELECT * FROM 123')
      end

      it 'calls the executor' do
        expect(Squirrell.executor).to receive(:call).and_call_original
        SqlExample.find(thing: "asdf")
      end
    end
  end
end
