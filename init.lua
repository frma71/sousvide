function configAndReboot(conn)
   wifi.setmode(wifi.STATION)
   wifi.sta.config(ssid,password)
   node.restart()
end

function startApp()
   dbg=net.createConnection(net.UDP)
   dbg:connect(1234, wifi.sta.getbroadcast())
   dbg:send("START")
   wait_for_ip = nil
   startConfig = nil
   configAndReboot = nil
   collectgarbage("collect")
   dofile("svc.lua")
   dofile("svcweb.lua")
end

function startConfig()
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
		   jointries = nil
		   startConfig()
		else 
		   jointries = jointries - 1
		end
	     end)
end

tmr.alarm(0,3000,0, wait_for_ip)
print("tmr.stop(0) within 3 secs to cancel boot")
	   
	 
