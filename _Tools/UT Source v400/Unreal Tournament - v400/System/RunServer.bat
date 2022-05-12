@echo off
:10
ucc server %1 %2 %3 %4 %5 %6 %7 %8 %9 -log=server.log
copy server.log servercrash.log
goto 10
