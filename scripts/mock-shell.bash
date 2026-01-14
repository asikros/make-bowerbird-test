#!/bin/bash
for __c; do :; done
__c_normalized=$(printf "%s" "$__c" | tr -d '\' | tr -s "[:space:]" " " | sed "s/^ //" | sed "s/ $$//")
if [ "${__BOWERBIRD_MOCK_SHOW_SHELL+set}" = "set" ]; then
  printf "%s %s %s\n" "$__BOWERBIRD_SHELL" "$__BOWERBIRD_SHELLFLAGS" "$__c_normalized" >>"$BOWERBIRD_MOCK_RESULTS"
else
  printf "%s\n" "$__c_normalized" >>"$BOWERBIRD_MOCK_RESULTS"
fi
