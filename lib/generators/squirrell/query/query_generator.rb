require 'rails/generators'

module Squirrell
  module Generators
    class QueryGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      argument :query_name, type: :string, desc: "Name of the query"
      argument :query_type, type: :string, default: "finder", desc: "finder/raw_sql/arel"

      desc "Creates a query"
      def create_query
        puts "#{query_name} and also #{ }"
      end
    end
  end
end

