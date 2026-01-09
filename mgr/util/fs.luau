local fs = zune.fs
local stdpath = fs.path
local task = zune.task
local process = zune.process

local function exists(path: string): boolean
    return fs.stat(path).kind ~= "none"
end

local function is_dir(path: string): boolean
    return fs.stat(path).kind == "directory"
end

local function ensure_dirs(dirs: { string })
    for _, dir in dirs do
        if exists(dir) and is_dir(dir) then
            continue
        end
        fs.makeDir(dir, true)
    end
end

local function remove(path: string, recursive: boolean?)
    if is_dir(path) then
        fs.deleteDir(path, recursive)
        return
    end
    fs.deleteFile(path)
end

local function remove_safe(path: string, recursive: boolean?)
    if not exists(path) then
        return
    end
    remove(path, recursive)
end

local function shell_remove(
    path: string,
    flags: { recursive: boolean?, force: boolean? }?
)
    local args = table.create(3) :: { string }
    if flags then
        if flags.recursive then
            table.insert(args, "-r")
        end

        if flags.force then
            table.insert(args, "-Force")
        end
    end
    table.insert(args, path)
    process.run("rm", args, { shell = "pwsh" } :: any)
end

local function mime_folders(paths: { string }): () -> ()
    local acting: { [string]: true } = {}
    for _, path in paths do
        if is_dir(path) then
            continue
        end
        fs.deleteDir(path)
        acting[path] = true
    end

    local function cleanup()
        for path in acting do
            fs.deleteDir(path)
        end
    end

    return cleanup
end

local function traverse(
    dir: string,
    fn: (
        path: string,
        name: string,
        metadata: Metadata,
        local_path: string
    ) -> (),
    start_name: string?
)
    assert(is_dir(dir))

    local local_name = start_name or stdpath.basename(dir)

    for _, entry in fs.entries(dir) do
        local path = stdpath.join(dir, entry.name)
        local child = fs.metadata(path)
        if not child then
            continue
        end

        local local_path = stdpath.join(local_name, entry.name)
        fn(path, entry.name, child, local_path)
        if child.kind == "directory" then
            traverse(path, fn, local_path)
            continue
        end
    end
end

local function watch_file(
    path: string,
    fn: (metadata: Metadata) -> ()
): () -> ()
    local origin_metadata = fs.metadata(path)
    local last_modified = origin_metadata.modified_at

    local thread = task.spawn(function()
        while true do
            task.wait(1)

            local metadata = fs.metadata(path)
            if last_modified < metadata.modified_at then
                last_modified = metadata.modified_at
                fn(metadata)
            end
        end
    end)

    return function()
        task.cancel(thread)
    end
end

local function relative_require_path(from: string, to: string)
    return string.gsub(stdpath.relative(from, to), stdpath.stem(to), "")
end

return {
    exists = exists,
    ensure_dirs = ensure_dirs,
    remove = remove,
    remove_safe = remove_safe,
    shell_remove = shell_remove,
    mime_folders = mime_folders,
    traverse = traverse,
    watch_file = watch_file,
    relative_require_path = relative_require_path,
}
