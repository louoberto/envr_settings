#==============================================================================
# Prompt
#==============================================================================
export prompt='[%n@%m %c02]$ '

if [ "$OS" == "Windows_NT" ] ; then
    hname=$(HOSTNAME)
    num_cores=$(grep -c ^processor /proc/cpuinfo) # Get the number of processing cores
    if [ -z "$num_cores" ]; then
        num_cores=$(cat /proc/cpuinfo | grep processor | wc -l) # Get the number of processing cores
    fi
    export PS1='\[\e[36m\]\u@\h.\[\e[32m\]${num_cores} \[\e[33m\]\w\[\e[0m\] $? \n> '
else
    if [[ $(uname) == "Darwin" ]]; then
        num_cores=$(sysctl -n hw.ncpu)  # macOS equivalent for number of processing cores
    else
        num_cores=$(nproc)  # Linux command
    fi
    export PS1='\[\e]0;\h:\w\a\]\n\[\e[36m\]\u@\h.\[\e[32m\]${num_cores} \[\e[33m\]\w\[\e[0m\] $? \n> '
fi
export PS4=':${BASH_SOURCE}:${LINENO}+'
#==============================================================================

#==============================================================================
# Some login info
#==============================================================================
# vsce login LouOberto; AESVTcpmdOwBpNsi4zcF4mgW98NoEdX0uaA8QuANtKFm2J3yrK9uJQQJ99BAACAAAAAAAAAAAAASAZDOZcws
umask 022   #Used for setting file priveleges for files I create (I can write, others can read)
alias u='cd ..'
alias mc='mv'
alias clu="fortify"
alias rpi="ssh louoberto@192.168.1.155"
alias python='python3'
export PATH="~/tools/fortify/source:$PATH"
export PATH="~/miniconda3/condabin/:$PATH"
if [ "$OS" == "Windows_NT" ]; then
    alias ls='ls -aB --color --group-directories-first'
    alias lou="cd ~/tools;"
    cd ~/tools 2>/dev/null || true
elif [[ $(uname) == "Darwin" ]]; then
    alias ls='ls -aB --color'
    export BASH_SILENCE_DEPRECATION_WARNING=1
    export PATH=/Library/Frameworks/Python.framework/Versions/Current/bin:$PATH
    export PATH=/usr/local/texlive/2024/bin/universal-darwin:$PATH
    export PATH="$PATH:/opt/homebrew/bin"
    ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
elif [[ $(uname) == "Linux" ]]; then
    alias ls='ls -aB --color --group-directories-first'
    export PATH="$PATH:/usr/local/bin:/usr/bin:/bin"
    ulimit -s unlimited
fi

if [ -f "$(dirname "${BASH_SOURCE[0]}")/../.bash_login" ]; then
    source "$(dirname "${BASH_SOURCE[0]}")/../.bash_login"
fi
#==============================================================================

#==============================================================================
# Custom commands
#==============================================================================
run(){
    the_cmd="$@"
    echo 'How many times to run?'
    read itrs
    for ((i=0;i<$itrs;i++)); do $the_cmd; done
}
#------------------------------------------------------------------------------
gadd(){
    git add "$@"
}
gpush(){
    git commit -m "$1"
    git push
}
#------------------------------------------------------------------------------
f(){
    fcmd="find . -name *$1*" # -not -name '*.o'"
    ${fcmd}
}
#------------------------------------------------------------------------------
frm(){
    for f in $(find . -type f -name '*libifcore*'); do
    rm -f "$f"
    done
}
#------------------------------------------------------------------------------
g(){
    # Enter the directories you wish to exclude
    xdir=(
        \*docs\*
        \*.git\*
    )
    # Enter the files you wish to exclude
    xfil=(
        '*.o'
        '*~'
        #'*log'
    )
    # Create string for Grep cmd for these
    exclu=""
    for edir in "${xdir[@]}"
    do
        exclu="${exclu}--exclude-dir=${edir} "
    done
    for efil in "${xfil[@]}"
    do
        exclu="${exclu}--exclude=${efil} "
    done
    gcmd="grep -irnI $exclu--color"
    # Call the string and enter the file
    if [ "$OS" == "Windows_NT" ] ; then
        ${gcmd} "$1" ./
    else
        ${gcmd} "$1"
    fi
}
#------------------------------------------------------------------------------
what() {
    if [[ $# -eq 0 ]]; then
        echo "Usage: what <file>" >&2
        return 1
    fi

    for file in "$@"; do
        if [[ ! -f "$file" ]]; then
            echo "what: $file: No such file" >&2
            continue
        fi

        echo "$file:"
        strings "$file" | grep -o '@(#).*' || echo "No what strings found."
    done
}
#------------------------------------------------------------------------------
ctex(){
    # Store tex filename
    theFile=$1
    # Check if the given file is tex
    if [ $(echo ${theFile} | tail -c 4) == "tex" ]; then
        if [ "$OS" == "Windows_NT" ]; then
            taskkill //im FoxitPDFReader.exe # If so, kill FoxitPDFReader so we can write the changes.
            pdflatex ${theFile}
            explorer "${theFile:0:${#theFile}-3}pdf"
        else
            {
                rm "${theFile:0:${#theFile}-3}pdf"
                pdflatex ${theFile}
                } || {
                pdflatex ${theFile}
            }
            #If the PDF was open with okular, kill it
            if pgrep evince; then pkill evince; fi
            # Open newly compiled PDF with Okular
            evince ${theFile:0:${#theFile}-3}pdf &
        fi
    else
        echo "This is not a LaTeX file. Please, try again."
    fi
}
#==============================================================================