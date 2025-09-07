export type PackageManagerConfig = {
    scope: string,
    --- `{scope}/{root_name}_{crate_name}`, defaults to `RootConfig.name`
    root_name: string?,
    registry: string,
}

export type RootConfig = {
    name: string,
    crates: string,

    repository: string,
    homepage: string,
    authors: { string },
    license: string,

    package_managers: {
        pesde: PackageManagerConfig?,
        wally: PackageManagerConfig?,
    },
}

local function Type(config: RootConfig): RootConfig
    return config
end

return Type
