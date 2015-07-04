#brightest.vim

カーソル下の単語を移動するたびにハイライトする。

## Screencapture

![brightest](https://cloud.githubusercontent.com/assets/214488/3297888/eb37a8dc-f5f9-11e3-8620-5876f030d762.gif)

## Using

```vim
" ハイライトを有効にします（既定値）
BrightestEnable

" ハイライトを無効にします
BrightestDisable

" ハイライトするグループ名を設定します
" アンダーラインで表示する
let g:brightest#highlight = {
\   "group" : "BrightestUnderline"
\}

" ハイライトする単語のパターンを設定します
" デフォルト（空の文字列の場合）は <cword> が使用されます
let g:brightest#pattern = '\k\+'


" filetype=cpp を無効にする
let g:brightest#enable_filetypes = {
\	"cpp" : 0
\}

" filetype=vim のみを有効にする
let g:brightest#enable_filetypes = {
\	"_"   : 0,
\	"vim" : 1,
\}
```


