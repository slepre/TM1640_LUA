-- Pin 5 is users for SCK, Pin 7 is used for DIN
-- Direct Pin assignment is used for performance
-- requires GPIO and BIT modules

gpio.mode(5,gpio.OUTPUT,gpio.PULLUP)
gpio.mode(7,gpio.OUTPUT,gpio.PULLUP)
-- variable instead of the table lookup for gpio.write
gpio_write = gpio.write
--variable timer
tmr_val = 100
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
-- Frame Buffer to accelerate lookups
frame_buffer = {}
-- Routines
function TM1640_Byte(data)
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

function TM1640_Command(cmd)
    gpio_write(7,0)
    TM1640_Byte(cmd)
    gpio_write(7,1)
end

-- TM1640 Brightness level goes from 0 to 7
function TM1640_Brightness(brightness)
    TM1640_Command(0x40)
    TM1640_Command(0x88 + brightness)
end
-- Display frame_buffer
function TM1640_FrameData()
    TM1640_Command(0x40);
    gpio_write(7,0)
    TM1640_Byte(0xC0)
    for k=1,8 do TM1640_Byte(frame_buffer[k]) end
    gpio_write(7,1)
end

function TM1640_ClearFrame()
    frame_buffer = {0,0,0,0,0,0,0,0}
end
-- Example of pure random display 
function FrameRandom()
    for k = 1,8 do frame_buffer[k] = node.random(255) end
    TM1640_Command(0x40);
    gpio_write(7,0)
    TM1640_Byte(0xC0)
    for k=1,8 do TM1640_Byte(frame_buffer[k]) end
    gpio_write(7,1)
    tmr_val = tmr_val + node.random(-250,250)
    if tmr_val < 100 then tmr_val = 100
    elseif tmr_val > 1000 then tmr_val = 1000
    end
    mytimer:register(tmr_val, 0, function() FrameRandom() end)
    mytimer:start()
end
-- Example showing the Monsters in random order, at random times between 100ms and 1000ms
function FrameRandomMonster()
    local x = node.random(1,table.getn(tmonster))
    for k = 1,8 do frame_buffer[k] = tmonster[x][k] end
    TM1640_Command(0x40);
    gpio_write(7,0)
    TM1640_Byte(0xC0)
    for k=1,8 do TM1640_Byte(frame_buffer[k]) end
    gpio_write(7,1)
    tmr_val = tmr_val + node.random(-250,250)
    if tmr_val < 100 then tmr_val = 100
    elseif tmr_val > 1000 then tmr_val = 1000
    end
    mytimer:register(tmr_val, 0, function() FrameRandomMonster() end)
    mytimer:start()
end
-- init
TM1640_Brightness(5)
-- init timer and play the monsters
mytimer=tmr.create()
mytimer:register(tmr_val, 0, function() FrameRandomMonster() end)
mytimer:start()
