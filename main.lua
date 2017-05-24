local font = love.graphics.newFont("fonts/calibril.ttf", 18);

local function isInsideRange(px,x,w)
  local rel = (px - x) 
  return rel >= 0 and rel < w
end

local function isInsideRect(px,py,x,y,w,h)
    return isInsideRange(px,x,w) and isInsideRange(py,y,h)
end

local roundedRectStyle = require "lime.style.roundedRect"
local flowLayouter = require "lime.layouter.flow"

local buttonPad = {5,15,5,15}

lime = {
  mousePressDistanceThreshold = 5;
  previousState = {};
  styles = {
    button = {
      pressed = roundedRectStyle:new(5,{255,255,255},{220,100,100},font,buttonPad);
      normal = roundedRectStyle:new(5,{40,40,40},{230,230,230}, font,buttonPad);
      hover = roundedRectStyle:new(5,{40,40,40},{250,250,250},font,buttonPad);
    }
  }
}

function lime:update()
  if self.currentState then
    self.previousState = self.currentState
  end
  self.currentState = {}
  self.currentState.mousePos = {love.mouse.getPosition()}
  self.currentState.isMouseDown = love.mouse.isDown(1)
  if not self.previousState.isMouseDown and self.currentState.isMouseDown then
    self.currentState.mouseFirstPressPosition = self.currentState.mousePos
  elseif self.currentState.isMouseDown then
    self.currentState.mouseFirstPressPosition = self.previousState.mouseFirstPressPosition
  end
end

function lime:wasMouseReleased()
  return self.previousState.isMouseDown and not self.currentState.isMouseDown
end

function lime:wasMousePressed()
  if self:wasMouseReleased() then
    local p0,pnow = self.currentState.mouseFirstPressPosition, self.currentState.mousePos
    local dx,dy = p0[1] - pnow[1], p0[2] - pnow[2]
    local dist = dx * dx + dy * dy
    return dist < self.mousePressDistanceThreshold ^ 2
  end
end

function lime:button(text,x,y,w,h)
  local style = self.styles.button.normal
  local pw,ph = lime.styles.button.normal:preferredSize(text) 
  if not w then
    w,h = pw,ph
  end
  x,y,w,h = self.layouter:layout(x,y,w,h,pw,ph,
      function()
        style:draw(text,x,y,w,h)
      end)
  local mx,my = love.mouse.getPosition()
  local isOver = isInsideRect(mx,my,x,y,w,h)
  local function checkPressed(pos)
    return pos and isInsideRect(pos[1],pos[2],x,y,w,h)
  end
  local pressedDownNow, pressedDownFirst = 
    self.currentState.isMouseDown and not self.currentState.isConsumed and checkPressed(self.currentState.mousePos), 
    checkPressed(self.previousState.mouseFirstPressPosition)
  love.graphics.setFont(font)
  if isOver and not self.currentState.isBlocked then
    if pressedDownFirst and pressedDownNow then
      style = self.styles.button.pressed
      self.currentState.isConsumed = true
    else
      style = self.styles.button.hover
    end
    self.currentState.isBlocked = true
  end
  
  
  
  return isOver and pressedDownFirst and not pressedDownNow
end

function lime:layout(layouter, block)
  local prevLayout = self.layouter
  self.layouter = layouter
  self.layouter:begin()
  block()
  self.layouter:finish()
  self.layouter = prevLayout
end

function love.draw()
  lime:update()
  lime:layout(flowLayouter:new(),function()
    if lime:button("hello button",10,10) then
      love.graphics.setColor(255,255,255)
      love.graphics.rectangle("fill",200,10,20,20,5,5,3)
    end
    if lime:button("yip",10,30) then
    end
    
  end)
  
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end