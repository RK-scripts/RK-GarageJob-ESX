Config = {}

Config.Garages = {
    {
        Name = "Cardealer Garage",
        job = 'cardealer',
        coords = vector3(215.124, -791.377, 30.646),
        useCustomColors = true, -- Abilita/disabilita colori personalizzati per questo garage
        vehicles = {
            {
                model = 'adder', 
                maxSpawn = 2,
                colors = {
                    primary = '#ec0db9', --(utilizza il sito https://htmlcolorcodes.com/ per trovare i colori)
                    secondary = '#ec0db9'
                }
            },
            {
                model = 'ambulance', 
                maxSpawn = 1,
                colors = {
                    primary = '#FFFFFF',
                    secondary = '#FF0000'
                }
            }
        }
    },
    {
        Name = "Mechanic Garage",
        job = 'mechanic',
        coords = vector3(-238.4866, -1395.4818, 30.9808),
        useCustomColors = false,
        vehicles = {
            {
                model = 'adder', 
                maxSpawn = 2,
                colors = {
                    primary = '#ec0db9',
                    secondary = '#ec0db9'
                }
            },
            {
                model = 'ambulance', 
                maxSpawn = 1,
                colors = {
                    primary = '#FFFFFF',
                    secondary = '#FF0000'
                }
            }
        }
    }
}