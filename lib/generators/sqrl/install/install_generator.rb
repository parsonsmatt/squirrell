require 'rails/generators'

module Sqrl
  module Generators
    class InstallGenerator < ::Rails::Generators::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc "Creates Squirrell initializer"
      def copy_initializer
        template "squirrell_initializer.rb", "config/initializers/squirrell.rb"
      end

      desc "Creates Example Query"
      def example_query
        template "example_query.rb", 'app/queries/example_query.rb'
      end
    end
  end
end
