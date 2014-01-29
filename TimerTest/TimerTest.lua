require "Wherigo"
ZonePoint = Wherigo.ZonePoint
Distance = Wherigo.Distance
Player = Wherigo.Player

-- String decode --
function _s621(str)
	local res = ""
    local dtable = "\021\001\084\014\098\024\047\008\051\087\003\096\111\061\054\058\022\005\095\090\086\100\012\112\081\080\063\076\064\027\115\070\048\038\089\067\028\079\068\118\039\025\023\102\088\101\013\077\116\062\092\104\126\052\007\124\103\060\119\015\105\091\121\072\114\085\043\020\093\037\057\017\082\050\019\059\073\046\110\040\018\065\069\004\109\042\074\030\000\108\066\113\031\053\026\055\035\045\083\106\049\044\010\036\107\117\029\056\097\006\011\120\016\078\034\094\002\125\032\009\041\075\123\071\099\122\033"
	for i=1, #str do
        local b = str:byte(i)
        if b > 0 and b <= 0x7F then
	        res = res .. string.char(dtable:byte(b))
        else
            res = res .. string.char(b)
        end
	end
	return res
end

-- Internal functions --
require "table"
require "math"

math.randomseed(os.time())
math.random()
math.random()
math.random()

_Urwigo = {}

_Urwigo.InlineRequireLoaded = {}
_Urwigo.InlineRequireRes = {}
_Urwigo.InlineRequire = function(moduleName)
  local res
  if _Urwigo.InlineRequireLoaded[moduleName] == nil then
    res = _Urwigo.InlineModuleFunc[moduleName]()
    _Urwigo.InlineRequireLoaded[moduleName] = 1
    _Urwigo.InlineRequireRes[moduleName] = res
  else
    res = _Urwigo.InlineRequireRes[moduleName]
  end
  return res
end

_Urwigo.Round = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end

_Urwigo.Ceil = function(num, idp)
  local mult = 10^(idp or 0)
  return math.ceil(num * mult) / mult
end

_Urwigo.Floor = function(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult) / mult
end

_Urwigo.DialogQueue = {}
_Urwigo.RunDialogs = function(callback)
	local dialogs = _Urwigo.DialogQueue
	local lastCallback = nil
	_Urwigo.DialogQueue = {}
	local msgcb = {}
	msgcb = function(action)
		if action ~= nil then
			if lastCallback ~= nil then
				lastCallback(action)
			end
			local entry = table.remove(dialogs, 1)
			if entry ~= nil then
				lastCallback = entry.Callback;
				if entry.Text ~= nil then
					Wherigo.MessageBox({Text = entry.Text, Media=entry.Media, Buttons=entry.Buttons, Callback=msgcb})
				else
					msgcb(action)
				end
			else
				if callback ~= nil then
					callback()
				end
			end
		end
	end
	msgcb(true) -- any non-null argument
end

_Urwigo.MessageBox = function(tbl)
    _Urwigo.RunDialogs(function() Wherigo.MessageBox(tbl) end)
end

_Urwigo.OldDialog = function(tbl)
    _Urwigo.RunDialogs(function() Wherigo.Dialog(tbl) end)
end

_Urwigo.Dialog = function(buffered, tbl, callback)
	for k,v in ipairs(tbl) do
		table.insert(_Urwigo.DialogQueue, v)
	end
	if callback ~= nil then
		table.insert(_Urwigo.DialogQueue, {Callback=callback})
	end
	if not buffered then
		_Urwigo.RunDialogs(nil)
	end
end

_Urwigo.Hash = function(str)
   local b = 378551;
   local a = 63689;
   local hash = 0;
   for i = 1, #str, 1 do
      hash = hash*a+string.byte(str,i);
      hash = math.fmod(hash, 65535)
      a = a*b;
      a = math.fmod(a, 65535)
   end
   return hash;
end

_Urwigo.DaysInMonth = {
	31,
	28,
	31,
	30,
	31,
	30,
	31,
	31,
	30,
	31,
	30,
	31,
}

_Urwigo_Date_IsLeapYear = function(year)
	if year % 400 == 0 then
		return true
	elseif year% 100 == 0 then
		return false
	elseif year % 4 == 0 then
		return true
	else
		return false
	end
end

