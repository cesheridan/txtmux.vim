_( tabwins x textwins ) multiplexer_ / Charles Sheridan

# _txtmux.vim_

[tabs]: ./doc_graphics/gif/txtmux_tabs.gif?raw=true  "tabs"
![alt text][tabs]

_**txtmux.vim is son of tabwins.vim & textwins.vim**, a TxT Multiplex -- Vim TNT!_, the fortuitous factorial of window and text multiplexing.

_**txtmux is MUXTING**_, the multiplexing of texting across windows, combined with the multiplexing of windows within and across tabs.

* **SEE tabwins.vim documentation** about the ways to create persistent window structures with 1 command.

* **SEE textwins.vim documentation** about termwins, editwins, and the concept of windows texting to each of other as peers, in point-to-point relationships distinct from muxting's point-to-multipoint.

Each of these plugins is **requisite** for _txtmux.vim_
___

## txtmuxD Demo Menu
![alt text][txtmux_txt]
[txtmux_txt]: ./doc_graphics/images/txtmuxD_TxT.jpg?raw=true  "txtmux_txt"

![alt text][txtmux_menu]
[txtmux_menu]: ./doc_graphics/images/txtmuxD_muxt.jpg?raw=true  "txtmux_menu"

The demo contains only a few of the commands in this plugin.  The _**developer is encouraged to customize**_ this menu for local use, by updating **menu_build()** and adding custom custom tabs that call :Tabwins, :TabwinsVertical, & :TabwinsHorizontal.  The demo commands call textwins.vim command :TermwinCreateSelfwin to build termwins. 

Global **g:load_txtmux_menu_is_wanted** default is **'Y'** and can be set to 'N' to turn off this menu.

Global **g:txtmux_menu_number** default is **9996** and can be updated.

See the _textwins.vim_ 'VERTICAL & HORIZONTAL' section re the naming syntax used in this menu. Also, the 'B's refer to a window being added to the bottom of the tab, and the 'L's refer to a window added at the left.

# COMMANDS
![alt text][ls_after_garbaj]
[ls_after_garbaj]: ./doc_graphics/gif/ls_after_garbaj.gif?raw=true  "ls_after_garbaj"
_sequence: cd to /usr/local/bin, garbled cmd line, clean it, run `ls` -- all via :MuxtExArgs cmds_

Command **scope** is the current tab, except for some of the exit commands, which encompass all tabs.  

Muxting commands start at the lowest applicable window number and move incrementaly to higher window numbers, & **finish execution by returning to the window that invokes the command.** 

Muxting occurs whether a termwin is in NORMAL or TERMINAL-Job mode.

On a per-command basis, **muxting defaults can be overridden** via 'rcvd_hash' in calls to function **Muxter(count_prefix, rcvd_hash)**, invoked from all muxting commands.  

Termwins that invoke muxting commands are **configured to NOT run the command on themselves.**  This can be overridden via Muxter() arg 'muxt_to_selfwin_is_wanted' 

#### Muxt Copied Text to Termwins
| FORM | :Ex Command |  nmap  |  vmap | Description |
| :--- |  :--- | --- | --- | --- |
| **:Muxt{}2{....}wins** |:Muxt2Termwins | mt**t** | mt**t** |Muxt **yank register or visual selection** of buffer of current editwin 
|  |:Muxt**ll**2Termwins | mf**l** | mf**l**|Muxt & **`ll`** yank register or visual selection
|  |:Muxt**Source**2Termwins | mf**s**| mf**s**|Muxt & **`source`** yank register or visual selection 
|  |:Muxt**Run**2Termwins | mf**r**| mf**r**|Muxt & **Run** yank register or visual selection 

#### Muxt Current Line to Termwins
| FORM | :Ex Command |  nmap  |  vmap | Description |
| :--- |  :--- | --- | --- | --- |
| **:Muxt{}2{....}wins** |:Muxtyy2Termwins | m**yy**t | m**yy**t |Muxt **current line** |

#### Muxt Filepath of Current Editwin to Termwins
Filepath muxting, as well as its sourcing and execution.

| FORM | :Ex Command |  nmap  |  vmap | Description |
| :--- |  :--- | --- | --- | --- |
| **:MuxtFilepath{}2{....}wins** |:MuxtFilepath2Termwins | mf**t** | mf**t** |Mux**t** **Filepath** of buffer of current editwin 
|  |:MuxtFilepath**ll**2Termwins | mf**l** | mf**l**|Muxt & `ll` **Filepath** of buffer of current editwin
|  |:MuxtFilepath**Source**2Termwins | mf**s**| mf**s**|Muxt & **`source` Filepath** of buffer of current editwin 
|  |:MuxtFilepath**Run**2Termwins | mf**r**| mf**r**|Muxt & **Run Filepath** of buffer of current editwin 

#### Muxt `make` to Termwins
| FORM | :Ex Command |  nmap  |  vmap | Description |
| :--- |  :--- | --- | --- | --- |
| **:Muxt{}2Termwins** |:Muxt**Make**2Termwins | mma | mma  |Muxt & run **`make`** |

#### Muxt :Ex Line Args to Termwins
| FORM | :Ex Command | Description |
| :--- |  :--- | --- | --- | 
| **:Muxt{}2Termwins** |:Muxt**ExArgs**2Termwins  |Muxt **:Ex Line Args** |
|  |:Muxt**ExArgsRun**2Termwins  |Muxt & Run **:Ex Line Args** |


