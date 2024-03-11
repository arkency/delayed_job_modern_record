# frozen_string_literal: true

require "generators/delayed_job/delayed_job_generator"
require "rails/generators/migration"
require "rails/generators/active_record"

module DelayedJob
  class ModernRecordGenerator < ::DelayedJobGenerator
    include Rails::Generators::Migration

    source_paths << File.join(File.dirname(__FILE__), "templates")

    def create_migration_file
      migration_template "migration.erb", "db/migrate/create_delayed_jobs.rb", migration_version: migration_version
    end

    def self.next_migration_number(dirname) = ActiveRecord::Generators::Base.next_migration_number dirname

    private

    def migration_version = "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
  end
end
