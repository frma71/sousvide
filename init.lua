function startApp()
   print("Start App")
   uart.on("data")
   wait_for_ip = nil
   startConfig = nil
   collectgarbage("collect")
   dofile("svc.lua")
   dofile("svcweb.lua")
end

function startConfig()
   uart.on("data")
   print("Go to config mode")
   wifi.setmode(wifi.STATIONAP)
   wifi.ap.config({ssid="Sous0001",pwd="Sousvide"})
   wait_for_ip = nil
   startApp = nil
   collectgarbage("collect")
   dofile("svcweb.lua")
end

jointries = 10
function wait_for_ip()
   jointries = 10
   wifi.setmode(wifi.STATION)
   tmr.alarm(0,1000,1, 
	     function()
		print("Waiting for IP...")
		if not (wifi.sta.getip() == nil) then
		   print("Got IP:"..wifi.sta.getip())
		   tmr.stop(0)
		   startApp()
		end
		if(jointries == 0) then
		   tmr.stop(0)
		   startConfig()
		else 
		   jointries = jointries - 1
		end
	     end)
end



tmr.alarm(0,3000,0, wait_for_ip)
print("Starting in 3 seconds, press q to cancel...")
uart.on("data","q", 
	function() 
	   tmr.stop(0)
	   uart.on("data")
	   print "Start canceled"
	end, 1)
	   
	 
