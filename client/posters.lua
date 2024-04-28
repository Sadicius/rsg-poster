local RSGCore = exports['rsg-core']:GetCoreObject()

local Flags = {
    haveTexturesBeenRequested = false,
    haveTexturesBeenLoaded = false,
    bountyBoardInitialized = false,
    regularPostersInitialized = false,
    legendaryPostersInitialized = false,
    advertPosterInitialized = false,
    customTextureApplied = false
}

local Posters = {
    poster0 = {
        tex = 'bounty_target_02',
        txd = 'bounty_target_02',
        isVisible = true,
        isDiffVisible = false,
        type = 1,
        difficulty = 1,
        price = '$99.00',
        body = 'bodys',
        header = 'headersd',
        name = 'namesds',
        posterid = 'Poster0',
        model = 'mp005_p_mp_bountyposter01x',
        coords = vector3(2680.21, -1454.054, 46.82629), -- St Denis train station near benches
        objectId = nil
    }
}

local Databindings = {}

local UiflowblockRequest = function(hash)
    return Citizen.InvokeNative(0xC0081B34E395CE48, hash)
end

local UiflowblockIsLoaded = function(flowblock)
    return Citizen.InvokeNative(0x10A93C057B6BD944, flowblock)
end

local UiflowblockEnter = function(flowblock, hash)
    return Citizen.InvokeNative(0x3B7519720C9DCB45, flowblock, hash)
end

local UiflowblockRelease = function(flowblock)
    return Citizen.InvokeNative(0xF320A77DD5F781DF, flowblock)
end

local UistatemachineExists = function(hash)
    return Citizen.InvokeNative(0x5D15569C0FEBF757, hash)
end

local UistatemachineCreate = function(hash, flowblock)
    return Citizen.InvokeNative(0x4C6F2C4B7A03A266, hash, flowblock)
end

local UiStatemachineDestroy = function(hash)
    Citizen.InvokeNative(0x4EB122210A90E2D8, hash)
end

local RequestStreamedTexture = function(hash, bool)
    Citizen.InvokeNative(0xDB1BD07FB464584D, hash, bool)
end

local HasStreamedTextureLoaded = function(hash)
    return Citizen.InvokeNative(0xBE72591D1509FFE4, hash)
end

local DoesStreamedTextureExist = function(hash)
    return Citizen.InvokeNative(0xBA0163B277C2D2D0, hash)
end

local SetStreamedTxdAsNoLongerNeeded = function(hash)
    Citizen.InvokeNative(0x8232F37DF762ACB2, hash)
end

local SetCustomTexturesOnObject = function(obj, txdHash, p2, p3)
    Citizen.InvokeNative(0xE124889AE0521FCF, obj, txdHash, p2, p3)
end

local EnableEntityMask = function()
    Citizen.InvokeNative(0xFAAD23DE7A54FC14)
end

local DisableEntitymask = function()
    Citizen.InvokeNative(0x5C9978A2A3DC3D0D)
end

local RemoveEntityFromEntityMask = function(obj)
    Citizen.InvokeNative(0x56A786E87FF53478, obj)
end

local AddEntityToEntityMaskWithIntensity = function(obj, mask, intensity)
    Citizen.InvokeNative(0x958DEBD9353C0935, obj, mask, intensity)
end

local loadTextureDicts = function ()
    if not DoesStreamedTextureExist(joaat(Posters['poster0'].txd)) or
        not DoesStreamedTextureExist(joaat('BOUNTY_HUNTER_EXPANSION')) then
        return false
    end

    RequestStreamedTexture(joaat(Posters['poster0'].txd), false)
    while not HasStreamedTextureLoaded(joaat(Posters['poster0'].txd)) do
        Wait(1)
    end

    RequestStreamedTexture(joaat('BOUNTY_HUNTER_EXPANSION'), false)
    while not HasStreamedTextureLoaded(joaat('BOUNTY_HUNTER_EXPANSION')) do
        Wait(1)
    end

    return true
end

local initializeDatabindings = function()
    Databindings.bountyBoardData = DatabindingAddDataContainerFromPath('', 'bounty_board_data')
    Databindings.posters = {}
    Databindings.posters.poster0 = {}
    Databindings.posters.poster0.container = DatabindingAddDataContainer(Databindings.bountyBoardData, 'Poster0')

    Databindings.posters.poster0.isVisible = DatabindingAddDataBool(Databindings.posters.poster0.container, 'isVisible',
        false)
    Databindings.posters.poster0.isDiffVisible = DatabindingAddDataBool(Databindings.posters.poster0.container,
        'isDiffVisible', false)
    Databindings.posters.poster0.type = DatabindingAddDataInt(Databindings.posters.poster0.container, 'type', 0)
    Databindings.posters.poster0.difficulty = DatabindingAddDataInt(Databindings.posters.poster0.container,
        'difficulty', 0)
    Databindings.posters.poster0.price = DatabindingAddDataString(Databindings.posters.poster0.container, 'price', '')
    Databindings.posters.poster0.body = DatabindingAddDataString(Databindings.posters.poster0.container, 'body', '')
    Databindings.posters.poster0.header = DatabindingAddDataString(Databindings.posters.poster0.container, 'header', '')
    Databindings.posters.poster0.name = DatabindingAddDataString(Databindings.posters.poster0.container, 'name', '')
    Databindings.posters.poster0.tex = DatabindingAddDataHash(Databindings.posters.poster0.container, 'tex', 0)
    Databindings.posters.poster0.txd = DatabindingAddDataHash(Databindings.posters.poster0.container, 'txd', 0)

    Flags.regularPostersInitialized = true
