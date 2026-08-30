# frozen_string_literal: true

# An ordinary in-memory model. `status` holds a JobStatus variant; asking
# what it means is the matcher's job.
class Job
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :name, :string
  attribute :status # holds a JobStatus variant

  validates :name, presence: true

  def describe = JobStatusOps::Describe.call(status)
  def describe_plain = PlainJobStatusOps.describe(status)
end
