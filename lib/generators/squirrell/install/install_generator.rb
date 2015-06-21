require 'rails/generators'

module Squirrell
  module Generators
    class InstallGenerator < Rails::Generator::Base
      source_root File.expand_path(File.join(File.dirname(__FILE__), 'templates'))

      desc "Creates Squirrell initializer"
      def copy_initializer
        template "squirrell_initializer.rb", "config/initializers/squirrell.rb"
        puts "Squirrell initializer installed."
      end

      desc "Creates Example Query"
      def example_query
        template "example_query.rb", 'app/queries/example_query.rb'
        puts "Example query installed."
      end
    end
  end
end
