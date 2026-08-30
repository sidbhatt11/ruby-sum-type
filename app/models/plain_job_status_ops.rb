# frozen_string_literal: true

# The control group: same behaviour, written the idiomatic bare-Ruby way.
# Nothing connects this match to the variant list, so it has no case for
# Failed and nothing notices until a Failed value reaches it.
module PlainJobStatusOps
  def self.describe(status)
    case status
    in JobStatus::Queued then 'waiting to start'
    in JobStatus::Running[started_at:] then "running since #{started_at}"
    in JobStatus::Done[result:] then "finished: #{result}"
    end
  end
end
