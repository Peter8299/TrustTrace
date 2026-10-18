"""Integrations with external analyst tooling that TrustTrace can use
when present but never requires: currently the Wireshark suite.

Everything in here is optional by construction. The platform's local-first
promise is that a plain `pip install trusttrace` gives a working
investigation with no external binaries, so each integration module is
responsible for detecting its own tooling and degrading to the built-in
path rather than raising on import.
"""

