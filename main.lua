--Attack of the Drones
--Sara Levine
--Coded for CCTP645 Poetics of Mobile
--Could not have finished this code without the following:
--http://docs.coronalabs.com/api/type/Map/index.html
--http://developer.coronalabs.com/content/application-programming-guide-graphics-and-drawing
--https://docs.coronalabs.com/api/library/native/newMapView.html
--https://developer.coronalabs.com/code/orbital-rotation
--http://docs.coronalabs.com/guide/events/touchMultitouch/index.html
--http://docs.coronalabs.com/guide/events/detectEvents/index.html
--https://docs.coronalabs.com/api/type/DisplayObject/alpha.html
--http://forums.coronalabs.com/topic/34137-how-to-set-timer-on-game-screen/
--https://docs.coronalabs.com/api/library/audio/play.html
display.setStatusBar(display.HiddenStatusBar)
local explodeSound = audio.loadSound("explosion.wav")
--The following code is related to the GPS map part of the app. I used static replacements so that I could test the game in the Simulator, but it shouldn't be too difficult to alter the code so that it works on an iPhone. 
--Also, you would need to turn off the tempBG and the tempMarker. Instead, the drones should revolve around the locationTable (the getUserLocation()). Anything that says tempMarker should be replaced after it is removed. 
local myMap = native.newMapView( 0, 0, display.contentWidth, display.contentHeight)
local isLocVisible = myMap.isLocationVisible
local locationTable = myMap:getUserLocation()
--locate addresses or landmarks
--lat, long = myMap:getAddressLocation( "Eiffel Tower")
--myMap:setCenter( lat, long )
--all map types
--myMap.mapType = "normal"
--myMap.mapType = "hybrid"
--myMap.mapType = "satellite"
--map markers with custom labels
--myMap:addMarker( lat, long, { title="Big Tower", subtitle="It's in France" } )
--convert locations to addresses
--myMap:nearestAddress( lat, long )

--This is what shows up when the user wins the game.
local function success ()
	local successBlock=display.newRect(display.contentWidth*.5,display.contentHeight*.5,800,1500)
	successBlock:setFillColor(0,0,0)
	local successText = display.newText("You Won!",display.contentCenterX,200,native.SystemFontBold,50)
end

--This sets up variables to be used later, including the counter for the timer and physics.
local counter=15
local physics = require("physics")
physics.start()
physics.setGravity(0,0)

--This is a temporary background to be used on the Simulator.
local tempBG = display.newImage("tempBG.png")
tempBG:translate(100,280)

--This is a temporary user marker to be used on the Simulator.
local tempMarker = display.newRect(display.contentWidth*.5,display.contentHeight*.5,10,10)
tempMarker:setFillColor(0,0,255)
physics.addBody(tempMarker, {radius=40})
tempMarker.bodyType="static"

--This is the first drone, the biggest drone. 
local drone1 = display.newImage("big-drone.png")
drone1:scale(.13,.13)
drone1.x=tempMarker.x+75
drone1.y=tempMarker.y
drone1.rotation = 180
physics.addBody(drone1,{radius=16})
drone1.bodyType="dynamic"

--This is the second drone, the medium sized one.
local drone2 = display.newImage("med-drone.png")
drone2:scale(.1,.1)
drone2.x=tempMarker.x+120
drone2.y=tempMarker.y
drone2.rotation=180
physics.addBody(drone2,{radius=16})
drone2.bodyType="dynamic"

--This is the third drone, the smallest and fastest one.
local drone3 = display.newImage("small-drone.png")
drone3:scale(.1,.1)
drone3.x=tempMarker.x+140
drone3.y=tempMarker.y
drone3.rotation=180
physics.addBody(drone3,{radius=16})
drone3.bodyType="dynamic"

--This tap listener is just for the first drone. If the first drone is tapped then it will become invisible, the counter adds ten seconds, and a sound plays. If it is the last drone to be destroyed then the user wins the game.
local function myTapListener (self,event)
	if(event.phase=="began") then
		drone1.alpha=0
		counter=10+counter-1
		local explodeChannel=audio.play(explodeSound)	
	end
	if drone1.alpha==0 and
		drone2.alpha==0 and
		drone3.alpha==0 then
		success()
	end
	return true
end

drone1.touch=myTapListener
drone1:addEventListener("touch",drone1)

--This tap listener is just for the second drone. If the second drone is tapped then it will become invisible, the counter adds ten seconds, and a sound plays. If it is the last drone to be destroyed then the user wins the game.
local function myTwoTapListener (self, event)
	if (event.phase=="began") then
		drone2.alpha=0
		counter=20+counter-1
		local explodeChannel=audio.play(explodeSound)
	end
	if drone1.alpha==0 and
		drone2.alpha==0 and
		drone3.alpha==0 then
		success()
	end
	return true
end

drone2.touch=myTwoTapListener
drone2:addEventListener("touch",drone2)

--This tap listener is just for the third drone. If the third drone is tapped then it will become invisible, the counter adds ten seconds, and a sound plays. If it is the last drone to be destroyed then the user wins the game.
local function myThreeTapListener (self, event)
	if(event.phase=="began") then
		drone3.alpha=0
		counter=30+counter-1
		local explodeChannel=audio.play(explodeSound)
	end
	if drone1.alpha==0 and
		drone2.alpha==0 and
		drone3.alpha==0 then
		success()
	end
	return true
end

drone3.touch=myThreeTapListener
drone3:addEventListener("touch",drone3)


--The following code sets up the physics for the rotating drones. Each one operates on its own "joint" and revolves around the tempMarker.
myJoint = physics.newJoint("pivot",drone1,tempMarker,tempMarker.x,tempMarker.y)
anotherJoint = physics.newJoint("pivot",drone2,tempMarker,tempMarker.x,tempMarker.y)
thirdJoint = physics.newJoint("pivot",drone3,tempMarker,tempMarker.x,tempMarker.y)
local rotateIt = function (event )
drone1.rotation = drone1.rotation+20
drone2.rotation = drone2.rotation+28
drone3.rotation = drone3.rotation+36
end
Runtime:addEventListener("enterFrame",rotateIt)

--This is for the counter. It displays the text on the screen.
local timeDisplay = display.newText(counter,0,0,native.systemFontBold,64)
timeDisplay:setFillColor(0,0,0)
timeDisplay.x=display.contentCenterX
timeDisplay.y=100

--This function updates the counter. If the counter reaches zero then the user has lost the game.
local function updateTimer(event)
	counter = counter - 1
	timeDisplay.text = counter
	if counter == 0 then
		local endScreen = display.newRect(display.contentWidth*.5,display.contentHeight*.5,800,1500)
		endScreen:setFillColor(0,0,0)
		local endText = display.newText("Game Over",display.contentCenterX,200,native.SystemFontBold,50)
	end
end
timer.performWithDelay(1000,updateTimer,60)


