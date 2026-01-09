export type function extend(base: type, superset: type): type
    assert(base:is("table") and superset:is("table"))

    local extended = types.newtable()

    for key, value in base:properties() do
        if value.read and value.write then
            extended:setproperty(key, value.read)
            continue
        end

        if value.read then
            extended:setreadproperty(key, value.read)
        elseif value.write then
            extended:setwriteproperty(key, value.write)
        end
    end

    for key, value in superset:properties() do
        if value.read and value.write then
            extended:setproperty(key, value.read)
            continue
        end

        if value.read then
            extended:setreadproperty(key, value.read)
        elseif value.write then
            extended:setwriteproperty(key, value.write)
        end
    end

    return extended
end

return {}
