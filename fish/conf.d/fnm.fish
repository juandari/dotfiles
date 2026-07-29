# fnm (Node.js version manager).
# Linux uses the install-script location, macOS the Homebrew one. Take the
# first that exists and set it up once — sourcing `fnm env` twice, or
# prepending to PATH unguarded, is what used to duplicate PATH entries.
for dir in $HOME/.local/share/fnm /opt/homebrew/opt/fnm/bin
    if test -d $dir
        fish_add_path --global --prepend $dir
        fnm env --use-on-cd --shell fish | source
        break
    end
end
