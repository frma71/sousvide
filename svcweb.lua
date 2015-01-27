-- dofile("svcweb.lua")
ctemp=2700
settemp=6700
out=0
--status="ok"
pt = "text/plain"
function sendHttpResp(conn,ctype,code)
   conn:send("HTTP/1.1 200 OK\nContent-Type: ")
   conn:send(ctype)
   conn:send("\nAccess-Control-Allow-Origin: *\n\n")
end

function handleReceive(conn,request)
   local   _, _, _, path = string.find(request, "([A-Z]+) (.+) HTTP"); 
   request = nil
   local cmd = string.sub(path,1,5)
   if cmd == "/run?" then
      _G[(string.sub(path,6))](conn)
   elseif cmd == "/get?" then
      sendHttpResp(conn,pt,200)
      local s=_G[string.sub(path,6)]
      if s ~= nil then conn:send(s) end
   elseif cmd == "/set?" then
      sendHttpResp(conn,pt,200)
      local _,_,name,val = string.find(path,"/set.(.+)=(%w+)")
      if name ~= nil and val ~= nil then
	 if(type(_G[name]) == "number") then
	    _G[name] = tonumber(val)
	 else
	    _G[name] = val
	 end
      end
   elseif file.open(string.sub(path,2)) then
      sendHttpResp(conn,"text/html",200)
      fileOpen=true
      line=file.readline()
      conn:send(line)
   else
      sendHttpResp(conn,pt,200)
   end
   path=nil
   conn=nil
end

function handleSent(conn)
   line=nil
   tmr.wdclr()
   if fileOpen then line=file.readline() end
   if line then
      conn:send(line)
      line=nil
   else
      if(fileOpen) then 
--	 print("close f") 
	 file.close() 
      end
      fileOpen = nil
--      print("close s")
--      print(node.heap())
      conn:close()
      conn=nil
      collectgarbage("collect")
   end
   conn=nil
end

function handleConn(conn)
   conn:on("receive", handleReceive)
   conn:on("sent", handleSent)
end

websrv=net.createServer(net.TCP) 
websrv:listen(80, handleConn)
