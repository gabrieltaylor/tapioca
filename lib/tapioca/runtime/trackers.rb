# typed: true
# frozen_string_literal: true

require "tapioca/runtime/trackers/tracker"

module Tapioca
  module Runtime
    module Trackers
      extend T::Sig

      @trackers = T.let([], T::Array[Tracker])

      class << self
        extend T::Sig

        sig { void }
        def disable_all!
          @trackers.each(&:disable!)
        end

        sig { params(tracker: Tracker).void }
        def register_tracker(tracker)
          @trackers << tracker
        end
      end
    end
  end
end

# The load order below is important:
# ----------------------------------
# We want the mixin tracker to be the first thing that is
# loaded because other trackers might apply their own mixins
# into core types (like `Module` and `Kernel`). In order to
# catch and filter those mixins as coming from Tapioca, we need
# the mixin tracker to be in place, before any mixin operations
# are performed.
require "tapioca/runtime/trackers/mixin"
require "tapioca/runtime/trackers/constant_definition"
require "tapioca/runtime/trackers/autoload"
require "tapioca/runtime/trackers/required_ancestor"
