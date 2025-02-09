" gf to go to file
" help ftplugin ~/.vim/ftplugin/help.vim
" $runtimepath/autoload/some/name
"     - not preloaded but sourced whenever function some#name#functionName() is called
"     - generally, source-loaded file is for mapping/env-setup... etc, while /autoload/ is for functions
" $runtimepath/plugin/
"     - automatically sourced before /vim/, but for vimplug manager,
"     - it adds /plugged/ and add the directory under &runtimepath so vim treate it as a total /.vim

source $HOME/.vim/vim/general_settings.vim
source $HOME/.vim/vim/functions.vim
" TODO export below 2 as its own plugin / move to ../plugin as extension of individual plugins
source $HOME/.vim/vim/customPlugins.vim
source $HOME/.vim/vim/plugin_configs.vim
source $HOME/.vim/vim/plugin_configs_directory.vim
source $HOME/.vim/vim/misc_mappings_sets.vim
source $HOME/.vim/vim/debugger.vim
source $HOME/.vim/vim/post_config.vim
source $HOME/.vim/vim/highlight.vim

" $runtimepath/after/
"     - post loading
DebuggerOff