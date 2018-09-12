# TM1640_LUA
LUA Based driver for TM1640 based displays, namely the WEMOS Matrix LED Shield
(https://wiki.wemos.cc/products:d1_mini_shields:matrix_led_shield) 

With special thanks to Markus Gritsch for his BIT-BANGING, PERFORMANCE, AND LUA TABLE LOOKUPS article which gave me the solution.
https://www.esp8266.com/viewtopic.php?f=24&t=832

For performance purposes (see above) the code runs on pins D5 for SCLK and D7 for DIN.
You will need the BIT Module enabled in your LUA firmware.

The attached init.lua is just to demonstrate the behavior.

###### UPDATE

As I also have a WEMOS Tripler Base (https://wiki.wemos.cc/products:d1_mini_shields:tripler_base) as well as two other Matrix LED Shields I thought I could probably drive all three displays from a single ESP-8266.

Given D7 (DIN) is shared for all 3 TM1640 I decided to use D6 and D8 to provide the SCK to the other two matrices.
_Since the center unit is a 'pass through' I assigned 
        **D6** to the **LEFT** side TM1640
        **D5** to the **MIDDLE** TM1640
        **D8** to the **RIGHT** side TM1640
It does require to cut a few lines and add two straps on the Tripler Base. Details to follow.

The only change is that we need to change the SCK pin we use in the TM1640_Byte(data) function:

```LUA
function TM1640_Byte2(data)
    for i = 1,8 do
        gpio_write(6,0) -- the change is here, this variant bangs SCK on pin 6
        -- gpio_write(8,0) -- the change is here, this variant bangs SCK on pin 8
        if bit.band(data,1)>0 then
            gpio_write(7,1)
        else
            gpio_write(7,0)
        end
        gpio_write(6,1)
        data=bit.arshift(data, 1)
    end
end
```

Still not sure which is the best approach in this case.
With everything hardcoded as per the above, I am able to play a unique Monster Face on each display.


I was able to sustain 40ms refresh rate on a D1 MINI PRO with the following change to the init.lua code:
```LUA
function FrameRandomMonster()

     local x = node.random(1,table.getn(tmonster))
     
     for k = 1,8 do frame_buffer[k] = tmonster[x][k] end
     
     TM1640_Command(0x40)
     
     gpio_write(7,0)
     
     TM1640_Byte(0xC0)
     
     for k=1,8 do TM1640_Byte(frame_buffer[k]) end
     
     gpio_write(7,1)

end

mytimer=tmr.create()

mytimer:register(40, 1, function() FrameRandomMonster() end)

mytimer:start()
```
