" HSV / RGB shouldn't be rounded, to avoid back translation error - do rounding only in RGB -> hex
let s:colorCode_max = 255.0
function! ColorMapping_nr2RGB(nr)
  let hex = a:nr
  if hex > 0xffffff || hex < 0
    throw expand("<stack>") . " - illegal hex color value " . hex
  endif
  let ret_RGB = []
  for _ in range(3)
    let ret_RGB += [hex % 0x100]
    let hex /= 0x100
  endfor
  return ret_RGB->reverse()
endfunction

function! ColorMapping_RGB2nr(RGB)
  return a:RGB->reduce({acc, val -> acc * 256.0 + val }, 0)
endfunction

function! ColorMapping_RGB2HSV(RGB)
  let [R, G, B] = a:RGB->map({_, val -> val + 0.0})
  let [minC, _, maxC] = [R, G, B]->sort()
  let V = maxC
  let Hfunc = {X, Y -> X == minC ?  -42.5 * (Y - minC) / (maxC - minC) : 42.5 * (X - minC) / (maxC - minC)}
  if maxC == minC
    let H = 0.0
    let S = 0.0
    return [H, S, V]
  elseif R == maxC
    let H = 0.0
    let H = H + Hfunc(G, B)
    let H = H < 0 ? 255.0 - H : H
  elseif G == maxC
    let H = 85.0
    let H = H + Hfunc(B, R)
  else " B == maxC
    let H = 170.0
    let H = H + Hfunc(R, G)
  endif
  " let H = H->round()->float2nr()
  let S = (((maxC - minC) / maxC)) * 255.0
  " let S = S->round()->float2nr()
  return [H, S, V]
endfunction

function! ColorMapping_HSV2RGB(HSV)
  let [H, S, V] = a:HSV->map({_, val -> val + 0.0})
  let maxC = V
  let minC = maxC - (S * maxC) / 255.0
  let midC = (H * ( maxC - minC )) / 255.0 + minC
  let arrC = [maxC, midC, minC]
  if H <= 42.5 || H >= 212.5 " < v.s. <= : bondary priority R > G > B, but it's a continuous mapping so whatever
    if H <= 42.5
      let [R, G, B] = arrC
    else
      let [R, B, G] = arrC
    endif
  elseif H > 42.5 && H <= 127.5
    if H <= 85
      let [G, R, B] = arrC
    else
      let [G, B, R] = arrC
    endif
  else " H > 127.5 && H < 212.5
    if H <= 170
      let [B, G, R] = arrC
    else
      let [B, R, G] = arrC
    endif
  endif
  return [R, G, B]
endfunction

function! ColorMapping_hexstr2nr(hexstr)
  return a:hexstr[1:]->str2nr(16)
endfunction

function! ColorMapping_nr2hexstr(nr)
  return '#' . printf('%06x', a:nr)
endfunction

function! ColorMapping_hexstr2RGB(hexstr)
  return [a:hexstr[1:2], a:hexstr[3:4], a:hexstr[5:]]->map('str2nr(v:val, 16)')
endfunction

function! ColorMapping_RGB2hexstr(RGB)
  return '#' . a:RGB->map("printf('%02x', v:val->float2nr())")->join('')
endfunction

