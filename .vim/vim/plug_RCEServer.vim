" for establish a server listening on created named pipe for cmd execution with outside input and more
augroup RCEServer
  autocmd! VimLeavePre * call RCEChannel_killAllServer()
augroup END

function! RCEChannel_executeInVim_shellscript(cmd, fzf2relay_pipe, relay2fzf_pipe)
  let l:autocmd_prefix = 'autocmd! BufEnter * ++once '
  " let l:return_script = "echo " . shellescape(s:gpgRCEChannel_signkey . l:autocmd_prefix . a:cmd, v:true)
  let l:return_script = "echo " . shellescape(s:gpgRCEChannel_signkey . a:cmd, v:true)
        \ . " > " . a:fzf2relay_pipe
        \ . " && cat " . a:relay2fzf_pipe
  return l:return_script
endfunction

" let s:gpgRCEChannel_passphrase = '81189822942206922'
let s:gpgRCEChannel_signkey = 'RCEChannel_executeCMD' " whatever...
function! s:RCEChannel_OnReadExecute(channel, msg)
  if a:msg[:len(s:gpgRCEChannel_signkey)-1] == s:gpgRCEChannel_signkey
  " just to prevent accidental RCE mess, encryption too overkill
    let l:stdout = ''
    redir => l:stdout
      execute a:msg[len(s:gpgRCEChannel_signkey):]
    redir END
    call ch_sendraw(a:channel, l:stdout)
    " echom "executed: " . a:msg[len(s:gpgRCEChannel_signkey):]
  endif
endfunction

function! RCEChannel_OnExitExecute(curry_serverName, job, exit_code)
  call RCEChannel_RCEServerStop(a:curry_serverName)
  echom "server:" . a:curry_serverName . " exited"
endfunction

if !exists('g:active_RCEserver_dict')
  let g:active_RCEserver_dict = {}
endif
function! RCEChannel_RCEServerStart(server_name)
  if !exists('g:active_RCEserver_dict')
    throw expand('<stack>') . " - g:active_RCEserver_dict doesn't exist for tracking"
  elseif has_key(g:active_RCEserver_dict, a:server_name)
    echom "server " . a:server_name . " already up and running!"
    return RCEChannel_getServer(a:server_name)
  endif
  let l:fzf2relay_pipe = RCEChannel_pipeCreate()
  let l:relay2fzf_pipe = RCEChannel_pipeCreate()
  let job_option = {
        \ 'out_cb' : function('s:RCEChannel_OnReadExecute'),
        \ 'exit_cb' : Curry(function('RCEChannel_OnExitExecute'), a:server_name)
        \ }
  let l:job_id = Create_CallBackOnRead(
        \ job_option,
        \ l:fzf2relay_pipe,
        \ l:relay2fzf_pipe)
  let RCE_handle = [l:fzf2relay_pipe, l:relay2fzf_pipe, l:job_id]
  let g:active_RCEserver_dict[a:server_name] = l:RCE_handle
  return RCE_handle
endfunction

function! RCEChannel_RCEServerStop(identifier)
  if type(a:identifier) == v:t_list && len(a:identifier) == 2
    let [l:fzf2relay_pipe, l:relay2fzf_pipe, l:job_id] = a:identifier
    let counter = 0
    let removing_serverName = ''
    for [_, dict_jobid] in values(g:active_RCEserver_dict)
      if l:dict_jobid == l:job_id
        let l:removing_serverName = keys(g:active_RCEserver_dict)[l:counter]
      endif
      let l:counter += 1
    endfor
    call remove(g:active_RCEserver_dict, l:removing_serverName)
  elseif type(a:identifier) == v:t_string
    let [l:fzf2relay_pipe, l:relay2fzf_pipe, l:job_id] = RCEChannel_getServer(a:identifier)
    call remove(g:active_RCEserver_dict, a:identifier)
  else
    throw expand('<stack>') . " - wrong type of arguments"
  endif
  call RCEChannel_pipeDestroy(l:fzf2relay_pipe)
  call RCEChannel_pipeDestroy(l:relay2fzf_pipe)
  call job_stop(l:job_id)
  return
endfunction

function! RCEChannel_killAllServer()
  for server_name in keys(g:active_RCEserver_dict)
    call RCEChannel_RCEServerStop(l:server_name)
  endfor
endfunction

function! RCEChannel_getServer(key)
  return g:active_RCEserver_dict[a:key]
endfunction

function! RCEChannel_serverExists(server_name)
  return has_key(g:active_RCEserver_dict, server_name)
endfunction

" create channel for other process to execute code in this vim instance
function! RCEChannel_pipeCreate()
  let l:pipeName = ''
  redir => l:pipeName
    silent echo system("mktemp -u RCEChannelXXXXX")
  redir END
  " echom "tmp file name: " . l:pipeName
  let l:pipeName = "/tmp/" . l:pipeName->substitute("\\n", "", 'g')
  silent call system("mkfifo " . l:pipeName)
  return l:pipeName
endfunction

function! RCEChannel_pipeDestroy(pipeName)
  silent call system("rm " . a:pipeName)
endfunction

function! OnPipeMessage(channel, msg)
  echom "###"
  echom "job read channel - " . string(a:channel) . " :"
  echom a:msg
  " if !empty(a:msg)
  "   for line in a:msg
  "     echo "Received: " . line
  "   endfor
  " endif
endfunction

function! OnJobExit(job, exit_code)
  echom "@@@"
  echom "exit code: " . a:exit_code
endfunction

" kinda awkward, but
" let g:shell_listener_path = fnamemodify(g:env_shellscript_path, ':p') . 'read_from_pipe.sh'
let g:shell_listener_path = fnamemodify(g:env_shellscript_path, ':p') . 'fifo_relay'
function! Create_CallBackOnRead(job_option, fzf2relay_pipe, relay2fzf_pipe)
" returns job id of the pipe listener
  " let shell_listener_path = fnamemodify(g:env_shellscript_path, ':p') . 'read_from_pipe.sh'
  if !filereadable(g:shell_listener_path)
    throw expand('<stack>') . " - relay program not present"
  endif
  let shell_listener = "zsh " . g:shell_listener_path . " " . a:fzf2relay_pipe . " " . a:relay2fzf_pipe
  " echom l:shell_listener
  " let job_option = {
  "       \ 'out_cb' : function(a:callback_function),
  "       \ 'exit_cb' : function(a:exitCB_function)
  "       \ }
  let job_id = job_start(l:shell_listener, a:job_option)
  return l:job_id
endfunction