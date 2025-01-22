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
    cd ~/tools
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

if [ -f ../.bash_login ]; then
    source ../.bash_login
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