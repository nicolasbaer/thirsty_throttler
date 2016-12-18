defmodule Throttler.LRU do

    def throttle(session_id) do

        IO.puts LruCache.get(:sessions, session_id)

        case LruCache.get(:sessions, session_id) do
            nil -> if :ets.info(:sessions, :size) > 3 do 
                    true 
                else  
                    LruCache.put(:sessions, session_id, "skjfsa")
                    false
                end
            _ -> false
        end
    end


end