let g:colorMapping_256toFullColor_mapping = {
      \ 0: 0x000000,
      \ 1: 0x800000,
      \ 2: 0x008000,
      \ 3: 0x808000,
      \ 4: 0x000080,
      \ 5: 0x800080,
      \ 6: 0x008080,
      \ 7: 0xc0c0c0,
      \ 8: 0x808080,
      \ 9: 0xff0000,
      \ 10: 0x00ff00,
      \ 11: 0xffff00,
      \ 12: 0x0000ff,
      \ 13: 0xff00ff,
      \ 14: 0x00ffff,
      \ 15: 0xffffff,
      \ 16: 0x000000,
      \ 17: 0x00005f,
      \ 18: 0x000087,
      \ 19: 0x0000af,
      \ 20: 0x0000d7,
      \ 21: 0x0000ff,
      \ 22: 0x005f00,
      \ 23: 0x005f5f,
      \ 24: 0x005f87,
      \ 25: 0x005faf,
      \ 26: 0x005fd7,
      \ 27: 0x005fff,
      \ 28: 0x008700,
      \ 29: 0x00875f,
      \ 30: 0x008787,
      \ 31: 0x0087af,
      \ 32: 0x0087d7,
      \ 33: 0x0087ff,
      \ 34: 0x00af00,
      \ 35: 0x00af5f,
      \ 36: 0x00af87,
      \ 37: 0x00afaf,
      \ 38: 0x00afd7,
      \ 39: 0x00afff,
      \ 40: 0x00d700,
      \ 41: 0x00d75f,
      \ 42: 0x00d787,
      \ 43: 0x00d7af,
      \ 44: 0x00d7d7,
      \ 45: 0x00d7ff,
      \ 46: 0x00ff00,
      \ 47: 0x00ff5f,
      \ 48: 0x00ff87,
      \ 49: 0x00ffaf,
      \ 50: 0x00ffd7,
      \ 51: 0x00ffff,
      \ 52: 0x5f0000,
      \ 53: 0x5f005f,
      \ 54: 0x5f0087,
      \ 55: 0x5f00af,
      \ 56: 0x5f00d7,
      \ 57: 0x5f00ff,
      \ 58: 0x5f5f00,
      \ 59: 0x5f5f5f,
      \ 60: 0x5f5f87,
      \ 61: 0x5f5faf,
      \ 62: 0x5f5fd7,
      \ 63: 0x5f5fff,
      \ 64: 0x5f8700,
      \ 65: 0x5f875f,
      \ 66: 0x5f8787,
      \ 67: 0x5f87af,
      \ 68: 0x5f87d7,
      \ 69: 0x5f87ff,
      \ 70: 0x5faf00,
      \ 71: 0x5faf5f,
      \ 72: 0x5faf87,
      \ 73: 0x5fafaf,
      \ 74: 0x5fafd7,
      \ 75: 0x5fafff,
      \ 76: 0x5fd700,
      \ 77: 0x5fd75f,
      \ 78: 0x5fd787,
      \ 79: 0x5fd7af,
      \ 80: 0x5fd7d7,
      \ 81: 0x5fd7ff,
      \ 82: 0x5fff00,
      \ 83: 0x5fff5f,
      \ 84: 0x5fff87,
      \ 85: 0x5fffaf,
      \ 86: 0x5fffd7,
      \ 87: 0x5fffff,
      \ 88: 0x870000,
      \ 89: 0x87005f,
      \ 90: 0x870087,
      \ 91: 0x8700af,
      \ 92: 0x8700d7,
      \ 93: 0x8700ff,
      \ 94: 0x875f00,
      \ 95: 0x875f5f,
      \ 96: 0x875f87,
      \ 97: 0x875faf,
      \ 98: 0x875fd7,
      \ 99: 0x875fff,
      \ 100: 0x878700,
      \ 101: 0x87875f,
      \ 102: 0x878787,
      \ 103: 0x8787af,
      \ 104: 0x8787d7,
      \ 105: 0x8787ff,
      \ 106: 0x87af00,
      \ 107: 0x87af5f,
      \ 108: 0x87af87,
      \ 109: 0x87afaf,
      \ 110: 0x87afd7,
      \ 111: 0x87afff,
      \ 112: 0x87d700,
      \ 113: 0x87d75f,
      \ 114: 0x87d787,
      \ 115: 0x87d7af,
      \ 116: 0x87d7d7,
      \ 117: 0x87d7ff,
      \ 118: 0x87ff00,
      \ 119: 0x87ff5f,
      \ 120: 0x87ff87,
      \ 121: 0x87ffaf,
      \ 122: 0x87ffd7,
      \ 123: 0x87ffff,
      \ 124: 0xaf0000,
      \ 125: 0xaf005f,
      \ 126: 0xaf0087,
      \ 127: 0xaf00af,
      \ 128: 0xaf00d7,
      \ 129: 0xaf00ff,
      \ 130: 0xaf5f00,
      \ 131: 0xaf5f5f,
      \ 132: 0xaf5f87,
      \ 133: 0xaf5faf,
      \ 134: 0xaf5fd7,
      \ 135: 0xaf5fff,
      \ 136: 0xaf8700,
      \ 137: 0xaf875f,
      \ 138: 0xaf8787,
      \ 139: 0xaf87af,
      \ 140: 0xaf87d7,
      \ 141: 0xaf87ff,
      \ 142: 0xafaf00,
      \ 143: 0xafaf5f,
      \ 144: 0xafaf87,
      \ 145: 0xafafaf,
      \ 146: 0xafafd7,
      \ 147: 0xafafff,
      \ 148: 0xafd700,
      \ 149: 0xafd75f,
      \ 150: 0xafd787,
      \ 151: 0xafd7af,
      \ 152: 0xafd7d7,
      \ 153: 0xafd7ff,
      \ 154: 0xafff00,
      \ 155: 0xafff5f,
      \ 156: 0xafff87,
      \ 157: 0xafffaf,
      \ 158: 0xafffd7,
      \ 159: 0xafffff,
      \ 160: 0xd70000,
      \ 161: 0xd7005f,
      \ 162: 0xd70087,
      \ 163: 0xd700af,
      \ 164: 0xd700d7,
      \ 165: 0xd700ff,
      \ 166: 0xd75f00,
      \ 167: 0xd75f5f,
      \ 168: 0xd75f87,
      \ 169: 0xd75faf,
      \ 170: 0xd75fd7,
      \ 171: 0xd75fff,
      \ 172: 0xd78700,
      \ 173: 0xd7875f,
      \ 174: 0xd78787,
      \ 175: 0xd787af,
      \ 176: 0xd787d7,
      \ 177: 0xd787ff,
      \ 178: 0xd7af00,
      \ 179: 0xd7af5f,
      \ 180: 0xd7af87,
      \ 181: 0xd7afaf,
      \ 182: 0xd7afd7,
      \ 183: 0xd7afff,
      \ 184: 0xd7d700,
      \ 185: 0xd7d75f,
      \ 186: 0xd7d787,
      \ 187: 0xd7d7af,
      \ 188: 0xd7d7d7,
      \ 189: 0xd7d7ff,
      \ 190: 0xd7ff00,
      \ 191: 0xd7ff5f,
      \ 192: 0xd7ff87,
      \ 193: 0xd7ffaf,
      \ 194: 0xd7ffd7,
      \ 195: 0xd7ffff,
      \ 196: 0xff0000,
      \ 197: 0xff005f,
      \ 198: 0xff0087,
      \ 199: 0xff00af,
      \ 200: 0xff00d7,
      \ 201: 0xff00ff,
      \ 202: 0xff5f00,
      \ 203: 0xff5f5f,
      \ 204: 0xff5f87,
      \ 205: 0xff5faf,
      \ 206: 0xff5fd7,
      \ 207: 0xff5fff,
      \ 208: 0xff8700,
      \ 209: 0xff875f,
      \ 210: 0xff8787,
      \ 211: 0xff87af,
      \ 212: 0xff87d7,
      \ 213: 0xff87ff,
      \ 214: 0xffaf00,
      \ 215: 0xffaf5f,
      \ 216: 0xffaf87,
      \ 217: 0xffafaf,
      \ 218: 0xffafd7,
      \ 219: 0xffafff,
      \ 220: 0xffd700,
      \ 221: 0xffd75f,
      \ 222: 0xffd787,
      \ 223: 0xffd7af,
      \ 224: 0xffd7d7,
      \ 225: 0xffd7ff,
      \ 226: 0xffff00,
      \ 227: 0xffff5f,
      \ 228: 0xffff87,
      \ 229: 0xffffaf,
      \ 230: 0xffffd7,
      \ 231: 0xffffff,
      \ 232: 0x080808,
      \ 233: 0x121212,
      \ 234: 0x1c1c1c,
      \ 235: 0x262626,
      \ 236: 0x303030,
      \ 237: 0x3a3a3a,
      \ 238: 0x444444,
      \ 239: 0x4e4e4e,
      \ 240: 0x585858,
      \ 241: 0x606060,
      \ 242: 0x666666,
      \ 243: 0x767676,
      \ 244: 0x808080,
      \ 245: 0x8a8a8a,
      \ 246: 0x949494,
      \ 247: 0x9e9e9e,
      \ 248: 0xa8a8a8,
      \ 249: 0xb2b2b2,
      \ 250: 0xbcbcbc,
      \ 251: 0xc6c6c6,
      \ 252: 0xd0d0d0,
      \ 253: 0xdadada,
      \ 254: 0xe4e4e4,
      \ 255: 0xeeeeee
      \ }



