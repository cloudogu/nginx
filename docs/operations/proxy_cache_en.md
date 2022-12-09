# Request cache and buffering

## Buffering
When buffering is enabled, nginx gets the response to a page request as fast as possible and stores it
into the buffer of the nginx-dogus, to pass it on from there bit by bit. This improves performance for
users with slow internet connections.
Buffering can be enabled/disabled for individual dogus. To do this, a registry key must be set in the following format:
```
/config/nginx/buffering/<doguname> = on|off
```
If no value is set, buffering is always enabled.

## Caching
When caching is enabled, Nginx stores web page accesses in its cache.

Caching can be enabled/disabled for individual dogus. To do this, a registry key must be set in the following format:
```
/config/nginx/cache/<doguname> = on|off
```
If no value is set, caching is always enabled.

