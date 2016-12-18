defmodule Throttler.LRU do

    def throttle(session_id, cache_size) do
        case LruCache.get(:sessions, session_id) do
            nil ->  if :ets.info(:sessions, :size) >= cache_size do 
                        true 
                    else  
                        LruCache.put(:sessions, session_id, "skjfsa")
                        false
                    end
            _ -> false
        end
    end
end