" 5f  87  af  df > d7!  ff
" 95  135 175 223> 215 255
function! s:ColorMapping_helper_hex2nearest16(nrRR, nrGG, nrBB)
  let s:colorMapping_acc_scale = 0
  let s:colorMapping_acc_base = 4
  let ret_scale = [nrRR, nrGG, nrBB]->reduce({ acc, val -> acc * 2 + round(val / 128.0) }, 0)
  let ret_diff = [nrRR, nrGG, nrBB]->reduce({ acc, val -> acc + val - round(val / 128.0) * 128.0 }, 0)
  " beware, ff will be rounded to 256, so it will have a diff of 1 despite being on the exactly ff (because we tries to fit )
  unlet s:colorMapping_acc
endfunction

function! ColorMapping_helper_hex2nearest256(hexstr)
  " returning [256scale, total deviation]
  " hexstr must be of the form \x\{6}
  let [nrRR, nrGG, nrBB] = [a:hexstr[:2], a:hexstr[2:4], a:hexstr[4:]]->map('str2nr(v:val, 16)')
  " 256 colors 16-231 is mapped to hex #00005f, #000087, ..., #ffffd7, #ffffff 
  " (40 in between, except when it went from 00 to 5f)
  function! s:ColorMapping_helper_hex2nearest256_greyScale(nrRR, nrGG, nrBB)
    " returning [256scale greyScale(232-255), total deviation]
    let total_brightness = (a:nrRR + a:nrGG + a:nrBB) 
    let avg_brightness =  total_brightness / 3.0
    let avg_brightness_scale = round((avg_brightness - 8) / 10.0)
    if avg_brightness_scale < 0
      " return color black (#000000)
      return 0, total_brightness - 0x000000
    endif
    " you should check if this falls into 232-255 yourself
    return 232 + avg_brightness_scale, total_brightness - (avg_brightness_scale * 10 + 8) * 3
  endfunction
  if (nrRR <= 75) && (nrGG <= 75) && (nrBB <= 75)
    " grey scale 232-239 
    " #080808, #121212, ... 10 in between but starts at 8
    return s:ColorMapping_helper_hex2nearest256_greyScale(nrRR, nrGG, nrBB)
  endif
  let [nrRRScale_round, nrGGScale_round, nrBBScale_round] = [nrRR, nrGG, nrBB]->map('round((v:val - 95) / 40.0)')
  if (nrRRScale_round == nrGGScale_round) && (nrGGScale_round == nrBBScale_round)
    " finer fitting check into the rest of grey scale 239-255
    let greyScale256 = s:ColorMapping_helper_hex2nearest256_greyScale(nrRR, nrGG, nrBB)
    let [nrRR_diff, nrGG_diff, nrBB_diff] = [nrRR, nrGG, nrBB]->map('round((v:val - 95) / 40.0) * 40 + 95 - v:val')
    if abs((nrRR+nrGG+nrBB) / 3.0 - ((greyScale256-232) * 10 + 8))
          \ < (nrRR_diff * 40 + 95)
    endif
  endif
  
