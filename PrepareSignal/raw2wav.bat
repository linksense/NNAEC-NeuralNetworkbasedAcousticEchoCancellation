@echo off
sox -r %2 -s -w -c 1 %1 -r %2 %~d1%~p1%~n1.wav


