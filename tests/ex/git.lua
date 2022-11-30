local Git = {}

function Git.init(git_root, branch)
    branch = branch or 'main'
    os.execute(string.format('git init -b %s %s', branch, git_root))
end

function Git.add(git_root, file)
    os.execute(string.format('git -C %s add %s', git_root, file))
end

function Git.commit(git_root, message)
    os.execute(string.format('git -C %s commit -am "%s"', git_root, message))
end

return Git