endfunction

function! ColorMapping_mapHighlight(colorMappingFunc) abort
  " colorMappingFunc: groupname -> none (execute highlight groupname ...)
  " Iterate over all highlight groups
  for group in split(execute('highlight'), '\n')
    " Extract the group name
    let groupname = matchstr(group, '^\S\+')
    if empty(groupname)
      continue
    endif
    if groupname =~# '^BG\x\{6}'
      continue
    endif
    try
      call a:colorMappingFunc(groupname)
    catch
      echom "#groupname=" . groupname
      echom "#exception=" . v:exception
      redir => verbosemsg
        execute "verbose highlight " . groupname
      redir END
      echom "#msg:".verbosemsg 
      echom
      return
    endtry
  endfor
endfunction

function! ColorMapping_verityCoralPink(groupname)
  let fg = synIDattr(synIDtrans(hlID(a:groupname)), 'fg', 'cterm')
  let bg = synIDattr(synIDtrans(hlID(a:groupname)), 'bg', 'cterm')

  " Adjust the foreground color if it's a number and greater than 51
  if fg =~ '^\d\+$' && fg > 51
      let new_fg = fg - 36
      execute 'highlight ' . a:groupname . ' ctermfg=' . new_fg
  endif

  " Adjust the background color if it's a number and greater than 51
  if bg =~ '^\d\+$' && bg > 51
      let new_bg = bg - 36
      execute 'highlight ' . a:groupname . ' ctermbg=' . new_bg
  endif
