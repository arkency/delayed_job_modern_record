# frozen_string_literal: true

require "active_record"
require "delayed_job"
require "delayed/backend/modern_record"

Delayed::Worker.backend = Delayed::Backend::ModernRecord::Job
