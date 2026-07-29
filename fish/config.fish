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
set -gx PATH "/home/juandari/.local/bin" $PATH

# Go binary path
fish_add_path /home/juandari/go/bin