endfunction

let g:ColorMapping_256toFullColor_brightenVal = 0.5
function! BrightenRGB(hex)
  let hexstr = printf('%06x', a:hex)
  let RGB = [hexstr[:1], hexstr[2:3], hexstr[4:]]->map('str2nr(v:val, 16)')
  " echom "@RGB=" . string(RGB)
  " echom "# RGBhex=". RGB->reduce({acc,val->acc . printf('%02x', val)}, '')
  let ratio = g:ColorMapping_256toFullColor_brightenVal
  let RGB_brightened = RGB->map('float2nr(255 - '.ratio.' * (255 - v:val))')
  " echom "# RGB_brightened=" . string(RGB_brightened)
  let ret_hex = RGB_brightened->reduce({acc, val -> acc * 256.0 + val}, 0)
  " echom "# ret_hex=" . ret_hex
  return ret_hex
endfunction

let g:colorMapping_256toFullColor_mappingBrightened = g:colorMapping_256toFullColor_mapping->copy()->map({key, val -> BrightenRGB(val)})
function! ColorMapping_256toFullColor_brightenfg(groupname)
  if a:groupname =~ "BG\x\{6}"
    return
  endif
  let groupID = hlID(a:groupname)
  if groupID != synIDtrans(groupID)
    " skip linked hlgroup, it'll be fine
    return
  endif
  call ColorMapping_256toFullColor(a:groupname, g:colorMapping_256toFullColor_mappingBrightened, 'fg')
  call ColorMapping_256toFullColor(a:groupname, g:colorMapping_256toFullColor_mapping, 'bg')
endfunction

function! ColorMapping_256toFullColor(groupname, mapping, target)
  let color256 = synIDattr(synIDtrans(hlID(a:groupname)), a:target, 'cterm')
  if !empty(color256)
    let colorhex = a:mapping[str2nr(color256)]
    execute 'highlight '.a:groupname.' gui'.a:target.'=#' . printf('%06x', colorhex)
  endif
endfunction

function! ColorMapping_256toFullColor_dict(groupname, mapping, target)
  let color256 = synIDattr(synIDtrans(hlID(a:groupname)), a:target, 'cterm')
  if !empty(color256)
    let colorhex = a:mapping[str2nr(color256)]
    execute 'highlight '.a:groupname.' gui'.a:target.'=#' . printf('%06x', colorhex)
  endif
endfunction


function! ColorMapping_fillFullColorSettings_nr(groupname, AttrFunc, fillDict) abort
  let id = hlID(a:groupname)
  if id != synIDtrans(id)
    " link, skip in order to not override it
    return
  endif
  " let colorCode = synIDattr(id, a:target, a:termType)
  let colorCode = a:AttrFunc(id) " a:AttrFunc is supposed to return nr color code
  if !empty(colorCode)
    let a:fillDict[a:groupname] = g:colorMapping_256toFullColor_mapping[colorCode]
  endif
endfunction

function! ColorMapping_generateFullColorSettings_nr(target, mode)
  let colorMapping_fullColorSettings_nr = {}

  let AttrFunc = { id -> synIDattr(id, a:target, a:mode)->str2nr() }
  let MappingFunc = { groupname -> ColorMapping_fillFullColorSettings_nr(groupname, AttrFunc, colorMapping_fullColorSettings_nr) }
  call ColorMapping_mapHighlight(MappingFunc)
  return colorMapping_fullColorSettings_nr
endfunction

function! ColorMapping_generateFullColorSettings_hsv(target, mode)
  let colorMapping_fullColorSettings_nr = ColorMapping_generateFullColorSettings_nr(a:target, a:mode)
  let colorMapping_fullColorSettings_hsv = colorMapping_fullColorSettings_nr
        \ ->map({_, val -> val
          \ ->ColorMapping_nr2RGB()
          \ ->ColorMapping_RGB2HSV()})
  return colorMapping_fullColorSettings_hsv
endfunction

if !exists("g:colorMapping_fullColorSettings_hsv_fg")
  let g:colorMapping_fullColorSettings_hsv_fg = ColorMapping_generateFullColorSettings_hsv('fg', 'cterm')