_Urwigo.Date_DaysInMonth = function(year, month)
	if month ~= 2 then
		return _Urwigo.DaysInMonth[month];
	else
		if _Urwigo_Date_IsLeapYear(year) then
			return 29
		else
			return 28
		end
	end
end

_Urwigo.Date_DayInYear = function(t)
	local res = t.day
	for month = 1, t.month - 1 do
		res = res + _Urwigo.Date_DaysInMonth(t.year, month)
	end
	return res
end

_Urwigo.Date_HourInWeek = function(t)
	return t.hour + (t.wday-1) * 24
end

_Urwigo.Date_HourInMonth = function(t)
	return t.hour + t.day * 24
end

_Urwigo.Date_HourInYear = function(t)
	return t.hour + (_Urwigo.Date_DayInYear(t) - 1) * 24
end

_Urwigo.Date_MinuteInDay = function(t)
	return t.min + t.hour * 60
end

_Urwigo.Date_MinuteInWeek = function(t)
	return t.min + t.hour * 60 + (t.wday-1) * 1440;
end

_Urwigo.Date_MinuteInMonth = function(t)
	return t.min + t.hour * 60 + (t.day-1) * 1440;
end

_Urwigo.Date_MinuteInYear = function(t)
	return t.min + t.hour * 60 + (_Urwigo.Date_DayInYear(t) - 1) * 1440;
end

_Urwigo.Date_SecondInHour = function(t)
	return t.sec + t.min * 60
end

_Urwigo.Date_SecondInDay = function(t)
	return t.sec + t.min * 60 + t.hour * 3600
end

_Urwigo.Date_SecondInWeek = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (t.wday-1) * 86400
end

_Urwigo.Date_SecondInMonth = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (t.day-1) * 86400
end

_Urwigo.Date_SecondInYear = function(t)
	return t.sec + t.min * 60 + t.hour * 3600 + (_Urwigo.Date_DayInYear(t)-1) * 86400
end


-- Inlined modules --
_Urwigo.InlineModuleFunc = {}

cartTimerTest = Wherigo.ZCartridge()

-- Media --
objSoundTelefon = Wherigo.ZMedia(cartTimerTest)
objSoundTelefon.Id = "99aff44a-2c84-4821-9940-9d6c0fe218d9"
objSoundTelefon.Name = "SoundTelefon"
objSoundTelefon.Description = ""
objSoundTelefon.AltText = ""
objSoundTelefon.Resources = {
	{
		Type = "mp3", 
		Filename = "telefon.mp3", 
		Directives = {}
	}, 
	{
		Type = "fdl", 
		Filename = "garmin_telefon.fdl", 
		Directives = {}
	}
}
objSoundOK = Wherigo.ZMedia(cartTimerTest)
objSoundOK.Id = "370f4dae-22db-4bbd-8116-f4c30e5c3609"
objSoundOK.Name = "SoundOK"
objSoundOK.Description = ""
objSoundOK.AltText = ""
objSoundOK.Resources = {
	{
		Type = "mp3", 
		Filename = "ok.mp3", 
		Directives = {}
	}, 
	{
		Type = "fdl", 
		Filename = "garmin_ok.fdl", 
		Directives = {}
	}
}
-- Cartridge Info --
cartTimerTest.Id="b62b0e7f-67cf-43f0-ad37-c481e3d62380"
cartTimerTest.Name="TimerTest"
cartTimerTest.Description=[[Test of Timers

A Test Cartridge to test all aspects of timers.

Created by Jonny65]]
cartTimerTest.Visible=true
cartTimerTest.Activity="TourGuide"
cartTimerTest.StartingLocationDescription=[[]]
cartTimerTest.StartingLocation = ZonePoint(49.4916083147109,10.9548282623291,0)
cartTimerTest.Version=""
cartTimerTest.Company=""
cartTimerTest.Author="Jonny65"
cartTimerTest.BuilderVersion="URWIGO 1.15.4973.39887"
cartTimerTest.CreateDate="08/12/2012 11:22:53"
cartTimerTest.PublishDate="1/1/0001 12:00:00 AM"
cartTimerTest.UpdateDate="01/29/2014 08:44:23"
cartTimerTest.LastPlayedDate="1/1/0001 12:00:00 AM"
cartTimerTest.TargetDevice="PocketPC"
cartTimerTest.TargetDeviceVersion="0"
cartTimerTest.StateId="1"
cartTimerTest.CountryId="2"
cartTimerTest.Complete=false
cartTimerTest.UseLogging=true


