# DelayedJob ModernRecord Backend

## Installation

Add the gem to your Gemfile:

    gem 'delayed_job_modern_record'

Run `bundle install`.

If you're using Rails, run the generator to create the migration for the
delayed_job table.

    rails g delayed_job:modern_record
    rake db:migrate