endif
if !exists("g:colorMapping_fullColorSettings_hsv_bg")
  let g:colorMapping_fullColorSettings_hsv_bg = ColorMapping_generateFullColorSettings_hsv('bg', 'cterm')
endif

function! ColorMapping_avgHSV(settings_hsv)
  " should implement weighted average by inspecting currently active highlight groups instead
  " for [key, val] in a:settings_hsv
  "   let [_, S, V] = val
  " endfor
  " return [128.0, , ]
  return [127.5, 127.5, 127.5]
endfunction
if !exists('s:HSV_base')
  " s:ColorMapping_fullColorHSV_settings->copy()->map('(v:val).guibg')->reduce({ acc, val -> }, 0)
  let s:HSV_base = ColorMapping_avgHSV(v:none)
endif

" let s:HSV_popup = []
" Update the popup text: each line is a scroll bar for H, S, or V.
function! s:UpdatePopupContent(HSV_target) abort
  let barlen = 26
  let lines = []
  let label = ['H', 'S', 'V']
  for index in range(3)
    let value = a:HSV_target.HSV[index]
    " Compute marker position (0 .. barlen-1)
    let pos = float2nr(value * (barlen - 1) / 255.0)
    let bar = ''
    for i in range(0, barlen - 1)
      if i <= pos
        let bar .= '󰝤' 
      else
        let bar .= ''
      endif
    endfor
    " Format each line: e.g. "H: 󰝤󱡔  128"
    " Total width: label (2) + colon+space (2) + brackets (2) + bar (26) + space (1) + value (3) = 36;
    " adjust as needed to fit in 30 cols (here we assume fixed width font)
    let line = label[index] . ': [' . bar . '] ' . printf('%3d', float2nr(value))
    call add(lines, line)
  endfor
  return lines
endfunction

" Filter function to process key presses in the popup.
function! s:PopupFilter_gen(HSV_obj, HSV_callback) abort
  " Adjust the appropriate HSV value.
  let s:HSV_saved = (a:HSV_obj.HSV)->copy()
  function! s:PopupFilter(id, key, HSV_obj, HSV_callback)
    let HSV = a:HSV_obj.HSV->copy()->map({_, val -> float2nr(val)})
    if a:key ==# 'h'
      let a:HSV_obj.HSV[0] = min([255, HSV[0] + 1])
    elseif a:key ==# 'H'
      let a:HSV_obj.HSV[0] = max([0, HSV[0] - 1])
    elseif a:key ==# 's'
      let a:HSV_obj.HSV[1] = min([255, HSV[1] + 1])
    elseif a:key ==# 'S'
      let a:HSV_obj.HSV[1] = max([0, HSV[1] - 1])
    elseif a:key ==# 'v'
      let a:HSV_obj.HSV[2] = min([255, HSV[2] + 1])
    elseif a:key ==# 'V'
      let a:HSV_obj.HSV[2] = max([0, HSV[2] - 1])
    elseif a:key == "\<CR>"
    " Confirm: Enter key
      call popup_close(a:id)
      echom "HSV confirmed: " . a:HSV_obj.HSV[0] . ", " . a:HSV_obj.HSV[1] . ", " . a:HSV_obj.HSV[2]
      return 1
    elseif a:key == "\<Esc>" || a:key == "q"
    " Cancel: Escape key
      let a:HSV_obj.HSV = s:HSV_saved
      call popup_close(a:id)
      call a:HSV_callback(a:HSV_obj)
      echom "HSV setting cancelled."
      return 1
    else
      " Ignore any other keys.
      return 0
    endif
    " Update the popup text after any adjustment.
    call popup_settext(a:id, s:UpdatePopupContent(a:HSV_obj))
    call a:HSV_callback(a:HSV_obj)
    return 1
  endfunction
  return {id, key -> s:PopupFilter(id, key, a:HSV_obj, a:HSV_callback)}
endfunction

function! ColorMapping_colorSet_hlset(groupname, target, mode)
  call hlset()
endfunction

function! ColorMapping_getHSVObject(settings, target)
  return {'settings': a:settings, 'target': a:target, 'HSV': s:HSV_base->copy()}
endfunction

