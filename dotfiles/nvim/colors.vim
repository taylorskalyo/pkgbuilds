" Theme based on base16
" https://github.com/chriskempson/base16-vim

"if &background ==# 'dark'
"  let s:base00 = '00'
"  let s:base01 = '10'
"  let s:base02 = '11'
"  let s:base03 = '08'
"  let s:base04 = '12'
"  let s:base05 = '07'
"  let s:base06 = '13'
"  let s:base07 = '15'
"else
"  let s:base00 = '15'
"  let s:base01 = '13'
"  let s:base02 = '07'
"  let s:base03 = '12'
"  let s:base04 = '08'
"  let s:base05 = '11'
"  let s:base06 = '10'
"  let s:base07 = '00'
"endif
let s:base00 = '00'
let s:base01 = '10'
let s:base02 = '11'
let s:base03 = '08'
let s:base04 = '12'
let s:base05 = '07'
let s:base06 = '13'
let s:base07 = '15'

" Colors
let s:base08 = '01'
let s:base09 = '09'
let s:base0A = '03'
let s:base0B = '02'
let s:base0C = '06'
let s:base0D = '04'
let s:base0E = '05'
let s:base0F = '14'

" Theme setup
hi clear
syntax reset
let g:colors_name = 'terminal'

" Highlighting function
fun <sid>hi(group, ctermfg, ctermbg, attr)
  if a:ctermfg !=# ''
    exec 'hi ' . a:group . ' ctermfg=' . a:ctermfg
  endif
  if a:ctermbg !=# ''
    exec 'hi ' . a:group . ' ctermbg=' . a:ctermbg
  endif
  if a:attr !=# ''
    exec 'hi ' . a:group . ' cterm=' . a:attr
  endif
endfun

" Vim editor colors
call <sid>hi('Bold',          '', '', 'bold')
call <sid>hi('Debug',         s:base08, '', '')
call <sid>hi('Directory',     s:base0D, '', '')
call <sid>hi('Error',         s:base00, s:base08, '')
call <sid>hi('ErrorMsg',      s:base08, s:base00, '')
call <sid>hi('Exception',     s:base08, '', '')
call <sid>hi('FoldColumn',    s:base0C, s:base01, '')
call <sid>hi('Folded',        s:base03, s:base01, '')
call <sid>hi('IncSearch',     s:base01, s:base0A, 'none')
call <sid>hi('Italic',        '', '', 'italic')
call <sid>hi('Macro',         s:base08, '', '')
call <sid>hi('MatchParen',    s:base00, s:base03,  '')
call <sid>hi('ModeMsg',       s:base0B, '', '')
call <sid>hi('MoreMsg',       s:base0B, '', '')
call <sid>hi('Question',      s:base0B, '', '')
call <sid>hi('Search',        s:base00, s:base0A,  '')
call <sid>hi('SpecialKey',    s:base02, '', '')
call <sid>hi('TooLong',       s:base08, '', '')
call <sid>hi('Underlined',    s:base08, '', '')
call <sid>hi('Visual',        '', s:base02, '')
call <sid>hi('VisualNOS',     s:base08, '', '')
call <sid>hi('WarningMsg',    s:base08, '', '')
call <sid>hi('WildMenu',      s:base08, '', '')
call <sid>hi('Title',         s:base07, '', 'none')
call <sid>hi('Conceal',       s:base0D, s:base00, '')
call <sid>hi('Cursor',        s:base00, s:base05, '')
call <sid>hi('NonText',       s:base02, '', '')
call <sid>hi('Normal',        s:base05, s:base00, '')
call <sid>hi('LineNr',        s:base02, s:base00, '')
call <sid>hi('SignColumn',    s:base0A, s:base01, '')
call <sid>hi('StatusLine',    s:base04, s:base02, 'none')
call <sid>hi('StatusLineNC',  s:base03, s:base01, 'none')
call <sid>hi('VertSplit',     s:base02, s:base00, 'none')
call <sid>hi('ColorColumn',   '', s:base01, 'none')
call <sid>hi('CursorColumn',  '', s:base01, 'none')
call <sid>hi('CursorLine',    '', s:base01, 'none')
call <sid>hi('CursorLineNr',  s:base03, s:base01, '')
call <sid>hi('PMenu',         s:base04, s:base01, 'none')
call <sid>hi('PMenuSel',      s:base01, s:base04, '')
call <sid>hi('TabLine',       s:base03, s:base01, 'none')
call <sid>hi('TabLineFill',   s:base03, s:base01, 'none')
call <sid>hi('TabLineSel',    s:base0B, s:base01, 'none')
call <sid>hi('Whitespace',    s:base02, '', 'none')

