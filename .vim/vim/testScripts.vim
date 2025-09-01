" function! TerminalCatStdOut(cmd)
"   redir => cmd_stdout
"     silent! execute a:cmd
"   redir END
"   let term_bufnr = term_start("cat")
"   let term_job = term_getjob(term_bufnr)
"   let chan_id = job_getchannel(term_job)
"   call ch_sendraw(term_job, cmd_stdout)
"   sleep 100m
"   call ch_close(chan_id)
" endfunction
put h