function! ColorMapping_colorSet_HSVCallback(HSV_obj) abort
  let HSV_dial = a:HSV_obj.HSV
  let [dH, dS, dV] = range(3)->map({ind, _ -> HSV_dial[ind] - s:HSV_base[ind]})
  let [pS, pV] = range(2)->map({ ind, _ -> [dS, dV][ind] - s:HSV_base[ind] })
  let pS = dS / ( dS > 0 ? s:HSV_base[1] + 0.0 : 255.0 - s:HSV_base[1])
  let pV = dV / ( dV > 0 ? s:HSV_base[2] + 0.0 : 255.0 - s:HSV_base[2])
  let HSV_settings = a:HSV_obj.settings
  let target = a:HSV_obj.target
  " let mode = a:HSV_obj.mode
  let hlset_list = []
  for groupname in HSV_settings->keys()
    let [H, S, V] = HSV_settings[groupname]
    let H = H + dH > 0 ? float2nr(H + dH) % 255 + 0.0 : float2nr(H + dH + 255.0) % 255 + 0.0
    let S = pS > 0 ? (255.0 - S) * pS + S : S * (1.0 + pS)
    let V = pV > 0 ? (255.0 - V) * pV + V : V * (1.0 + pV)
    " echom "# " . groupname . ": HSV=" . string([H, S, V])
    let hexstr = [H, S, V]->ColorMapping_HSV2RGB()->ColorMapping_RGB2hexstr()
    " echom "  hexstr: " . hexstr
    " echom ""
    let hlset_list += [{'name': groupname, target: hexstr}]
  endfor
  call hlset(hlset_list)
endfunction

" Main function to create the popup control panel.
function! ControlPanelHSV(HSV_obj, HSV_callback) abort
  " (Re)initialize values if needed.
  " let a:HSV_target = {'h': 128, 's': 128, 'v': 128}
  " Create a popup window with 3 lines and at least 30 columns.
  " You can adjust 'line' and 'col' for placement; here they appear near the cursor.
  silent! let p = popup_dialog(s:UpdatePopupContent(a:HSV_obj), {
        \ 'minwidth': 37,
        \ 'minheight': 3,
        \ 'line': 'cursor+1',
        \ 'col': winwidth(0),
        \ 'mappings': 0,
        \ 'borderchars': ['─', '│', '─', '│', '╭',  '╮', '╯', '╰'],
        \ 'highlight': 'WildMenu',
        \ 'filter': s:PopupFilter_gen(a:HSV_obj, a:HSV_callback)
        \ })
endfunction

function! UpdPopupC(HSV_obj)
  return s:UpdatePopupContent(a:HSV_obj)
endfunction


" 152 #AFD7D7
" 132 #afdfdf
" 0 #261720
" my coral pink 16 color mapping:
let g:ColorMapping_verityCoralPink_windowsTerm2hex = {
      \          "background": "#3D2730",
      \          "black": "#261720",
      \          "blue": "#555CD1",
      \          "brightBlack": "#332529",
      \          "brightBlue": "#7E99E3",
      \          "brightCyan": "#76D1DD",
      \          "brightGreen": "#3B593C",
      \          "brightPurple": "#B651D1",
      \          "brightRed": "#BD2878",
      \          "brightWhite": "#C7C7C7",
      \          "brightYellow": "#C9B256",
      \          "cursorColor": "#96B8BD",
      \          "cyan": "#35BDC4",
      \          "foreground": "#BDB5BD",
      \          "green": "#1D7A4F",
      \          "name": "Ubuntu-ColorScheme-Maxium",
      \          "purple": "#761485",
      \          "red": "#8A2840",
      \          "selectionBackground": "#9BBDBF",
      \          "white": "#9E978E",
      \          "yellow": "#A8774F"
      \ }

eval g:ColorMapping_verityCoralPink_windowsTerm2hex->map({ key, val -> ColorMapping_hexstr2nr(val) })
let g:ColorMapping_verityCoralPink_16toWindowsTerm = {
      \  0: "black"
      \, 1: "red"
      \, 2: "green"
      \, 3: "yellow"
      \, 4: "blue"
      \, 5: "purple"
      \, 6: "cyan"
      \, 7: "white"
      \, 8: "brightBlack"
      \, 9: "brightRed"
      \, 10: "brightGreen"
      \, 11: "brightYellow"
      \, 12: "brightBlue"
      \, 13: "brightPurple"
      \, 14: "brightCyan"
      \, 15: "brightWhite" }
