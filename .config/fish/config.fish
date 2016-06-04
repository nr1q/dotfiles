set fish_greeting

setenv EDITOR vim
setenv LANG en_US.UTF-8
setenv GPG_TTY (tty)

# FUNCTIONS {{{

function fish_colors --description 'Set my custom fish colors'
    set fish_color_autosuggestion  ffffff
    set fish_color_command         696969
    set fish_color_param           b2b2b2
    set fish_color_comment         87d700
    set fish_color_cwd             green
    set fish_color_cwd_root        red
    set fish_color_end             ff0
    set fish_color_error           ff8700
    set fish_color_escape          cyan
    set fish_color_history_current cyan
    set fish_color_host            cyan --bold
    set fish_color_match           cyan
    set fish_color_normal          normal
    set fish_color_operator        ffd700 --bold
    set fish_color_quote           ffffff
    set fish_color_redirection     0087ff
    # https://github.com/fish-shell/fish-shell/issues/2442
    #set fish_color_search_match    af0000 --bold --background=ff5f00
    set fish_color_search_match    --background=ff5f00
    set fish_color_status          red
    set fish_color_user            green --bold
    set fish_color_valid_path      ffffff --underline
end

function prompt_pwd --description 'Print the current working directory, NOT shortened to fit the prompt'
    if test "$PWD" != "$HOME"
        printf "%s" (echo $PWD|sed -e 's|/private||' -e "s|^$HOME|~|")
    else
        echo '~'
    end
end

# Use $EDITOR to edit the current command
function edit_commandline --description "Edit the current command in your $EDITOR"
    set -q EDITOR; or return 1
    set -l tmpfile (mktemp -t "edit_commandline.XXX"); or return 1
    commandline > $tmpfile
    eval $EDITOR $tmpfile
    commandline -r -- (cat $tmpfile)
    rm $tmpfile
end
bind \ee edit_commandline

# }}}

# ALIASES & ABBREVIATIONS {{{

abbr gcm 'git commit'
abbr gco 'git checkout'
abbr gd 'git diff'
abbr gs 'git status'
abbr gt 'git tree'

abbr se sudoedit
abbr v vim
abbr vd vimdiff
abbr vup 'vagrant up'
abbr vht 'vagrant halt'
abbr vre 'vagrant reload'
abbr vss 'vagrant ssh'
abbr vsu 'vagrant suspend'

# ranger with image preview (non-ascii)
alias iranger 'ranger --cmd="set preview_images true"'

function cranger --description 'Keep last directory on exit'
    set -l tempfile '/tmp/ranger-choosedir'
    /usr/bin/ranger --choosedir=/tmp/ranger-choosedir
    if test -f $tempfile; and test (cat $tempfile) != (echo -n (pwd))
        cd (cat $tempfile)
    end
    rm $tempfile
end

function ls --description 'List colored contents of directory'
    set -l param --human-readable --group-directories-first --color=auto
    if isatty 1
        set param $param --indicator-style=classify
    end
    command ls $param $argv
end

# }}}

# PROMPT {{{

function fish_prompt --description 'Write out the prompt'
    set -l git_branch ''
    if git rev-parse ^/dev/null
        set git_branch  " " (git branch ^/dev/null | sed -n '/\* /s///p') " "
    end

    # Just calculate these once, to save a few cycles when displaying the prompt
    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (hostname | cut -d . -f 1)
    end

    if not set -q __fish_prompt_normal
        set -g __fish_prompt_normal (set_color normal)
    end

    if not set -q __fish_prompt_bold
        set -g __fish_prompt_bold (set_color --bold white)
    end

    switch $USER
        case root
            if not set -q __fish_prompt_cwd
                if set -q fish_color_cwd_root
                    set -g __fish_prompt_cwd (set_color $fish_color_cwd_root)
                else
                    set -g __fish_prompt_cwd (set_color $fish_color_cwd)
                end
            end

            #echo "$USER" at "$__fish_prompt_hostname" in "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal"
            echo "$USER" :: "$__fish_prompt_cwd" (prompt_pwd) "$__fish_prompt_normal"
            echo -n -s'# '

        case '*'
            if not set -q __fish_prompt_cwd
                set -g __fish_prompt_cwd (set_color --bold $fish_color_cwd)
            end

            echo -n -s (set_color --bold fff) "$USER"
            echo -n -s "$__fish_prompt_normal" " :$__fish_prompt_hostname: "
            echo -n -s (set_color yellow) $git_branch
            echo -n -s "$__fish_prompt_cwd" (prompt_pwd)
            echo
            echo -n -s "$__fish_prompt_normal" '> '
    end
end

# }}}

# start X at login
if status --is-login
    if test -z "$DISPLAY" -a $XDG_VTNR -eq 1
        exec startx -- -keeptty
    end
end

# vim:foldmethod=marker:foldlevel=0
