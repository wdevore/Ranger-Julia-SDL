export TimingProperties

mutable struct TimingProperties
    paused::Bool

    function TimingProperties()
        new(
            false
        )
    end
end