ESX = nil

ESX = exports["es_extended"]:getSharedObject()

ESX.RegisterServerCallback('rk.garagejob:checkJob', function(source, cb, job)
    local xPlayer = ESX.GetPlayerFromId(source)
    
    if xPlayer and xPlayer.job and xPlayer.job.name == job then
        cb(true)
    else
        cb(false)
    end
end)