-- Pin D7 is used for DIN, Shared
-- Pin D6 is used for the Left TM1640
-- Pin D5 is used for the Center TM1640
-- Pin D6 is used for the Right TM1640
-- Direct Pin assignment is used for performance
gpio.mode(5,gpio.OUTPUT,gpio.PULLUP)
gpio.mode(7,gpio.OUTPUT,gpio.PULLUP)
gpio.mode(6,gpio.OUTPUT,gpio.PULLUP)
gpio.mode(8,gpio.OUTPUT,gpio.PULLUP)
-- variable instead of the table lookup for gpio.write
gpio_write = gpio.write
--variable timer
tmr_val = 100
-- Frame Buffer to accelerate lookups
frame_buffer = {}
-- Some 8x8 cliparts, add as needed
tmonster={
    {102,126,219,60,24,36,102,66},
    {102,255,219,126,60,36,66,165},
    {153,189,90,126,66,60,219,129},
    {195,126,66,90,66,126,90,36},
    {231,60,60,90,126,24,102,36},
    {24,60,126,219,189,24,102,66},
    {24,60,126,219,255,60,126,165},
    {36,126,255,219,126,66,189,129},
    {36,60,60,90,189,60,102,66},
    {36,66,36,126,153,255,60,90},
    {60,126,255,219,126,60,126,219},
    {60,126,255,255,126,90,60,90},
    {66,102,60,126,195,189,102,66},
    {66,129,189,90,102,60,102,165},
    {66,129,255,90,102,126,102,66},
    {66,60,126,219,255,102,165,129},
}
-- Byte Routines
function TM1640_Byte(data) -- Bang D5 SCK
    for i = 1,8 do
        gpio_write(5,0)
        if bit.band(data,1)>0 then
            gpio_write(7,1)
        else
            gpio_write(7,0)
        end
        gpio_write(5,1)
        data=bit.arshift(data, 1)
    end
end
function TM1640_Byte2(data) -- Bang D6 SCK
    for i = 1,8 do
        gpio_write(6,0)
        if bit.band(data,1)>0 then
            gpio_write(7,1)
        else
            gpio_write(7,0)
        end
        gpio_write(6,1)
        data=bit.arshift(data, 1)
    end
end
function TM1640_Byte3(data) -- Bang D8 SCK
    for i = 1,8 do
        gpio_write(8,0)
        if bit.band(data,1)>0 then
            gpio_write(7,1)
        else
            gpio_write(7,0)
        end
        gpio_write(8,1)
        data=bit.arshift(data, 1)
    end
end
-- Command Routines
function TM1640_Command(cmd) -- Bang D5 SCK
    gpio_write(7,0)
    TM1640_Byte(cmd)
    gpio_write(7,1)
end
function TM1640_Command2(cmd) -- Bang D6 SCK
    gpio_write(7,0)
    TM1640_Byte2(cmd)
    gpio_write(7,1)
end
function TM1640_Command3(cmd) -- Bang D8 SCK
    gpio_write(7,0)
    TM1640_Byte3(cmd)
    gpio_write(7,1)
end
-- TM1640 Brightness Routines (0 to 7)
function TM1640_Brightness(brightness)
    TM1640_Command(0x40)
    TM1640_Command(0x88 + brightness)
end
function TM1640_Brightness2(brightness)
    TM1640_Command2(0x40)
    TM1640_Command2(0x88 + brightness)
end
function TM1640_Brightness3(brightness)
    TM1640_Command3(0x40)
    TM1640_Command3(0x88 + brightness)
end
-- Example of random Monster on each display 
function TripleMonster()
local x = node.random(1,table.getn(tmonster))
local y = node.random(1,table.getn(tmonster))
local z = node.random(1,table.getn(tmonster))
    for k = 1,8 do frame_buffer[k] = tmonster[z][k] end
    TM1640_Command3(0x40);
    gpio_write(7,0)
    TM1640_Byte3(0xC0)
    for k=1,8 do TM1640_Byte3(frame_buffer[k]) end
    gpio_write(7,1)
    
    for k = 1,8 do frame_buffer[k] = tmonster[x][k] end
    TM1640_Command(0x40);
    gpio_write(7,0)
    TM1640_Byte(0xC0)
    for k=1,8 do TM1640_Byte(frame_buffer[k]) end
    gpio_write(7,1)
    
    for k = 1,8 do frame_buffer[k] = tmonster[y][k] end
    TM1640_Command2(0x40);
    gpio_write(7,0)
    TM1640_Byte2(0xC0)
    for k=1,8 do TM1640_Byte2(frame_buffer[k]) end
    gpio_write(7,1)
    
    -- timer stuff
    tmr_val = tmr_val + node.random(-250,250)
    if tmr_val < 100 then tmr_val = 100
    elseif tmr_val > 1000 then tmr_val = 1000
    end
    mytimer:register(tmr_val, 0, function() TripleMonster() end)
    mytimer:start()

end
-- init sequence
TM1640_Brightness(1)
TM1640_Brightness2(1)
TM1640_Brightness3(1)
-- animation
mytimer=tmr.create()
mytimer:register(250, 0, function() TripleMonster() end)
mytimer:start()
