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

function roundedRectStyle:preferredSize(text,w,h)
  local tw = text and self.font:getWidth(text) or 0
  local th = text and self.font:getHeight() or 0
  local t,r,b,l = unpack(self.padding)
  return math.max(tw, w or 0) + r + l, math.max(th, h or 0) + t + b
end

function roundedRectStyle:draw(text,x,y,w,h)
  love.graphics.setColor(self.colorRect)
  love.graphics.rectangle("fill",x,y,w,h,self.r,self.r,3)
  if text then
    love.graphics.setFont(self.font)
    love.graphics.setColor(self.colorText)
    local tw = self.font:getWidth(text)
    local th = self.font:getHeight()
    love.graphics.print(text,x+math.floor((w-tw)/2),math.floor(y+(h-th)/2)-1)
  end
end
return roundedRectStyle