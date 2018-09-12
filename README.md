# TM1640_LUA
LUA Based driver for TM1640 based displays, namely the WEMOS Matrix LED Shield
(https://wiki.wemos.cc/products:d1_mini_shields:matrix_led_shield) 

With special thanks to Markus Gritsch for his BIT-BANGING, PERFORMANCE, AND LUA TABLE LOOKUPS article which gave me the solution.
https://www.esp8266.com/viewtopic.php?f=24&t=832

For performance purposes (see above) the code runs on pins D5 for SCLK and D7 for DIN.
You will need the BIT Module enabled in your LUA firmware.

The attached init.lua is just to demonstrate the behavior.

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
'''
