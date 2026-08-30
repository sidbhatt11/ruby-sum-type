# ruby-sum-type

Sum types in plain Ruby, checked at Rails boot. The repo behind the Ruby
Melbourne talk "SumTypes and Ruby" (August 2026).

- Talk: [talk.pdf](talk.pdf)
- The `SumType` module as one postable file:
  [gist](https://gist.github.com/sidbhatt11/5538e2e7d47efa3cddb16ace8556d42a)

## The idea

1. `SumType.matcher` validates its handlers against the variant registry when
   the matcher is constructed, not when it is called.
2. Matchers are constants, so construction happens when the file loads.
3. Rails eager-loads every constant at boot, in production and CI.

Add a variant, forget to update a matcher, and the app refuses to start,
naming the missing variant and the file that forgot it.

## Run it

```sh
bundle install
rake        # rubocop + tests + boot check
```

A minimal Rails app: `railties` and `activemodel` only, no ActiveRecord, no
database. One domain (a job's status), one mistake (a variant is added, the
code matching on it is not), two outcomes.

### Bare Ruby crashes at runtime

`PlainJobStatusOps` is idiomatic `case/in` with no `else`, and has no case for
`JobStatus::Failed`. Nothing noticed.

```sh
bin/plain-crash
```

The app boots, then the first failed job dies with `NoMatchingPatternError` at
the call site. No check ran; a value found the hole.

### SumType refuses to boot

In `app/models/job_status.rb`:

```ruby
variants(
  queued: Queued,
  running: Running,
  done: Done,
  # failed: Failed,    <-- uncomment this line
)
```

`JobStatusOps` is left alone, exactly as it would be if you forgot it.

```sh
bin/boot-check
```

```
app/models/concerns/sum_type.rb:33:in 'SumType#matcher': missing handlers for: failed (SumType::NonExhaustiveMatch)
	from app/models/job_status_ops.rb:5:in '<module:JobStatusOps>'

BOOT FAILED (exit 1) — a matcher does not cover its sum.
```

## The cops

RuboCop runs at full strictness (`NewCops: enable`) plus two custom cops in
`lib/rubocop/cop/sum_type/`, both guarding preconditions the boot check needs.

`SumType/MatcherInMethod` catches a matcher built inside a method, which is
validated on first call rather than at boot. This is the load-bearing one: the
guarantee holds only if every matcher is a constant.

`SumType/VariantsNotDeclared` catches a module that extends `SumType` but never
calls `variants(...)`, which raises on first use rather than at boot.

## Notes

- `config.eager_load = true` in development is deliberate, so `bin/rails`
  behaves the way production and CI already do.
- Dispatch is a class-keyed hash with an `is_a?` scan as the fallback for
  subclass carriers, so it costs less than `case/in`. `bin/bench` measures it.
- `test/` guards that fallback: delete the scan as redundant and
  `test_falls_back_to_is_a_scan_for_subclasses` is the only thing that notices.
  The boot check cannot see it, since it only proves matchers are exhaustive.
- A cop doing the exhaustiveness check itself was prototyped and rejected. It
  works, but must abstain on `**splat` handlers, aliased sums and dynamic keys,
  all of which the boot check catches.
