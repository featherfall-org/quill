export type WorkspaceCrate =
    | "core"
    | "dependencies"
    | "logger"
    | "rblx_components"

export type PesdePackageVariant = {
    name: string,
    version: string,
}

export type WallyPackageVariant = {
    name: string,
    version: string,
}

export type DependencySpecifier = {
    pesde: PesdePackageVariant,
    wally: WallyPackageVariant,
}

export type Target = "luau" | "roblox"

export type CrateConfig = {
    name: WorkspaceCrate,
    description: string,
    version: string,
    lib: string,

    targets: { [Target]: true },
    workspace_dependencies: { [WorkspaceCrate]: true }?,
    dependencies: { [string]: DependencySpecifier }?,
}

local function Type(config: CrateConfig): CrateConfig
    return config
end

return Type
