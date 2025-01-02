# Startup stuff ------------------------------------------------------
umask 022   #Used for setting file priveleges for files I create (I can write, others can read)
# --------------------------------------------------------------------

# Prompt
export prompt='[%n@%m %c02]$ '
export PS1='\[\e]0;\h:\w\a\]\n\[\e[36m\]\u@\h \[\e[33m\]\w\[\e[0m\] $? \n> '
export PS4=':${BASH_SOURCE}:${LINENO}+'
alias u='cd ..'
alias mc='mv'
# --------------------------------------------------------------------

# OS
unamestr=$(uname -r)
# --------------------------------------------------------------------

# ALIASES
export PATH="~/tools/fortify/source:$PATH"
export PATH="~/miniconda3/condabin/:$PATH"
alias clu="driver.py"
alias rpi="ssh louoberto@192.168.1.155"
alias python='python3'
alias lou='cd /Users/loberto/tools/'

# ====================================================================
if [[ $(uname) == "Darwin" ]]; then # Mac Only
    clear
    echo On bash. The current host name is $HOSTNAME.
    export BASH_SILENCE_DEPRECATION_WARNING=1
    alias ls='ls -aB --color'
    export PATH=/Library/Frameworks/Python.framework/Versions/Current/bin:$PATH
    export PATH=/usr/local/texlive/2024/bin/universal-darwin:$PATH
    ln -s "/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code" /usr/local/bin/code
fi
#--------------------------------------------------------------------

# COMMANDS
#====================================================================
gadd(){
    git add "$@"
}
gpush(){
    git commit -m "$1"
    git push
}

# Compile latex and open PDF shortcut
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

run(){
    the_cmd="$@"
    echo 'How many times to run?'
    read itrs
    for ((i=0;i<$itrs;i++)); do $the_cmd; done
}
#-----------------------------------------------------

# Find command shortcut ------------------------------
f(){
    fcmd="find . -name *$1* -not -name '*.o'"
    ${fcmd}
}
#-----------------------------------------------------

# Find & Remove Command ------------------------------
frm(){
    frmcmd1="find"
    frmcmd2="-type f -name"
    frmcmd="${frmcmd1} $1 ${frmcmd2} $2 -delete"
    ${frmcmd}
}
#-----------------------------------------------------

# Grep command shortcut ------------------------------
g(){
    # Enter the directories you wish to exclude
    xdir=(
        \*genTM\*
        \*kits\*
        \*docs\*
        \*build\*
        \*.git\*
    )
    # Enter the files you wish to exclude
    xfil=(
        '*.o'
        '*~'
        '*log'
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
    ${gcmd} "$1"
}
#-----------------------------------------------------