let g:ColorMapping_verityCoralPink_16toHex = g:ColorMapping_verityCoralPink_16toWindowsTerm->copy()->map('g:ColorMapping_verityCoralPink_windowsTerm2hex[v:val]')
let g:colorMapping_256toFullColor_mapping = extend(g:colorMapping_256toFullColor_mapping->copy(), g:ColorMapping_verityCoralPink_16toHex)

highlight TypeUnknown guifg=#f9d17a

" Set SignColumn background color to light gray
" 256 xterm color see: https://www.ditig.com/publications/256-colors-cheat-sheet
" highlight SignColumn ctermbg=0 guibg=#261720
" highlight CocMenuSel ctermfg=152 ctermbg=132 guifg=#AFD7D7 guibg=#afdfdf
" highlight CocFloating ctermfg=96 ctermbg=0 
" highlight Comment term=italic cterm=italic ctermfg=181 guifg=#dfafaf
" highlight Cursor cterm=reverse ctermbg=12 guibg=#7E99E3
" highlight Visual term=reverse cterm=reverse ctermfg=132 ctermbg=123 guibg=DarkGrey
" highlight VertSplit ctermfg=97 ctermbg=0 gui=reverse
" highlight SpecialKey term=bold cterm=bold ctermfg=11 ctermbg=8 guifg=Cyan

" popups
" highlight Pmenu term=italic cterm=italic ctermfg=229 ctermbg=237 guifg=#dfafaf guibg=#54285c
" highlight PmenuSbar term=italic cterm=italic ctermfg=229 ctermbg=240 guifg=#dfafaf guibg=#54285c
" highlight PmenuThumb term=italic cterm=italic ctermfg=229 ctermbg=229 guifg=#dfafaf guibg=#54285c

" tabline hl group w/ airline tabline setting as well
" highlight TabLineSel  term=underline,reverse cterm=underline,reverse ctermfg=131 ctermbg=53 gui=bold
" highlight TabLine term=underline cterm=underline ctermfg=97 ctermbg=0 gui=underline guibg=DarkGrey
" highlight TabLineFill term=underline cterm=underline ctermfg=97 ctermbg=0 gui=reverse
" highlight link airline_tabline TabLine
" highlight link airline_tabline_fill TabLineFill
" highlight link airline_tabline_active TabLineSel
" highlight link airline_tabline_inactive TabLine
" highlight link airline_tabline_separator TabLine

" augroup HITABFILL
"     autocmd!
"     autocmd User AirlineModeChanged highlight airline_warning ctermfg=232 ctermbg=167
"     autocmd User AirlineModeChanged highlight airline_warning_bold ctermfg=232 ctermbg=167
"     autocmd User AirlineModeChanged highlight airline_warning_inactive ctermfg=232 ctermbg=167
"     autocmd User AirlineModeChanged highlight airline_warning_inactive_bold ctermfg=232 ctermbg=167

"     autocmd User AirlineAfterTheme highlight airline_a_inactive ctermfg=232 ctermbg=250
"     autocmd User AirlineAfterTheme highlight link airline_a_inactive_bold airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_a_inactive_red airline_a_inactive

"     autocmd User AirlineAfterTheme highlight link airline_b_inactive airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_b_inactive_bold airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_b_inactive_red airline_a_inactive

"     autocmd User AirlineAfterTheme highlight link airline_c_inactive airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_c_inactive_bold airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_c_inactive_red airline_a_inactive

"     autocmd User AirlineAfterTheme highlight link airline_x_inactive airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_x_inactive_bold airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_x_inactive_red airline_a_inactive

"     autocmd User AirlineAfterTheme highlight link airline_y_inactive airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_y_inactive_bold airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_y_inactive_red airline_a_inactive

"     autocmd User AirlineAfterTheme highlight link airline_z_inactive airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_z_inactive_bold airline_a_inactive
"     autocmd User AirlineAfterTheme highlight link airline_z_inactive_red airline_a_inactive



"     " |AirlineAfterInit|    after plugin is initialized, but before the statusline is replaced
"     " |AirlineAfterTheme|   after theme of the statusline has been changed
"     " |AirlineToggledOn|    after airline is activated and replaced the statusline
"     " |AirlineToggledOff|   after airline is deactivated and the statusline is restored to the original
"     " |AirlineModeChanged|  The mode in Vim changed.
" augroup END