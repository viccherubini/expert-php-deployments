## General Aliases ##
alias ls='ls -laF --color=auto --group-directories-first'
alias grep='grep --color=auto'

## Application Management ##
alias goapps='cd /srv/http/apps/'

## Navigation ##
function .. () {
    local arg=${1:-1};
    local dir=""
    while [ $arg -gt 0 ]; do
        dir="../$dir"
        arg=$(($arg - 1));
    done
    cd $dir && ls
}

## Git Short Aliases ##
function gitroot {
    cwd=`pwd`
    while [ ! -d ".git" ]; do
        pwd=`pwd`
        if [ $pwd == "/" ]; then
            echo "Could not find .git directory, keeping you in $cwd"
            cd $cwd
            break
        fi
    cd ..
    done
}

alias a='git add'
alias ci='git commit'
alias co='git checkout'
alias d='git diff'
alias s='git status'

if [ -f ~/.bash_envvars ]; then
    . ~/.bash_envvars
fi