" Standard syntax highlighting
call <sid>hi('Boolean',      s:base09, '', '')
call <sid>hi('Character',    s:base08, '', '')
call <sid>hi('Comment',      s:base03, '', '')
call <sid>hi('Conditional',  s:base05, '', '')
call <sid>hi('Constant',     s:base09, '', '')
call <sid>hi('Define',       s:base0E, '', 'none')
call <sid>hi('Delimiter',    s:base0C, '', '')
call <sid>hi('Float',        s:base09, '', '')
call <sid>hi('Function',     s:base0D, '', '')
call <sid>hi('Identifier',   s:base08, '', 'none')
call <sid>hi('Include',      s:base0D, '', '')
call <sid>hi('Keyword',      s:base0A, '', '')
call <sid>hi('Label',        s:base0A, '', '')
call <sid>hi('Number',       s:base09, '', '')
call <sid>hi('Operator',     s:base05, '', 'none')
call <sid>hi('PreProc',      s:base0E, '', '')
call <sid>hi('Repeat',       s:base05, '', '')
call <sid>hi('Special',      s:base05, '', '')
call <sid>hi('SpecialChar',  s:base0F, '', '')
call <sid>hi('Statement',    s:base05, '', '')
call <sid>hi('StorageClass', s:base0A, '', '')
call <sid>hi('String',       s:base0B, '', '')
call <sid>hi('Structure',    s:base0E, '', '')
call <sid>hi('Tag',          s:base0A, '', '')
call <sid>hi('Todo',         s:base01, s:base03, '')
call <sid>hi('Type',         s:base0D, '', 'none')
call <sid>hi('Typedef',      s:base0A, '', '')

" C highlighting
call <sid>hi('cType',         s:base0A, '', '')
call <sid>hi('cStorageClass', s:base0E, '', '')
call <sid>hi('cConditional',  s:base0E, '', '')
call <sid>hi('cRepeat',       s:base0E, '', '')

" C# highlighting
call <sid>hi('csClass',                 s:base0A, '', '')
call <sid>hi('csAttribute',             s:base0A, '', '')
call <sid>hi('csModifier',              s:base0E, '', '')
call <sid>hi('csType',                  s:base08, '', '')
call <sid>hi('csUnspecifiedStatement',  s:base0D, '', '')
call <sid>hi('csContextualStatement',   s:base0E, '', '')
call <sid>hi('csNewDecleration',        s:base08, '', '')

" CSS highlighting
call <sid>hi('cssBraces',      s:base05, '', '')
call <sid>hi('cssClassName',   s:base0E, '', '')
call <sid>hi('cssColor',       s:base0C, '', '')

" Diff highlighting
"call <sid>hi('DiffAdd',       s:base0B, s:base01, '')
call <sid>hi('DiffAdd',       '', s:base01, '')
call <sid>hi('DiffChange',    s:base03, s:base01, '')
call <sid>hi('DiffDelete',    s:base08, s:base01, '')
call <sid>hi('DiffText',      s:base0D, s:base01, '')
call <sid>hi('DiffAdded',     s:base0B, s:base00, '')
call <sid>hi('DiffFile',      s:base08, s:base00, '')
call <sid>hi('DiffNewFile',   s:base0B, s:base00, '')
call <sid>hi('DiffLine',      s:base0D, s:base00, '')
call <sid>hi('DiffRemoved',   s:base08, s:base00, '')

" Git highlighting
call <sid>hi('diffAdded',          s:base0B, '', '')
call <sid>hi('diffRemoved',        s:base08, '', '')
call <sid>hi('gitcommitSummary',   '', '', 'bold')
call <sid>hi('gitCommitOverflow',  s:base08, '', '')
call <sid>hi('gitCommitSummary',   s:base0B, '', '')

