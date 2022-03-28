local cvarName = "hostname"

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

            function game.SetHostName( str )
                if hook_Run( "OnHostNameChanged") != true then
                    RunConsoleCommand( cvarName, str )
                    timer_Simple(0, function()
                        net_Start( "GPM:SendHostName" )
                            net_WriteString( str )
                        net_Broadcast()
                    end)
                end
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

    do
        local cvars_String = cvars.String
        local default = "Garry's Mod"
        function game.HostName()
            return cvars_String( cvarName, default )
        end
    end

    do
        local net_ReadString = net.ReadString
        local RunConsoleCommand = RunConsoleCommand
        net.Receive("GPM:SendHostName", function()
            RunConsoleCommand( cvarName, net_ReadString() )
        end)
    end

end

GetHostName = game.HostName
