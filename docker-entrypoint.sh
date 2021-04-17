#!/bin/sh
# Run file to call the agent
# cd /home/app/MTC_Agent/
ls
/lib/ld-musl-x86_64.so.1 --library-path lib /home/app/MTC_Agent/agent agent.cfg