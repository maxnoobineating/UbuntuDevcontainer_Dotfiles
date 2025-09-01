command! HugoSwitchHTMLCSS exec "e " . Hugo_correspondingHTMLCSS()
command! HugoSplitHTMLCSS exec "split " . Hugo_correspondingHTMLCSS()
command! HugovSplitHTMLCSS exec "vsplit " . Hugo_correspondingHTMLCSS()
nnoremap <expr> <C-f>ge "e " . Hugo_correspondingHTMLCSS()
nnoremap <expr> <C-f>gs "split " . Hugo_correspondingHTMLCSS()
nnoremap <expr> <C-f>gv "vsplit " . Hugo_correspondingHTMLCSS()

function! Hugo_correspondingHTMLCSS()
  if &filetype->Isin(['html'])
    return Hugo_equivalentCSSPath()
  elseif &filetype->Isin(['css', 'scss'])
    return Hugo_equivalentHTMLPath()
  else
    throw "this isn't a html or css file"
  endif
endfunction

let s:hugo_cssPath = 'assets/scss'
let s:hugo_cssExtension = 'scss'
let s:hugo_htmlPath = 'layouts'
let s:hugo_htmlExtension = 'html'
function! Hugo_equivalentCSSPath()
  let [hugoRoot, hugoFilePath] = Hugo_getHugoRootNFilePath()
  let htmlPath = hugoFilePath->split('/')[1:]->join('/')->Hugo_getHTMLPath()
  let cssFileName = hugoFilePath->fnamemodify(':t:r') . '.' . s:hugo_cssExtension
  return [hugoRoot , s:hugo_cssPath , htmlPath.dir, cssFileName]->join('/')
endf

function! Hugo_equivalentHTMLPath()
  let [hugoRoot, hugoFilePath] = Hugo_getHugoRootNFilePath()
  let cssPath = hugoFilePath->split('/')[1:]->join('/')->Hugo_getCSSPath()
  let htmlFileName = cssPath.fileName->fnamemodify(':r') . '.' . s:hugo_htmlExtension
  return [hugoRoot , s:hugo_htmlPath , cssPath.dir, htmlFileName]->join('/')
endf

function! Hugo_getHTMLPath(path)
  let pathSplit = a:path->split('/')
  if pathSplit[0] != s:hugo_htmlPath || pathSplit[-1]->fnamemodify(':e') != s:hugo_htmlExtension
    throw "the path isn't a hugo html file"
  endif
  return { 'dir': pathSplit[1:-2]->join('/'), 'fileName': pathSplit[-1]}
endf

function! Hugo_getCSSPath(path)
  let pathSplit = a:path->split('/')
  if pathSplit[0] != s:hugo_cssPath || pathSplit[-1]->fnamemodify(':e') != s:hugo_cssExtension
    throw "the path isn't a hugo css file"
  endif
  return { 'dir': pathSplit[1:-2]->join('/'), 'fileName': pathSplit[-1]}
endf

function! Hugo_getHugoRootNFilePath()
  " return [ hugoRoot, hugoFilePath ]
  " hugoRoot == "/root/path/to/hugo/file"
  " hugoFilePath == "filePath/relative/to/hugoRoot"
  let hugoRoot = expand('%:p')
  let filePath = ''
  while !Hugo_isHugoRoot(hugoRoot) && hugoRoot != '/'
    let hugoRoot = fnamemodify(hugoRoot, ':h')
    let filePath = fnamemodify(hugoRoot, ':t') . '/' . filePath
  endwhile
  if hugoRoot == '/'
    throw "this isn't a hugo file"
  endif
  return [hugoRoot, filePath]
endf

function! Hugo_isHugoRoot(path)
  " let matchDirs = ['archetypes', 'assets', 'content', 'data', 'i18n', 'layouts', 'node', 'public', 'resources', 'static', 'themes']
  let matchDirs = ['assets', 'content', 'layouts', 'static']
  let matchFiles = ['hugo.toml']
  let g:Hugo_isHugoRoot_path = a:path
  function! Hugo_containDir(index, dirName)
    return finddir(a:dirName, g:Hugo_isHugoRoot_path)
  endfunction
  " if matchDirs->All('finddir(v:val, ' . shellescape(a:path) . ')')
  return matchDirs->All('Hugo_containDir')
endf

function! Hugo_relativeHugoRoot()
  let path = './'
  while fnamemodify(path, ':p') != '/'
    let layoutsPath = finddir('layouts', path)
    if empty(layoutsPath)
      let path = '../' . path
      continue
    endif
    if empty(finddir('assets', path)) || !filereadable(fnamemodify(path, ':p') . 'hugo.toml')
      let path = '../' . path
      continue
    endif
    break
  endwhile
  return path
endfunction

command! HugoBuildCSSFileStructure call Hugo_BuildCSSFileStructure()
function! Hugo_BuildCSSFileStructure()
  " Recursively get all .html files under the layouts directory
  let path = Hugo_relativeHugoRoot()
  let l:files = glob(path . "layouts/**/*.html", 0, 1)
  for l:file in l:files
    " Replace the .html extension with .scss
    let l:scssFile = l:file->substitute('/\([^/]\{-}\)\.html$', '/_\1.scss', '')->substitute('\./layouts', './assets/scss', '')
    " Check if the .scss file already exists
    let l:scssFileDir = l:scssFile->fnamemodify(':h')
    if !mkdir(l:scssFileDir, "p")
      EchomWarn 'file ' . l:scssFile . ' directory creation failure!'
      continue
    endif
    if !filereadable(l:scssFile)
      " Create an empty file if it doesn't exist
      let lines = [
          \ '// global - this compiles into root to be reused by every matching class',
          \ '@mixin global {', '', '}', '', '',
          \ '// structural - this compiles into nested css selector that target specifically that element',
          \ '@mixin structural {' , '', '}', '', '',
          \ '// others', ''
          \ ]
      call writefile(lines, l:scssFile)
      echom "Created: " . l:scssFile
    else
      echom "Already exists: " . l:scssFile
    endif
  endfor
endfunction

