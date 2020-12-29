#!/bin/sh
# Run file to call the agent
# cd /MTC_Agent/
/lib/ld-musl-x86_64.so.1 --library-path lib /MTC_Agent/agent agent.cfg # || ./agent agent.cfg