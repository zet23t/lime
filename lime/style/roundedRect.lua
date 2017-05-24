local roundedRectStyle = {}
roundedRectStyle.__mt = {__index = roundedRectStyle}

function roundedRectStyle:new(r, colorText, colorRect, font, padding)
  local self = setmetatable({}, self.__mt)
  self.r = r
  self.colorText = colorText
  self.colorRect = colorRect
  self.padding = padding or {0,0,0,0}
  self.font = font
  return self
end

function roundedRectStyle:preferredSize(text)
  local tw = self.font:getWidth(text)
  local th = self.font:getHeight()
  local t,r,b,l = unpack(self.padding)
  return tw + r + l, th + t + b
end

function roundedRectStyle:draw(text,x,y,w,h)
  love.graphics.setFont(self.font)
  love.graphics.setColor(self.colorRect)
  love.graphics.rectangle("fill",x,y,w,h,self.r,self.r,3)
  love.graphics.setColor(self.colorText)
  local tw = self.font:getWidth(text)
  local th = self.font:getHeight()
  love.graphics.print(text,x+math.floor((w-tw)/2),math.floor(y+(h-th)/2)-1)
end
return roundedRectStyle