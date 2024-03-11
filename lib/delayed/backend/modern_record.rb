# frozen_string_literal: true

require "active_record/version"
module Delayed
  module Backend
    module ModernRecord
      class Job < ::ActiveRecord::Base
        include Delayed::Backend::Base

        scope :by_priority, lambda { order("priority, run_at") }
        scope :min_priority, lambda { where("priority >= ?", Worker.min_priority) if Worker.min_priority }
        scope :max_priority, lambda { where("priority <= ?", Worker.max_priority) if Worker.max_priority }
        scope :for_queues, lambda { |queues = Worker.queues| where(queue: queues) if Array(queues).any? }
        scope :ready_to_run,
              lambda { |worker_name, max_run_time|
                where(
                  "((run_at <= ? AND (locked_at IS NULL OR locked_at < ?)) OR locked_by = ?) AND failed_at IS NULL",
                  db_time_now,
                  db_time_now - max_run_time,
                  worker_name
                )
              }

        before_save :set_default_run_at

        def self.set_delayed_job_table_name
          self.table_name = "#{::ActiveRecord::Base.table_name_prefix}delayed_jobs"
        end

        set_delayed_job_table_name

        def self.before_fork = ::ActiveRecord::Base.connection_handler.clear_all_connections!(:all)
        def self.after_fork = ::ActiveRecord::Base.establish_connection

        def self.clear_locks!(worker_name)
          where(locked_by: worker_name).update_all(locked_by: nil, locked_at: nil)
        end

        def self.reserve(worker, max_run_time = Worker.max_run_time)
          now = db_time_now.change(usec: 0)
          count =
            ready_to_run(worker.name, max_run_time)
              .min_priority
              .max_priority
              .for_queues
              .by_priority
              .limit(1)
              .update_all(locked_at: now, locked_by: worker.name)
          return if count == 0

          where(locked_at: now, locked_by: worker.name, failed_at: nil).first
        end

        # Get the current time (GMT or local depending on DB)
        # Note: This does not ping the DB to get the time, so all your clients
        # must have syncronized clocks.
        def self.db_time_now
          if Time.zone
            Time.zone.now
          elsif ::ActiveRecord.default_timezone == :utc
            Time.now.utc
          else
            Time.now
          end
        end

        def reload(*args)
          reset
          super
        end
      end
    end
  end
end
