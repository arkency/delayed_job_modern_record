# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name = "delayed_job_modern_record"
  spec.version = "0.0.1"
  spec.summary = "Modern ActiveRecord backend for DelayedJob"
  spec.description = "Modern ActiveRecord backend for Delayed::Job, originally authored by Tobias Lütke"

  spec.licenses = "MIT"

  spec.authors = ["Arkency"]
  spec.email = ["dev@arkency.com"]
  spec.homepage = "http://github.com/arkency/delayed_job_modern_record"

  spec.files = %w[CONTRIBUTING.md LICENSE.md README.md delayed_job_modern_record.gemspec] + Dir["lib/**/*.rb"]
  spec.require_paths = ["lib"]

  spec.metadata = { "rubygems_mfa_required" => "true" }

  spec.required_ruby_version = ">= 3.3.0"

  spec.add_dependency "activerecord", [">= 7.1", "< 8.0"]
  spec.add_dependency "delayed_job", [">= 4.1.11", "< 5"]
end