" GitGutter highlighting
call <sid>hi('GitGutterAdd',     s:base0B, s:base01, '')
call <sid>hi('GitGutterChange',  s:base0D, s:base01, '')
call <sid>hi('GitGutterDelete',  s:base08, s:base01, '')
call <sid>hi('GitGutterChangeDelete',  s:base0E, s:base01, '')

" HTML highlighting
call <sid>hi('htmlBold',    s:base0A, '', 'bold')
call <sid>hi('htmlItalic',  s:base0E, '', 'italic')
call <sid>hi('htmlEndTag',  s:base05, '', '')
call <sid>hi('htmlTag',     s:base05, '', '')

" JavaScript highlighting
call <sid>hi('javaScript',        s:base05, '', '')
call <sid>hi('javaScriptBraces',  s:base05, '', '')
call <sid>hi('javaScriptNumber',  s:base09, '', '')

" Mail highlighting
call <sid>hi('mailQuoted1',  s:base0A, '', '')
call <sid>hi('mailQuoted2',  s:base0B, '', '')
call <sid>hi('mailQuoted3',  s:base0E, '', '')
call <sid>hi('mailQuoted4',  s:base0C, '', '')
call <sid>hi('mailQuoted5',  s:base0D, '', '')
call <sid>hi('mailQuoted6',  s:base0A, '', '')
call <sid>hi('mailURL',      s:base0D, '', '')
call <sid>hi('mailEmail',    s:base0D, '', '')

" Markdown highlighting
call <sid>hi('markdownCode',              s:base0B, '', '')
call <sid>hi('markdownError',             s:base05, s:base00, '')
call <sid>hi('markdownCodeBlock',         s:base0B, '', '')
call <sid>hi('markdownHeadingDelimiter',  s:base0D, '', '')
call <sid>hi('markdownH1',                s:base07, '', 'bold')
call <sid>hi('markdownH2',                s:base06, '', 'bold')
call <sid>hi('markdownH3',                s:base05, '', 'bold')
call <sid>hi('markdownH4',                s:base04, '', 'bold')
call <sid>hi('markdownH5',                s:base03, '', 'bold')
call <sid>hi('markdownListMarker',        s:base05, '', '')

" Vimwiki highlighting
call <sid>hi('VimwikiHeaderChar',  s:base0D, '', '')
call <sid>hi('VimwikiHeader1',     s:base07, '', 'bold')
call <sid>hi('VimwikiHeader2',     s:base06, '', 'bold')
call <sid>hi('VimwikiHeader3',     s:base05, '', 'bold')
call <sid>hi('VimwikiHeader4',     s:base04, '', 'bold')
call <sid>hi('VimwikiHeader5',     s:base03, '', 'bold')
call <sid>hi('VimwikiPre',         s:base0B, '', '')
call <sid>hi('VimwikiCode',        s:base0B, '', '')
call <sid>hi('VimwikiListTodo',    s:base05, '', '')

" NERDTree highlighting
call <sid>hi('NERDTreeDirSlash',  s:base0D, '', '')
call <sid>hi('NERDTreeExecFile',  s:base05, '', '')

" PHP highlighting
call <sid>hi('phpVarSelector',    s:base08, '', '')
call <sid>hi('phpKeyword',        s:base0E, '', '')
call <sid>hi('phpRepeat',         s:base0E, '', '')
call <sid>hi('phpConditional',    s:base0E, '', '')
call <sid>hi('phpStatement',      s:base0E, '', '')
call <sid>hi('phpMemberSelector', s:base05, '', '')

" Python highlighting
call <sid>hi('pythonInclude',     s:base0E, '', '')
call <sid>hi('pythonStatement',   s:base0E, '', '')
call <sid>hi('pythonConditional', s:base0E, '', '')
call <sid>hi('pythonRepeat',      s:base0E, '', '')
call <sid>hi('pythonException',   s:base0E, '', '')
call <sid>hi('pythonFunction',    s:base0D, '', '')
call <sid>hi('pythonPreCondit',   s:base0E, '', '')
call <sid>hi('pythonRepeat',      s:base0C, '', '')
call <sid>hi('pythonExClass',     s:base0A, '', '')

