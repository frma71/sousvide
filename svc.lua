-- GPIO2
TEMPPIN=4
-- GPIO0
OUTPIN=3

ctemp = 4000
oldtemp = 4000
settemp = 5900

out=0
-- 30 second output period
outp=30

cnt = 0

kpn = 1
kpd = 8
kdn = 0
kdd = 1

kin = 3
kid = 8192
acc = 0
accmax = 30*kid/kin;



function getjson(conn)
      sendHttpResp(conn,"application/json",200);
      conn:send("{\n\"temp\": ")
      conn:send(ctemp)
      conn:send(",\n\"target\": ")
      conn:send(settemp)
      conn:send(",\n\"out\": ")
      conn:send(out)
      conn:send(",\n\"time\": ")
      conn:send(tmr.time())
--      conn:send(",\n\"status\": \"")
--      conn:send(status)
--      conn:send("\"\n}")
      conn:send("\n}")
end

function ds_init(pin) 
   local addr
   ow.setup(pin)
   local count = 0
   repeat
      count = count + 1
      addr = ow.reset_search(pin)
      addr = ow.search(pin)
      tmr.wdclr()
      if count > 100 then
	 return nil
      end
   until(addr ~= nil)
   local crc = ow.crc8(string.sub(addr,1,7))
   if (crc == addr:byte(8)) then
      if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
	 return addr
      end
   end
   return nil
end

function ds_read(pin, addr)
   local crc
   if(force_temp) then 
      return force_temp
   end
   ow.reset(pin)
   ow.select(pin, addr)
   ow.write(pin, 0x44,1)
   tmr.delay(100000)
   local present = ow.reset(pin)
   ow.select(pin, addr)
   ow.write(pin,0xBE,1)
   local data = nil
   data = string.char(ow.read(pin))
   for i = 1, 8 do
      data = data .. string.char(ow.read(pin))
   end
   crc = ow.crc8(string.sub(data,1,8))
   if (crc == data:byte(9)) then
      return ((data:byte(1) + data:byte(2) * 256) * 625)/100
   end                   
   return nil
end


--require("ds18b20")
--function ds_init(pin)
--  ds18b20.setup(pin)
--end

--function ds_read()
--  local tint,tfrac = ds18b20.readNumber()
--  return tint*100+tfrac/100
--end

function regulate()
   print(node.heap())
   tmr.wdclr()
   local t = ds_read(TEMPPIN, addr)
   tmr.wdclr()
   print(t)
   if(t) then
      ctemp = t
      dbg:send("TEMP:" .. ctemp)
   else
      dbg:send("TFAIL")
   end
   print(node.heap())   
   local err = settemp - ctemp
   acc = acc + err;
   local delta = ctemp - oldtemp;
   local op,oi,od = (kpn*err)/kpd, (kin*acc)/kid, (kdn*delta)/kdd
   print(node.heap())
   if(oi > 50) then  oi=50;  acc = accmax; end
   if(oi < -50) then oi=-50; acc = -accmax; end
   out = op + oi + od
   print(node.heap())
   if out > 100 then out = 100 end
   if out < 0 then out = 0 end
   print(node.heap())
   oldtemp=ctemp
--   output()
end

function output()
   if cnt > outp then cnt = 0 end
   if cnt < out*outp/100 then 
      gpio.write(OUTPIN,gpio.LOW)
   else
      gpio.write(OUTPIN,gpio.HIGH)
   end
   cnt=cnt+1
end

function svc_start()
   gpio.mode(OUTPIN, gpio.OUTPUT)
   addr = ds_init(TEMPPIN)
   ds_init = nil
   if(addr ~= nil) then
      regulate()
      tmr.alarm(0,1000,1,regulate)
   else
      dbg:send("No sens")
   end
end
svc_start()
svc_start = nil
collectgarbage("collect")
