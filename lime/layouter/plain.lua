local plainLayouter = {}
plainLayouter.__mt = {__index = plainLayouter}
function plainLayouter:new(space)
  local self = setmetatable({},self.__mt)
  return self
end

function plainLayouter:begin()
  self.drawQueue = {}
end

function plainLayouter:finish(draw)
  if draw then
    for i=#self.drawQueue,1,-1 do
      self.drawQueue[i]()
    end
  end
end

function plainLayouter:eval(block)
  self.startx,self.starty = self.x,self.y
  block()
end


function plainLayouter:layout(x,y,w,h,pw,ph,draw)
  return x,y,w,h
end

return plainLayouter