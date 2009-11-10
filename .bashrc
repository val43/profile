# This file originated in the Gentoo /etc/skel version but has been heavily
# modified.

# This file is sourced by all *interactive* bash shells on startup,
# including some apparently interactive shells such as scp and rcp
# that can't tolerate any output.

# Test for an interactive shell.  There is no need to set anything
# past this point for scp and rcp, and it's important to refrain from
# outputting anything in those cases.
if [[ $- != *i* ]]; then
	# Shell is non-interactive.  Be done now
	return
fi

# Support for figuring out how my .bashrc ran
function do_debug() { export BASHRC_DEBUG="$BASHRC_DEBUG"$'\n'"${BASHRC_DEBUG_INDENT}$@"; }

# Let's make use of screen for increased efficiency.
if [[ "$TERM" != screen* ]] && [[ "$TERMCAP" != *\|screen\|* ]] && [ "$NO_SCREEN" == "" ]; then
	do_debug "	    -- Calling screen subshell --"
	export BASHRC_DEBUG_INDENT="		"
		read -t 1 -p "Calling screen... (Press enter to cancel)" || exec screen -RR
	unset BASHRC_DEBUG_INDENT
else
	do_debug "	    -- Already running inside screen --"
fi

# Change the window title of X terminals (Customized from the Gentoo version)
case $TERM in
	xterm*|rxvt|Eterm|eterm)
		PROMPT_COMMAND='echo -ne "\033]0;bash: ${PWD/$HOME/~}\007"'
		;;
	screen)
		PROMPT_COMMAND='echo -ne "\033k"bash$"\033"\\; echo -ne "\033_${PWD/$HOME/~}\033\\"'
		#PROMPT_COMMAND='echo -ne "\033_bash: ${PWD/$HOME/~} - Window: $WINDOW\033\\"'
		;;
esac

# uncomment the following to activate bash-completion:
#[ -f /etc/profile.d/bash-completion ] && source /etc/profile.d/bash-completion
# (Too slow-loading for me)
source ~/.bash_completion

# Configure the shell the way I like it
shopt -s cdspell         # Enable typo correction for the cd command.
shopt -s checkwinsize    # Make sure bash keeps the LINES and COLUMNS current as the term resizes.
shopt -s extglob         # Enable more regex-like shell glob support
set -b                   # Make status messages about terminated background jobs appear immediately

# Set up comfortable history management.
export CDPATH=".:~"
export HISTFILESIZE=1000 # Default is 500 lines
export HISTIGNORE="&"	 # Example: export HISTIGNORE="&:ls:ls *:mutt:[bf]g:exit"
export HISTCONTROL="ignoredups:ignorespace:erasedups" # Make sure a command only appears in the list once.
export PROMPT_COMMAND="history -a; ${PROMPT_COMMAND}"
shopt -s cmdhist         # Ensure multi-line commands are single-line history entries
shopt -s histappend      # Append command history, don't overwrite

# Pull in the stuff common to both bash and zsh
source ~/.common_sh_init/env
source ~/.common_sh_init/aliases

# Make the bash `which` command more like its zsh counterpart.
which () {
  (alias; declare -f) | /usr/bin/which --tty-only --read-alias --read-functions --show-tilde --show-dot $@
}
export -f which

# Run fortune for maximum wittiness
fortune

# The following line is included in ~/.common_sh_init/env but has to remain here
# so the KCM module for gtk-qt can see it.

# This line was appended by KDE
# Make sure our customised gtkrc file is loaded.
export GTK2_RC_FILES="$HOME/.gtkrc-2.0:$HOME/.kde/share/config/gtkrc-2.0:/etc/gtk-2.0/gtkrc"