# frozen_string_literal: true

require_relative "spec_helper"

RSpec.describe Delayed::Backend::ModernRecord::Job do
  it_behaves_like "a delayed_job backend"

  context "db_time_now" do
    after do
      Time.zone = nil
      ActiveRecord.default_timezone = :local
    end

    it "returns time in current time zone if set" do
      Time.zone = "Arizona"
      expect(Delayed::Job.db_time_now.zone).to eq("MST")
    end

    it "returns UTC time if that is the AR default" do
      Time.zone = nil
      ActiveRecord.default_timezone = :utc
      expect(Delayed::Backend::ModernRecord::Job.db_time_now.zone).to eq "UTC"
    end

    it "returns local time if that is the AR default" do
      Time.zone = "Arizona"
      ActiveRecord.default_timezone = :local
      expect(Delayed::Backend::ModernRecord::Job.db_time_now.zone).to eq("MST")
    end
  end

  describe "after_fork" do
    it "calls reconnect on the connection" do
      allow(ActiveRecord::Base).to receive(:establish_connection)
      Delayed::Backend::ModernRecord::Job.after_fork
      expect(ActiveRecord::Base).to have_received(:establish_connection)
    end
  end

  describe "enqueue" do
    it "allows enqueue hook to modify job at DB level" do
      later = described_class.db_time_now + 20.minutes
      job = Delayed::Backend::ModernRecord::Job.enqueue payload_object: EnqueueJobMod.new
      expect(Delayed::Backend::ModernRecord::Job.find(job.id).run_at).to be_within(1).of(later)
    end
  end

  context "ActiveRecord::Base.table_name_prefix" do
    it "when prefix is not set, use 'delayed_jobs' as table name" do
      ActiveRecord::Base.table_name_prefix = nil
      Delayed::Backend::ModernRecord::Job.set_delayed_job_table_name

      expect(Delayed::Backend::ModernRecord::Job.table_name).to eq "delayed_jobs"
    end

    it "when prefix is set, prepend it before default table name" do
      ActiveRecord::Base.table_name_prefix = "custom_"
      Delayed::Backend::ModernRecord::Job.set_delayed_job_table_name

      expect(Delayed::Backend::ModernRecord::Job.table_name).to eq "custom_delayed_jobs"

      ActiveRecord::Base.table_name_prefix = nil
      Delayed::Backend::ModernRecord::Job.set_delayed_job_table_name
    end
  end
end
