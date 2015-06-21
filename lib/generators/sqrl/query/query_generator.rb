require 'rails/generators'

module Sqrl
  module Generators
    class QueryGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      class_option :type, type: :string, default: "finder", desc: "finder/raw_sql/arel"
      argument :requires, type: :array, default: ["id"], desc: "Required parameters"

      desc "Creates a query"
      def create_query
        puts "Name: #{name} #{class_name} #{file_name}"
        puts "Type: #{options[:type]}"
        puts "Requires: #{requires}"
      end
    end
  end
end