-- Zones --

-- Characters --

-- Items --
zitemTimer1 = Wherigo.ZItem{
	Cartridge = cartTimerTest, 
	Container = Player
}
zitemTimer1.Id = "c6e65284-9d18-43fd-b1f6-49e4ad8d6f68"
zitemTimer1.Name = "Timer1"
zitemTimer1.Description = "Timertype Interval, Event OnStart, timer restarts every 4 seconds, Sound is played always in OnStart."
zitemTimer1.Visible = true
zitemTimer1.Commands = {
	cmdSTART = Wherigo.ZCommand{
		Text = "START", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
zitemTimer1.Commands.cmdSTART.Custom = true
zitemTimer1.Commands.cmdSTART.Id = "00baef09-02e9-4a2c-9c86-0f99a4c4314b"
zitemTimer1.Commands.cmdSTART.WorksWithAll = true
zitemTimer1.ObjectLocation = Wherigo.INVALID_ZONEPOINT
zitemTimer1.Locked = false
zitemTimer1.Opened = false
zitemTimer2 = Wherigo.ZItem{
	Cartridge = cartTimerTest, 
	Container = Player
}
zitemTimer2.Id = "c98cf6f0-818e-4b66-ad2c-34e031bcf3ff"
zitemTimer2.Name = "Timer2"
zitemTimer2.Description = "Timertype Interval, Event OnTick, Interval is 4 seconds."
zitemTimer2.Visible = true
zitemTimer2.Commands = {
	cmdSTART = Wherigo.ZCommand{
		Text = "START", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
zitemTimer2.Commands.cmdSTART.Custom = true
zitemTimer2.Commands.cmdSTART.Id = "98bc3f4c-d2e9-41ef-a1a9-84a6ac7a6a5d"
zitemTimer2.Commands.cmdSTART.WorksWithAll = true
zitemTimer2.ObjectLocation = Wherigo.INVALID_ZONEPOINT
zitemTimer2.Locked = false
zitemTimer2.Opened = false
zitemTimer3 = Wherigo.ZItem{
	Cartridge = cartTimerTest, 
	Container = Player
}
zitemTimer3.Id = "cf54e00c-b3bb-418e-a13d-d56695e0bdc2"
zitemTimer3.Name = "Timer3"
zitemTimer3.Description = "Timertype Countdown, Event OnTick, Timer restarts every second, each 4 seconds the sound is played."
zitemTimer3.Visible = true
zitemTimer3.Commands = {
	cmdSTART = Wherigo.ZCommand{
		Text = "START", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nothing available"
	}
}
zitemTimer3.Commands.cmdSTART.Custom = true
zitemTimer3.Commands.cmdSTART.Id = "f44a4b9b-e9df-46ce-8e4e-e51dd00dfac7"
zitemTimer3.Commands.cmdSTART.WorksWithAll = true
zitemTimer3.ObjectLocation = Wherigo.INVALID_ZONEPOINT
zitemTimer3.Locked = false
zitemTimer3.Opened = false

-- Tasks --

-- Cartridge Variables --
objCounterTelefon = 0
CR = ""
objEnergypoints = 100
objEnergyString = "Meine Energie : "
objCounterZeit = 10
currentZone = "dummy"
currentCharacter = "dummy"
currentItem = "zitemTimer1"
currentTask = "dummy"
currentInput = "dummy"
currentTimer = "ztimerTimer1"
cartTimerTest.ZVariables = {
	objCounterTelefon = 0, 
	CR = "", 
	objEnergypoints = 100, 
	objEnergyString = "Meine Energie : ", 
	objCounterZeit = 10, 
	currentZone = "dummy", 
	currentCharacter = "dummy", 
	currentItem = "zitemTimer1", 
	currentTask = "dummy", 
	currentInput = "dummy", 
	currentTimer = "ztimerTimer1"
}

-- Timers --
ztimerTimer1 = Wherigo.ZTimer(cartTimerTest)
ztimerTimer1.Id = "1cc0bd23-59a9-4fa6-b290-ebe43e502026"
ztimerTimer1.Name = "Timer1"
ztimerTimer1.Description = ""
ztimerTimer1.Visible = true
ztimerTimer1.Duration = 4
ztimerTimer1.Type = "Interval"
ztimerTimer2 = Wherigo.ZTimer(cartTimerTest)
ztimerTimer2.Id = "a0a273f5-8eb0-425a-93fe-2027e512dc7a"
ztimerTimer2.Name = "Timer2"
ztimerTimer2.Description = ""
ztimerTimer2.Visible = true
ztimerTimer2.Duration = 4
ztimerTimer2.Type = "Interval"
ztimerTimer3 = Wherigo.ZTimer(cartTimerTest)
ztimerTimer3.Id = "26a40fd5-d3e0-4e56-b6cb-874c8420012a"
ztimerTimer3.Name = "Timer3"
ztimerTimer3.Description = ""
ztimerTimer3.Visible = true
ztimerTimer3.Duration = 1
ztimerTimer3.Type = "Countdown"

-- Inputs --

-- WorksWithList for object commands --

-- functions --
function cartTimerTest:OnStart()
	if Wherigo.NoCaseEquals(string.sub(Env.Platform,1,6), "iPhone") then
		_Urwigo.MessageBox{
			Text = "iPhone wurde erkannt", 
			Callback = function(action)
				if action ~= nil then
					Wherigo.ShowScreen(Wherigo.MAINSCREEN)
				end
			end
		}
	else
		_Urwigo.MessageBox{
			Text = ((("Platform is "..(Env.Platform))..", Device is ")..(Env.Device))..[[.
]], 
			Callback = function(action)
				if action ~= nil then
					Wherigo.ShowScreen(Wherigo.MAINSCREEN)
				end
			end
		}
	end
end
function cartTimerTest:OnRestore()
end
function ztimerTimer1:OnStart()
	Wherigo.PlayAudio(objSoundTelefon)
end
function ztimerTimer1:OnStop()
	Wherigo.PlayAudio(objSoundOK)
end
function ztimerTimer2:OnStop()
	Wherigo.PlayAudio(objSoundOK)
end
function ztimerTimer2:OnTick()
	Wherigo.PlayAudio(objSoundTelefon)
end
function ztimerTimer3:OnStop()
	Wherigo.PlayAudio(objSoundOK)
end
function ztimerTimer3:OnTick()
	if objCounterTelefon == 4 then
		objCounterTelefon = 1
		Wherigo.PlayAudio(objSoundTelefon)
	else
		objCounterTelefon = objCounterTelefon + 1
	end
	ztimerTimer3:Start()
end
function zitemTimer1:OncmdSTART(target)
	ztimerTimer1:Start()
	_Urwigo.MessageBox{
		Text = "Timer1 should fire all 4 seconds until you press STOP. First ring is called from OnTick.", 
		Buttons = {
			"STOP"
		}, 
		Callback = function(action)
			if action ~= nil then
				Wherigo.Command "StopSound"
				ztimerTimer1:Stop()
			end
		end
	}
end
function zitemTimer2:OncmdSTART(target)
	Wherigo.PlayAudio(objSoundTelefon)
	ztimerTimer2:Start()
	_Urwigo.MessageBox{
		Text = "Timer2 should fire all 4 seconds until you press STOP. First ring is called from OnTick.", 
		Buttons = {
			"STOP"
		}, 
		Callback = function(action)
			if action ~= nil then
				Wherigo.Command "StopSound"
				ztimerTimer2:Stop()
			end
		end
	}
end
function zitemTimer3:OncmdSTART(target)
	objCounterTelefon = 1
	Wherigo.PlayAudio(objSoundTelefon)
	ztimerTimer3:Start()
	_Urwigo.MessageBox{
		Text = "Timer3 should fire all 4 seconds until you press STOP. First ring is called from OnTick.", 
		Buttons = {
			"STOP"
		}, 
		Callback = function(action)
			if action ~= nil then
				Wherigo.Command "StopSound"
				ztimerTimer3:Stop()
			end
		end
	}
end

-- Urwigo functions --

-- Begin user functions --
CR=[[
]]

-- End user functions --
return cartTimerTest