end

local initializeBountyBoard = function()
    if not loadTextureDicts() then
        print('failed to load texture dicts')
        return false
    end

    local flowblock = UiflowblockRequest(1911615281)

    initializeDatabindings()
    print('initialize databindings')

    while not UiflowblockIsLoaded(flowblock) do
        Wait(1)
    end

    UiflowblockEnter(flowblock, joaat('bounty_board'))

    if not UistatemachineExists(-1436556974) then
        UistatemachineCreate(-1436556974, flowblock)
    end

    Flags.bountyBoardInitialized = true
    print(flowblock)
    return flowblock
end

local fillPosters = function()
    -- currently only 1 poster
    for poster, bindings in pairs(Databindings.posters) do
        DatabindingWriteDataString(bindings.name, Posters[poster].name)
        DatabindingWriteDataString(bindings.body, Posters[poster].body)
        DatabindingWriteDataString(bindings.header, Posters[poster].header)
        DatabindingWriteDataString(bindings.price, Posters[poster].price)
        DatabindingWriteDataInt(bindings.type, Posters[poster].type)

        DatabindingWriteDataHashString(bindings.txd, joaat(Posters[poster].txd))
        DatabindingWriteDataHashString(bindings.tex, joaat(Posters[poster].tex))

        DatabindingWriteDataBool(bindings.isVisible, Posters[poster].isVisible)
    end

end

local loadPosterModel = function()
    local modelHash = joaat(Posters['poster0'].model)
    RequestModel(modelHash)

    if not IsModelValid(modelHash) then
        return false
    end

    while not HasModelLoaded(modelHash) do
        Wait(1)
    end

    return true
end

local createPosters = function()
    for _, data in pairs(Posters) do

        if DoesEntityExist(data.objectId or 0) then
            RemoveEntityFromEntityMask(data.objectId)
        else
            data.objectId = CreateObjectNoOffset(joaat(data.model), data.coords.x, data.coords.y, data.coords.z, false, false, false, false)
        end

        print(data.objectId)
        while not DoesEntityExist(data.objectId) do
            Wait(1)
        end

        print('obj', data.objectId)

        EnableEntityMask()
        AddEntityToEntityMaskWithIntensity(data.objectId, 2, 1.0)

        SetEntityVisible(data.objectId, true)
        SetEntityCollision(data.objectId, true, false)
        FreezeEntityPosition(data.objectId, true)
    end

    return true
end

RegisterCommand('poster_add', function()

    Flags['flowblock'] = initializeBountyBoard()
    print('initialize posters')

    fillPosters()
    print('filled posters')

    if not loadPosterModel() then
        print('failed to load models')
        return
    end

    print('loaded models')

    createPosters()
    print('created posters')

    if DoesEntityExist(Posters['poster0'].objectId) == 1 then

        if not Flags.haveTexturesBeenRequested then
            print('requesting texture')

            RequestStreamedTexture(joaat(Posters['poster0'].tex))
            Flags.haveTexturesBeenRequested = true
        end

        if not Flags.haveTexturesBeenLoaded then
            Flags.haveTexturesBeenLoaded = HasStreamedTextureLoaded(joaat(Posters['poster0'].tex)) == 1
        end

        if Flags.haveTexturesBeenRequested and Flags.haveTexturesBeenLoaded and not Flags.customTextureApplied then
            SetCustomTexturesOnObject(Posters['poster0'].objectId, joaat(Posters['poster0'].tex), 0, 0)
            SetStreamedTxdAsNoLongerNeeded(joaat(Posters.poster0.txd))
            print('set custom texture')
            Flags.customTextureApplied = true
        end
    end

    print('Exiting')
end, false)

RegisterCommand('poster_dump', function()
    print(json.encode(Flags))
end, false)

RegisterCommand('poster_clean', function()
    RemoveEntityFromEntityMask(Posters.poster0.objectId)
    print('Removing mask')
    DisableEntitymask()
    print('disable mask')
    DatabindingRemoveDataEntry(Databindings.posters.poster0.container)
    DatabindingRemoveDataEntry(Databindings.bountyBoardData)
    if UistatemachineExists(-1436556974) then
        UiStatemachineDestroy(-1436556974)
        print('destory statemachine')
    end

    if UiflowblockIsLoaded(Flags['flowblock']) then
        -- UiflowblockRelease(Flags['flowblock']) ?????? error 
        print('Release flowblock', Flags['flowblock'])
    end

    DeleteEntity(Posters.poster0.objectId)
    print('delete entity')
    SetStreamedTxdAsNoLongerNeeded(joaat('BOUNTY_HUNTER_EXPANSION'))
    SetStreamedTxdAsNoLongerNeeded(joaat(Posters['poster0'].txd))
    SetModelAsNoLongerNeeded(joaat('mp005_p_mp_bountyposter01x'))
    print('unload model and textures')

end, false)