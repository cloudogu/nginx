# Request Buffering

When buffering is enabled, nginx receives the response to a page request as fast as possible and stores it
into the buffer of the nginx-dogus, to pass it on from there bit by bit. This improves performance for
users with slow internet connections.
Buffering can be enabled/disabled for individual dogus. To do this, a registry key must be set in the following format:
```
/config/nginx/buffering/<doguname> = on|off
```
If no value is set, buffering is always enabled.

After the key is set in the registry, nginx and the dogu for which the key was set must be restarted.
