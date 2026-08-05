# Golang environment setup for Fish shell

# Set GOROOT if /usr/local/go exists
if test -d /usr/local/go
    set -gx GOROOT /usr/local/go
end

# Set GOPATH if not already set
if not set -q GOPATH
    set -gx GOPATH $HOME/go
end

# Ensure GOPATH bin directory exists
if not test -d $GOPATH/bin
    mkdir -p $GOPATH/bin
end

# Add Go binary directories to PATH (prepend /usr/local/go/bin for priority)
for dir in $GOROOT/bin /usr/local/go/bin $GOPATH/bin
    if test -d $dir
        fish_add_path --global --prepend $dir
    end
end
