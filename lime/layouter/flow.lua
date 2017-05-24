local flowLayouter = {}
flowLayouter.__mt = {__index = flowLayouter}
function flowLayouter:new()
  local self = setmetatable({},self.__mt)
  return self
end

function flowLayouter:begin()
  
  self.drawQueue = {}
end

function flowLayouter:finish()
  for i=#self.drawQueue,1,-1 do
    self.drawQueue[i]()
  end
end

function flowLayouter:layout(x,y,w,h,pw,ph,draw)
  self.drawQueue[#self.drawQueue+1] = draw
  return x,y,w,h
end

return flowLayouter