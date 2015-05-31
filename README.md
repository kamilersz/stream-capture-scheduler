# Kamilersz Streamripper
Rip any online music streaming

Requirements:
- doalarm
- mplayer
- FPC

TODO: (feel free to join)
- Make program parameter configurable
- Easy-to-read schedule syntax
- Killable/restartable by program signaling
- Daemonize process

How to run:
- Compile: fpc main.pas
- Run: screen ./main (or just ./main if you don't wan running background)

Why did I choose Pascal instead of C?
Because when this program was written in C the stability is doubtful, only able to run up to 1 week. And this Pascal code can still run for years. Dunno why.
