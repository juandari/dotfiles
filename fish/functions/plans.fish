function plans --description 'Serve the local Claude plan viewer (.claude/plans) on localhost:3030'
    # Passes through args: optional plans dir, and --port N.
    # Defaults to ./.claude/plans on port 3030.
    node ~/dotfiles/claude/tools/plan-viewer.mjs $argv
end
