local flowLayouter = {}
flowLayouter.__mt = {__index = flowLayouter}
function flowLayouter:new(direction, space, style)
  local self = setmetatable({},self.__mt)
  self.direction = direction or "horizontal"
  self.spacing = space or 5
  self.w,self.h = 0,0
  self.style = style
  return self
end

function flowLayouter:begin()
  self.x,self.y = 0,0
  if self.direction == "horizontal" then
    self.w = 0
  else
    self.h = 0
  end
  self.drawQueue = {}
end

function flowLayouter:preferredOffset()
  if self.style then
    return self.style.padding[3], self.style.padding[1]
  end
  return 0,0
end

function flowLayouter:preferredSize()
  if self.style then
    return self.style:preferredSize(self.w,self.h)
  end
  return self.w,self.h
end

function flowLayouter:eval(block)
  self.startx,self.starty = self.x,self.y
  block()
end

function flowLayouter:finish(draw)
  if draw then
    if self.style then
      local t,r,b,l = unpack(self.style.padding)
      self.style:draw(nil,self.startx - l,self.starty - t,self.w + l + r,self.h + t + b)
    end
    for i=#self.drawQueue,1,-1 do
      self.drawQueue[i]()
    end
  end
end

function flowLayouter:layout(x,y,w,h,pw,ph,draw)
  self.drawQueue[#self.drawQueue+1] = draw
  x,y = self.x,self.y
  if self.direction == "horizontal" then
    self.x = self.x + self.spacing + pw
    self.h = math.max(self.h, ph)
    self.w = self.w + pw + self.spacing
    return x,y,pw,self.h
  else
    self.y = self.y + self.spacing + ph
    self.w = math.max(self.w, pw)
    self.h = self.h + ph + self.spacing
    return x,y,self.w,h
  end
end

return flowLayouter