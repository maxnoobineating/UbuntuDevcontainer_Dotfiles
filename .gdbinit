set style enabled on
set disassembly-flavor intel
set verbose off
source /root/pwndbg/gdbinit.py

set context-sections ''

catch signal SIGSEGV
commands
    gcore ~/.gdb/core.%p.dump
    quit
end
