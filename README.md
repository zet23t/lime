This is a simple test that might be interesting or others as well, thus publishing it on github.

License: MIT

# Anecdote of initial development

I woke up with the idea in my head at 4 o'clock in the morning, that I could not get rid of over the day:
How hard could it be to build an immediate GUI system?

So in the end I couldn't resist to look into this... I quickly slapped together a bit of code and got something sort of working: Buttons. In a simple flow layout - but with expanding sizes relative to the largest element in the current column / row. 

I only looked at this from the perspective of a Unity IMGui user - I don't really know how an actual immediate GUI system should work, so I had to come up with some things myself. I know that the responsible code for defining the visible UI must be run several times to produce an output. So there must be several phases (if you want automatic layouts). I came up with three phases: 

1) Prepare: Run through the gui code and gather what layouts and widgets exist. The widgets know their preferred sizes, the layouts will know at the end of the phase what their preferred sizes are. One trick is to cache the layout objects to memorize the results from this pass.
2) Draw: Running again, but this time letting the actual on-screen coordinates are calculated, defined by the active layouting logic. This part must make sure that overlapping UIs consume and block events accordingly - so that a mouse cursor can only highlight and press the topmost elements. I've decided to draw front-to-back ordered because this way the first logic that blocks the mouse will consume the event and followup code will know this and draw it accordingly. So for that purpose, the draw calls are gathered and executed after this phase for each layout logic. I am not sure how overlapping layouts would handle this.
3) Event phase: After drawing, the actual events are triggered and something like "if button(...) then " yields true when the button is pressed.

All in all it was an interesting exercise. I am tempted to add widgets such as toggles, sliders and input fields. It shouldn't be hard to do since it's similar to the button logic.

What's actual harder about it is to make the layouting "smarter". Something like right / left alignments or the ability to set preferred sizes for layouts. But currently I don't see why this should be more complicated. 