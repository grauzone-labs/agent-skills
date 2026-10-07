# Plan: rate-limit the public API

Add per-client rate limiting to the public REST API so one client cannot starve the others.

Open points:

- Limit by API key or by IP address.
- Fixed window or sliding window.
- Where the counters live (in-process, Redis, or the gateway).
- What the client sees when limited (status code, headers, retry hint).
- Whether internal services get an exemption.
