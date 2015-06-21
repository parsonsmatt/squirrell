require 'rails/generators'

module Squirrell
  module Generators
    class QueryGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      argument :query_type, type: :string, default: "finder", desc: "finder/raw_sql/arel"
      argument :requires, type: :array, default: ["id"], desc: "Required parameters"

      desc "Creates a query"
      def create_query
        puts "#{name} and also #{query_type} and maybe #{requires}"
      end
    end
  end
end

