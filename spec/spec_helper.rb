# frozen_string_literal: true

require "logger"
require "rspec"
require_relative "../lib/delayed_job_modern_record"
require "delayed/backend/shared_spec"

Delayed::Worker.logger = Logger.new("/tmp/dj.log")
ENV["RAILS_ENV"] = "test"

ActiveRecord::Base.establish_connection YAML.load_file("spec/database.yml")[ENV.fetch("ADAPTER", "mysql2")]
ActiveRecord::Base.logger = Delayed::Worker.logger
ActiveRecord::Migration.verbose = false

migration_template = File.open("lib/generators/delayed_job/templates/migration.erb")

migration_context =
  Class.new do
    def my_binding = binding

    private

    def migration_version = "[#{ActiveRecord::VERSION::MAJOR}.#{ActiveRecord::VERSION::MINOR}]"
  end

migration_ruby = ERB.new(migration_template.read).result(migration_context.new.my_binding)
eval(migration_ruby)

ActiveRecord::Schema.define do
  drop_table :delayed_jobs if table_exists?(:delayed_jobs)

  CreateDelayedJobs.up

  create_table :stories, primary_key: :story_id, force: true do |table|
    table.string :text
    table.boolean :scoped, default: true
  end
end

class Story < ActiveRecord::Base
  self.primary_key = :story_id

  def tell = text
  def whatever(number) = tell * number

  default_scope { where(scoped: true) }
  handle_asynchronously :whatever
end
