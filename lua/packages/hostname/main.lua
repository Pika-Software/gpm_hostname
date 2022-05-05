local cvarName = "hostname"
local logger = GPM.Logger( "Hostname" )

if (SERVER) then

    timer.Remove( "HostnameThink" )

    local hook_Run = hook.Run

    do

        local cvars_String = cvars.String
        local GetHostName = GetHostName

        function game.HostName()
            return cvars_String( cvarName, GetHostName() )
        end

    end

    do

        local net_Start = net.Start
        local net_Broadcast = net.Broadcast
        local net_WriteString = net.WriteString

        do

            local timer_Simple = timer.Simple
            local RunConsoleCommand = RunConsoleCommand

            function game.SetHostName( any )
                local new = tostring( any )
                if hook_Run( "OnHostNameChanged", new ) == true then return end

                RunConsoleCommand( cvarName, new )
                timer_Simple(0, function()
                    net_Start( "GPM:SendHostName" )
                        net_WriteString( new )
                    net_Broadcast()

                    logger:debug( "Hostname changed, new hostname is '{1}'", new )
                end)
            end

        end

        do
            local net_Send = net.Send
            util.AddNetworkString( "GPM:SendHostName" )
            hook.Add("PlayerInitialized", "GPM:SendHostName", function( ply )
                net_Start( "GPM:SendHostName" )
                    net_WriteString( game.HostName() )
                net_Send( ply )
            end)
        end

    end

else

    local hostname = "Garry's Mod"
    function game.HostName()
        return hostname
    end

    function game.SetHostName( str )
        hostname = str
    end

    do

        local net_ReadString = net.ReadString
        local game_SetHostName = game.SetHostName
        local RunConsoleCommand = RunConsoleCommand

        net.Receive("GPM:SendHostName", function()
            local hostname = net_ReadString()
            if (hostname ~= "") then
                game_SetHostName( hostname )
                RunConsoleCommand( cvarName, hostname )
                logger:debug( "Hostname changed, new hostname is '{1}'", hostname )
            end
        end)

    end

end

GetHostName = game.HostName