## Termwins Control 
![alt text][halt_du_from_root]
[halt_du_from_root]: ./doc_graphics/gif/halt_du_from_root.gif?raw=true  "halt_du_from_root"
_sequence: cd to root, run `du`, decide it's too much screen data, halt output via CNTL-C_

'clean-up' termwin command lines before muxting commands.

| FORM | :Ex Command |  nmap  | Description |
| :--- |  :--- | --- | --- | --- |
| **:Muxt{..}2{....}wins** |:Muxt**CR**2**Term**wins  |m**CR**  |  Muxt **Carriage Returns** | 
|  |:Muxt**SP**2**Term**wins  |m**SP**    |Muxt **SPace** Chars | 
|  |:Muxt**CC**2**Term**wins  |m**CC**    |Muxt **Cntl-Cs** | 
|  |:Muxt**CU**2**Term**wins  |m**CU**    |Muxt **Cntl-Us**  to **delete chars to left** of cursors| 
|  |:Muxt**Job**2**Term**wins  |m**jo**   |Muxt **Terminal JOb** modes| 

## Wintype Conversion

[converts]: ./doc_graphics/gif/converts.gif?raw=true  "converts"
![alt text][converts]

**Use case**: a developer completes a period of interaction with termwins(editwins) and converts them to editwins(termwins). 

| FORM | :Ex Command |  nmap | Description | 
| :--- |  :--- | --- | --- | --- |
| **:ConvertTab{}{....}wins2{....}wins ** |:ConvertTab**Term**wins2**Edit**wins   |**T2e**  |   Convert this tab's **termwins to editwins**|
|  |   |**t2e**  |   name replaced by `T2e` in release 1.1.0|
| |:ConvertTab**OtherTerm**wins2**Edit**wins   |**t2e**  |   Convert the other **termwins in this tab to editwins** i.e. excludes the window that invokes the command|
|  |   |**o2e**  |   name replaced by `t2e` in release 1.1.0|
| |:ConvertTab**Edit**wins2**Term**wins   |**e2t**  |   Convert this tab's **editwins to termwins**|
| |:ConvertTab**OtherEdit**wins2**Term**wins   |**o2t**  |   Convert the other **editwins in this tab to termwins** i.e. excludes the window that invokes the command|

Replaced buffers remain in the buffer list.

Windows that are _neither editwins nor termwins_, e.g. QuickFix & Help windows, remain as they are.

Note that if a session creates a large number of Vim terminals, approximately 60 or more, new Vim terminals might not be functional -- there seems to be a limit to the number of open terminals that Vim8 supports.

## Muxt Wintype Exits

**Use case** for several of these commands: a developer completes a period of interaction with termwins(editwins) and removes them, while preserving the editwins(termwins).

:quit of a Vim8 :terminal prompts for confirmation -- _**termwin quits use :quit! to bypass confirmation**_.

| FORM | :Ex Command |  nmap  |  Description | 
| :--- |  :--- | --- | --- | --- |
|  |:Quit**TabTerm**wins  |q**Tt**  |    **:quit!** this Tab's Termwins|
|  |:Quit**AllTerm**wins  |q**at**  |    **:quit!** ALL Termwins|
|  |:Quit**TabEdit**wins  |q**Te**  |    **:quit!** this Tab's Editwins|
|  |:Quit**AllEdit**wins  |q**ae**  |    **:quit!** ALL Editwins|
| **:Quit{..}AndWithForceIfTermwin**  |:Quit**Tab**AndWithForceIfTermwin    | q**TT** |    **:quit** ALL windows in current tab(includes quickfix & help windows) & quit! ALL termwins in this tab.  
|| Quit**All**AndWithForceIfTermwin    | q**aa** |    **:quit** ALL non-termwin windows (includes quickfix & help windows) & quit! ALL termwins, across ALL tabs.  Equivalent to a Vim :qa which also quits all termwins with force. |


#### MNEMONICS
* _txtmux.vim_ follows the mnemonics conventions of _textwins.vim_, and adds 'm' for 'Muxt'

#### _textwins.vim_ & Vim
_This plugin:_
* Requires Vim8, the first Vim release with terminals
* Neither writes to Vim global vars nor changes Vim configurations


#### REQUISITE PLUGINS
*  _**textwins.vim** Windows that text_
  https://raw.githubusercontent.com/cesheridan/textwins.vim/master/README.md

*  _**tabwins.vim** 1 command for custom window structures that persist_
  https://raw.githubusercontent.com/cesheridan/tabwins.vim/master/README.md

#### RECOMMENDED PLUGIN
*  _**streamline.vim** Essential wares, to get there_
  https://raw.githubusercontent.com/cesheridan/streamline.vim/master/README.md

#### DISTRIBUTION
* https://vim.sourceforge.io/scripts/script.php?script_id=5662
* Includes release history 

#### DOCUMENTATION
* https://raw.githubusercontent.com/cesheridan/txtmux.vim/master/README.md

#### DEPLOYMENT
_txtmux.vim_ has the dependencies listed in REQUISITE PLUGINS. 

The .tgz decompresses to ./plugin & ./doc dirs compatible with established Vim package managers. 

#### LICENSE 
License: GPL (Gnu Public License) version 3
Copyright (c) 2018 Charles E. Sheridan
