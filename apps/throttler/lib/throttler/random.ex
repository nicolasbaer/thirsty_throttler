defmodule Throttler.Random do

    def throttle(_) do
        case :rand.uniform(2) do
            1 -> true
            2 -> false
        end
    end
end