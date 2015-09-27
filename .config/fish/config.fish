#
#                    ╔═╗ ╦ ╔═╗ ╦ ╦    ╔═╗ ╔═╗ ╔╗╔ ╔═╗ ╦ ╔═╗
#                    ╠╣  ║ ╚═╗ ╠═╣    ║   ║ ║ ║║║ ╠╣  ║ ║ ╦
#                    ╚   ╩ ╚═╝ ╩ ╩    ╚═╝ ╚═╝ ╝╚╝ ╚   ╩ ╚═╝
#

# turn off greeting
set fish_greeting

# vim for the win
setenv EDITOR vim


# -- FUNCTIONS

function prompt_pwd --description 'Print the current working directory, NOT shortened to fit the prompt'
    if test "$PWD" != "$HOME"
        printf "%s" (echo $PWD|sed -e 's|/private||' -e "s|^$HOME|~|")
    else
        echo '~'
    end
end


# -- ALIASES

function ls --description 'List colored contents of directory'
    set -l param --human-readable --group-directories-first --color=auto
    if isatty 1
        set param $param --indicator-style=classify
    end
    command ls $param $argv
end

function svim --description "Alias: sudo vim [args]"
    sudo vim $argv
end


# -- PROMPT

function fish_prompt --description 'Write out the prompt'

    # Just calculate these once, to save a few cycles when displaying the prompt
    if not set -q __fish_prompt_hostname
        set -g __fish_prompt_hostname (hostname|cut -d . -f 1)
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
            echo -n -s "$__fish_prompt_normal" ' :: '
            echo -n -s "$__fish_prompt_cwd" (prompt_pwd)
            echo
            echo -n -s "$__fish_prompt_normal" '> '
    end
end


# start X at login
if status --is-login
    if test -z "$DISPLAY" -a $XDG_VTNR = 1
        exec startx -- -keeptty
    end
end

