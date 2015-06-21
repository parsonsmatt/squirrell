require 'rails/generators'

module Sqrl
  module Generators
    class QueryGenerator < ::Rails::Generators::NamedBase
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      class_option :type, type: :string, default: "finder", desc: "finder/raw_sql/arel"
      argument :requires, type: :array, default: ["id"], desc: "Required parameters"

      desc "Creates a query"
      def create_query
        path = "app/queries/#{file_name}.rb"

        template 'query_template.rb.erb', path
      end

      private

      def require_syms
        requires.map { |s| ":#{s}" } * ", "
      end

      def query_type
        options[:type] || "finder"
      end
    end
  end
end

