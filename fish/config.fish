if status is-interactive
    # Commands to run in interactive sessions can go here
    abbr -a pn pnpm
    abbr -a gco 'git checkout'
    abbr -a ga 'git add'
    abbr -a gp 'git push --set-upstream origin (git branch --show-current)'
    abbr -a gpl 'git pull'
    abbr -a pni 'pnpm i'
    abbr -a gst 'git status'
    abbr -a cc 'claude'
    abbr -a gcim 'git commit -m'
    abbr -a t 'tmux'
    abbr -a tat 'tmux attach -t'
    abbr -a pdeploy 'pnpm run deploy'
end

# Added by Antigravity CLI installer
# set -gx PATH "/home/juandari/.local/bin" $PATH

# Go binary path
fish_add_path $HOME/go/bin
fish_add_path $HOME/.local/bin

# Prioritize Homebrew (so python3, etc. resolve to Homebrew versions over system
# ones). macOS only — guarded so these don't end up in fish_user_paths on Linux.
for dir in /opt/homebrew/sbin /opt/homebrew/bin
    if test -d $dir
        fish_add_path --move --prepend $dir
    end
end

# fnm is set up in conf.d/fnm.fish

# Default Editor (Antigravity IDE)
set -gx EDITOR "code --wait"
set -gx VISUAL "code --wait"

# The next line updates PATH for the Google Cloud SDK.
if [ -f "$HOME/google-cloud-sdk/path.fish.inc" ]; . "$HOME/google-cloud-sdk/path.fish.inc"; end

# Android SDK configuration
set -gx ANDROID_HOME $HOME/Library/Android/sdk
if test -d $ANDROID_HOME
    fish_add_path $ANDROID_HOME/emulator $ANDROID_HOME/platform-tools
end

