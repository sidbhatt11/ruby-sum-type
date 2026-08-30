# frozen_string_literal: true

module JobStatusOps
  # A constant, so it is built — and checked — when the file loads.
  Describe = JobStatus.matcher(
    queued: ->(_) { 'waiting to start' },
    running: ->(s) { "running since #{s.started_at}" },
    done: ->(s) { "finished: #{s.result}" },
  )
end