" Ruby highlighting
call <sid>hi('rubySymbol',                 s:base0B, '', '')
call <sid>hi('rubyConstant',               s:base0A, '', '')
call <sid>hi('rubyAccess',                 s:base0A, '', '')
call <sid>hi('rubyAttribute',              s:base0D, '', '')
call <sid>hi('rubyInclude',                s:base0D, '', '')
call <sid>hi('rubyLocalVariableOrMethod',  s:base0A, '', '')
call <sid>hi('rubyCurlyBlock',             s:base0A, '', '')
call <sid>hi('rubyStringDelimiter',        s:base0B, '', '')
call <sid>hi('rubyInterpolationDelimiter', s:base0A, '', '')
call <sid>hi('rubyConditional',            s:base0E, '', '')
call <sid>hi('rubyRepeat',                 s:base0E, '', '')
call <sid>hi('rubyControl',                s:base0E, '', '')
call <sid>hi('rubyException',              s:base0E, '', '')

" Crystal highlighting
call <sid>hi('crystalSymbol',                 s:base0B, '', '')
call <sid>hi('crystalConstant',               s:base0A, '', '')
call <sid>hi('crystalAccess',                 s:base0A, '', '')
call <sid>hi('crystalAttribute',              s:base0D, '', '')
call <sid>hi('crystalInclude',                s:base0D, '', '')
call <sid>hi('crystalLocalVariableOrMethod',  s:base0A, '', '')
call <sid>hi('crystalCurlyBlock',             s:base0A, '', '')
call <sid>hi('crystalStringDelimiter',        s:base0B, '', '')
call <sid>hi('crystalInterpolationDelim',     s:base0A, '', '')
call <sid>hi('crystalConditional',            s:base0E, '', '')
call <sid>hi('crystalRepeat',                 s:base0E, '', '')
call <sid>hi('crystalControl',                s:base0E, '', '')
call <sid>hi('crystalException',              s:base0E, '', '')

" SASS highlighting
call <sid>hi('sassidChar',     s:base08, '', '')
call <sid>hi('sassClassChar',  s:base09, '', '')
call <sid>hi('sassInclude',    s:base0E, '', '')
call <sid>hi('sassMixing',     s:base0E, '', '')
call <sid>hi('sassMixinName',  s:base0D, '', '')

" Signify highlighting
call <sid>hi('SignifySignAdd',     s:base0B, s:base01, '')
call <sid>hi('SignifySignChange',  s:base0D, s:base01, '')
call <sid>hi('SignifySignDelete',  s:base08, s:base01, '')

" Spelling highlighting
call <sid>hi('SpellBad',     '', s:base00, 'undercurl')
call <sid>hi('SpellLocal',   '', s:base00, 'undercurl')
call <sid>hi('SpellCap',     '', s:base00, 'undercurl')
call <sid>hi('SpellRare',    '', s:base00, 'undercurl')

" ALE highlighting
call <sid>hi('ALEErrorSign',   s:base01, s:base08, '')
call <sid>hi('ALEWarningSign', s:base0A, s:base01, '')

" LSP highlighting
call <sid>hi('LspDiagnosticsDefaultError', s:base08, '', 'bold')
call <sid>hi('LspDiagnosticsDefaultWarning', s:base09, '', 'bold')
"call <sid>hi('LspDiagnosticsDefaultInformation', s:base07, '', 'bold')
call <sid>hi('LspDiagnosticsDefaultHint', s:base0A, '', 'bold')

" Leading Space
"call <sid>hi('WhiteSpaceBol', s:base02, s:base00, '')
"call <sid>hi('WhiteSpaceMol', s:base00, s:base00, '')

" Indentline highlighting
call <sid>hi('IndentBlanklineChar', s:base01, '', '')
call <sid>hi('IndentBlanklineContextChar', s:base01, '', '')

" Remove functions
delf <sid>hi

" Remove color variables
unlet s:base00 s:base01 s:base02 s:base03 s:base04 s:base05 s:base06 s:base07 s:base08 s:base09 s:base0A s:base0B s:base0C s:base0D s:base0E s:base0F
