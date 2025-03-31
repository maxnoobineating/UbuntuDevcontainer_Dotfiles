
source /root/pwndbg/gdbinit.py

define readlineApplicationName
  break rl_initialize
  r
  p (char*)rl_readline_name
end

set style enabled on
set disassembly-flavor intel
set verbose off

set context-sections ''

catch signal SIGSEGV
commands
    bt
    info locals
    info args
    gcore ~/.gdb/core.%p.dump
    quit
end

# Make sure GDB stops and prints a message on SIGSEGV
# handle SIGSEGV stop print nopass

# # Define a hook that runs every time the program stops.
# define hook-stop
#     if ($_siginfo && $_siginfo.si_signo == SIGSEGV)
#         echo *** Segmentation fault detected ***\n
#         bt
#     end
# end


# tui enable
# shell mkdir -p /tmp/gdb/
# shell test -p /tmp/gdb/gdblog || mkfifo /temp/gdb/gdblog
# set logging file /tmp/gdb/gdblog

# set trace-commands on
# set logging on

# source /root/.gdb_dashboard.gdbinit
