local font = love.graphics.newFont("fonts/Roboto-regular.ttf", 18);

local function isInsideRange(px,x,w)
  local rel = (px - x) 
  return rel >= 0 and rel < w
end

local function isInsideRect(px,py,x,y,w,h)
    return isInsideRange(px,x,w) and isInsideRange(py,y,h)
end

local roundedRectStyle = require "lime.style.roundedRect"
local flowLayouter = require "lime.layouter.flow"
local plainLayouter = require "lime.layouter.plain"

local buttonPad = {5,15,5,15}

lime = {
  mousePressDistanceThreshold = 5;
  previousState = {};
  layouter = plainLayouter:new();
  styles = {
    button = {
      pressed = roundedRectStyle:new(5,{255,255,255},{220,100,100},font,buttonPad);
      normal = roundedRectStyle:new(5,{40,40,40},{230,230,230}, font,buttonPad);
      hover = roundedRectStyle:new(5,{40,40,40},{250,250,250},font,buttonPad);
    };
    panel = roundedRectStyle:new(10,{40,40,40},{180,180,230},font,{10,10,10,10});
  }
}

function lime:render(block)
  self:update()
  self.cacheData = {}
  -- phases: Prepare -> Layout -> Draw -> Event
  local function phase(p)
    self.cacheRun = 1
    self.phase = p
    block()
    return phase
  end
  local function phaseReset(p)
    self.currentState.isBlocked = false
    self.currentState.isConsumed = false
    phase(p)
    return phaseReset
  end
  phase "layout"
  phaseReset "draw" "event"
end

function lime:cache(obj)
  self.cacheRun = self.cacheRun + 1
  if not self.cacheData[self.cacheRun - 1] then
    self.cacheData[self.cacheRun - 1] = obj
    return obj
  end
  return self.cacheData[self.cacheRun - 1]
end

function lime:update()
  self.layouter:begin()
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
  pw,ph = math.max(pw,w),math.max(ph,h)
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
  if isOver and not self.currentState.isBlocked then
    if pressedDownFirst and pressedDownNow then
      style = self.styles.button.pressed
      self.currentState.isConsumed = true
    else
      style = self.styles.button.hover
    end
    self.currentState.isBlocked = true
  end
  
  return self.phase == "event" and isOver and pressedDownFirst and not pressedDownNow
end

function lime:layout(layouter, block)
  layouter = self:cache(layouter)
  local prevLayout = self.layouter
  self.layouter = layouter
  self.layouter:begin()
  local pw,ph = layouter:preferredSize()
  local ox,oy = layouter:preferredOffset()
  layouter.x,layouter.y = prevLayout:layout(layouter.x,layouter.y, pw,ph,pw,ph)
  layouter.x = layouter.x + ox
  layouter.y = layouter.y + oy
  layouter:eval(block)
  self.layouter:finish(self.phase == "draw")
  self.layouter = prevLayout
end

function lime:finish()
  self.layouter:finish()
end


local state = 1
local msg = {"long hello button","toggle","on","off"}
function love.draw()
  lime:render(
    function() 
      lime:layout(flowLayouter:new("vertical"),function()
        lime:layout(flowLayouter:new "horizontal",function()
            for i=1,5 do lime:button("Top row: #"..i) end
          end)
        lime:layout(flowLayouter:new("horizontal"),function()
          lime:button("left column high button",0,0,100,100)
          
          lime:layout(flowLayouter:new("vertical",nil, lime.styles.panel),function()
            lime:button("a")
            if lime:button(msg[state]) then
              state = state + 1
              if state > #msg then state = 1 end
              --love.graphics.rectangle("fill",200,10,20,20,5,5,3)
            end
            if lime:button("yip") then
            end
            lime:button("yo")
          end)
        end)
      end)
    end
  )
end

function love.keypressed(key)
  if key == "escape" then
    love.event.quit()
  end
end