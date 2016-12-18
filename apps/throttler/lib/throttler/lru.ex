defmodule Throttler.LRU do

    def now() do
        :os.system_time(:milli_seconds)
    end

    def dropOutdated() do
        #find oldest
        ttl_in_ms = 2000
        oldest_tstamp = :ets.first(:sessions_ttl)
        [{_, old_key}] = :ets.lookup(:sessions_ttl, oldest_tstamp) 
        [{_, old_sess_id, old_timestamp}] = :ets.lookup(:sessions, old_key) 

        #drop outdated
        if old_timestamp < (now - ttl_in_ms) do
            LruCache.delete(:sessions, old_key)
            dropOutdated
            true
        else
            false
        end

    end

    def throttle(session_id, cache_size) do
        case LruCache.get(:sessions, session_id) do
            nil ->  if :ets.info(:sessions, :size) >= cache_size do 
                        could_drop = dropOutdated
                        if could_drop do
                            LruCache.put(:sessions, session_id, now)
                        end
                        !could_drop
                    else  
                        LruCache.put(:sessions, session_id, now)
                        false
                    end
            _ -> LruCache.update(:sessions, session_id, now, touch = false)
                false
        end
    end
end
