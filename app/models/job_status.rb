# frozen_string_literal: true

# The sum: a job is in exactly one of these states, and each carries exactly
# the data that state has.
module JobStatus
  extend SumType

  Queued  = Data.define
  Running = Data.define(:started_at)
  Done    = Data.define(:result)
  Failed  = Data.define(:error)

  variants(
    queued: Queued,
    running: Running,
    done: Done,
    # failed: Failed,
  )
end
