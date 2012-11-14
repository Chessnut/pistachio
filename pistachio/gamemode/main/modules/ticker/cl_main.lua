if (SERVER) then return; end;

surface.CreateFont( "ps_TickerFont", {
    font = "Tahoma",
    size = 14,
    weight = 400,
    antialias = true,
    outline = true
} );

local enableTicker = CreateClientConVar("ps_enableticker", "1", true, false);
local textX;
local currentMessage = 1;
local messages = {
    "Visit the official website at <website>!",
    "Invite your friends and have a good time!",
    "Remember that administrators are here to help you.",
    "Please respect other players and treat them as you'd treat yourself.",
    "The purpose of Pistachio is to allow the use of your imagination.",
    "Don't create drama in OOC chat."
};
local currentText = messages[currentMessage];
local alpha = 0;
local currentColor = Color(255, 255, 255);
local colorString = {};
colorString["red"] = Color(255, 0, 0);
colorString["orange"] = Color(255, 125, 0);
colorString["yellow"] = Color(255, 255, 0);
colorString["green"] =  Color(0, 0, 255);
colorString["cyan"] = Color(0, 255, 255);
colorString["blue"] = Color(0, 0, 255);
colorString["purple"] = Color(255, 0, 255);
colorString["gray"] = Color(125, 125, 125);

hook.Add("HUDPaint", "ps_Ticker", function()
    if (enableTicker:GetInt() > 0) then
        surface.SetFont("ps_TickerFont");
        
        local scrW, scrH = surface.ScreenWidth(), surface.ScreenHeight();
        local width, height = surface.GetTextSize( messages[currentMessage] );
        
        if (!textX) then
            textX = scrW;
        end;

        if (textX + width < scrW * 0.2 or textX > scrW * 0.8) then
            alpha = math.Approach(alpha, 0, FrameTime() * 125);
        else
            alpha = math.Approach(alpha, 255, FrameTime() * 125);
        end;

        if (textX <= -width) then
            textX = scrW;
            currentMessage = currentMessage + 1;
            
            if ( !messages[currentMessage] ) then
                currentMessage = 1;
            end;
            
            currentText = messages[currentMessage];
            currentColor = Color(255, 255, 255);
            
            for k, v in pairs(colorString) do
                local length = string.len(k) + 1;
                
                if (string.sub(currentText, 1, length) == k..":") then
                    currentColor = v;
                    currentText = string.gsub(currentText, k..":", "");
                end;
            end;
        else
            textX = math.Approach(textX, -width, FrameTime() * 64);
        end;
        
        surface.SetDrawColor(0, 0, 0, alpha * 0.8);
        surface.DrawRect(scrW * 0.25 - 2, 6, scrW * 0.5 + 4, 22);
        
        surface.SetDrawColor(255, 255, 255, alpha * 0.1);
        surface.DrawOutlinedRect(scrW * 0.25 - 1, 7, scrW * 0.5 + 2, 20);
        
        surface.SetDrawColor(255, 255, 255, alpha * 0.81);
        surface.DrawOutlinedRect(scrW * 0.25 - 3, 5, scrW * 0.5 + 6, 24);
        
        render.SetScissorRect(scrW * 0.25, 5, scrW * 0.75, 24, true);
            draw.SimpleText(currentText, "ps_TickerFont", textX, 17, Color(currentColor.r, currentColor.g, currentColor.b, alpha), 0, 1)
        render.SetScissorRect(scrW * 0.25, 5, scrW * 0.75, 24, false);
    end;
end);
