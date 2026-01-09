#!/bin/sh
# Extract command (always last argument after SHELLFLAGS)
eval "COMMAND=\"\${$#}\""
echo "$COMMAND" >> "${BOWERBIRD_MOCK_RESULTS:?BOWERBIRD_MOCK_RESULTS must be set}"
