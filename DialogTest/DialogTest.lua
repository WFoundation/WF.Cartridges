require "Wherigo"
ZonePoint = Wherigo.ZonePoint
Distance = Wherigo.Distance
Player = Wherigo.Player

-- String decode --
function _yOC(str)
	local res = ""
    local dtable = "\087\072\035\069\005\078\046\025\001\106\112\041\120\113\068\082\081\105\014\061\110\052\057\056\027\119\023\030\102\114\055\051\115\065\033\097\015\067\049\064\086\074\037\117\077\043\004\079\028\021\048\040\018\122\019\039\044\089\111\008\123\080\034\121\091\094\013\036\073\047\126\063\045\093\104\003\116\054\092\083\016\058\124\108\075\053\109\020\085\006\011\101\012\107\084\022\118\060\066\026\059\031\071\100\010\042\029\076\032\088\050\099\090\096\038\095\125\000\002\024\009\103\017\098\070\062\007"
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

objDialogTest = Wherigo.ZCartridge()

-- Media --
objName = Wherigo.ZMedia(objDialogTest)
objName.Id = "9825df77-1c29-4ace-b334-4c50dd8b87bf"
objName.Name = "Name"
objName.Description = ""
objName.AltText = ""
objName.Resources = {
	{
		Type = "jpg", 
		Filename = "Icon.jpg", 
		Directives = {}
	}
}
objImage = Wherigo.ZMedia(objDialogTest)
objImage.Id = "9dd02cdc-03d9-43ef-851b-5eb3129cebc9"
objImage.Name = "Image"
objImage.Description = ""
objImage.AltText = ""
objImage.Resources = {
	{
		Type = "jpg", 
		Filename = "Image.jpg", 
		Directives = {}
	}
}
-- Cartridge Info --
objDialogTest.Id="5be78e2c-7594-48e2-a29f-5ca73b1f4763"
objDialogTest.Name="DialogTest"
objDialogTest.Description=[[Test cartridge for MessageBoxes and Dialogs]]
objDialogTest.Visible=true
objDialogTest.Activity="TourGuide"
objDialogTest.StartingLocationDescription=[[]]
objDialogTest.StartingLocation = Wherigo.INVALID_ZONEPOINT
objDialogTest.Version=""
objDialogTest.Company=""
objDialogTest.Author=""
objDialogTest.BuilderVersion="URWIGO 1.15.4973.39887"
objDialogTest.CreateDate="01/29/2014 11:11:22"
objDialogTest.PublishDate="1/1/0001 12:00:00 AM"
objDialogTest.UpdateDate="01/29/2014 12:05:40"
objDialogTest.LastPlayedDate="1/1/0001 12:00:00 AM"
objDialogTest.TargetDevice="PocketPC"
objDialogTest.TargetDeviceVersion="0"
objDialogTest.StateId="1"
objDialogTest.CountryId="2"
objDialogTest.Complete=false
objDialogTest.UseLogging=true


-- Zones --

-- Characters --

-- Items --
objMessageBox0buttons = Wherigo.ZItem{
	Cartridge = objDialogTest, 
	Container = Player
}
objMessageBox0buttons.Id = "eb302f4e-1cf4-468e-b6b8-62b736f1064f"
objMessageBox0buttons.Name = "MessageBox 0 buttons"
objMessageBox0buttons.Description = "MessageBox with no button"
objMessageBox0buttons.Visible = true
objMessageBox0buttons.Commands = {
	cmdDisplay = Wherigo.ZCommand{
		Text = "Display", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nicht verfugbar"
	}
}
objMessageBox0buttons.Commands.cmdDisplay.Custom = true
objMessageBox0buttons.Commands.cmdDisplay.Id = "74e00900-3be0-43ad-b82d-da11677388c2"
objMessageBox0buttons.Commands.cmdDisplay.WorksWithAll = true
objMessageBox0buttons.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objMessageBox0buttons.Locked = false
objMessageBox0buttons.Opened = false
objMessageBox1button = Wherigo.ZItem{
	Cartridge = objDialogTest, 
	Container = Player
}
objMessageBox1button.Id = "95a466c8-00b0-4639-bc55-255821856ddb"
objMessageBox1button.Name = "MessageBox 1 button"
objMessageBox1button.Description = "MessageBox with one button"
objMessageBox1button.Visible = true
objMessageBox1button.Commands = {
	cmdDisplay = Wherigo.ZCommand{
		Text = "Display", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nicht verfugbar"
	}
}
objMessageBox1button.Commands.cmdDisplay.Custom = true
objMessageBox1button.Commands.cmdDisplay.Id = "307dc2b7-aa54-4cbc-86dd-8306c4f6cd3a"
objMessageBox1button.Commands.cmdDisplay.WorksWithAll = true
objMessageBox1button.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objMessageBox1button.Locked = false
objMessageBox1button.Opened = false
objMessageBox2buttons = Wherigo.ZItem{
	Cartridge = objDialogTest, 
	Container = Player
}
objMessageBox2buttons.Id = "4a5a0af9-9ad0-491e-b9d1-346fafb45964"
objMessageBox2buttons.Name = "MessageBox 2 buttons"
objMessageBox2buttons.Description = "MessageBox with two buttons"
objMessageBox2buttons.Visible = true
objMessageBox2buttons.Commands = {
	cmdDisplay = Wherigo.ZCommand{
		Text = "Display", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nicht verfugbar"
	}
}
objMessageBox2buttons.Commands.cmdDisplay.Custom = true
objMessageBox2buttons.Commands.cmdDisplay.Id = "caa28a4e-cf95-42fd-bbf2-fc66d0a261d2"
objMessageBox2buttons.Commands.cmdDisplay.WorksWithAll = true
objMessageBox2buttons.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objMessageBox2buttons.Locked = false
objMessageBox2buttons.Opened = false
objDialog = Wherigo.ZItem{
	Cartridge = objDialogTest, 
	Container = Player
}
objDialog.Id = "bf783ef8-8d0a-4d64-a685-b14c3f9d591c"
objDialog.Name = "Dialog"
objDialog.Description = "Three Dialog screens without any Action between"
objDialog.Visible = true
objDialog.Commands = {
	cmdDisplay = Wherigo.ZCommand{
		Text = "Display", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nicht verfugbar"
	}
}
objDialog.Commands.cmdDisplay.Custom = true
objDialog.Commands.cmdDisplay.Id = "6d0ea2c0-620a-46c0-8234-e6e0f7dfd3a3"
objDialog.Commands.cmdDisplay.WorksWithAll = true
objDialog.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objDialog.Locked = false
objDialog.Opened = false
objActionDialog = Wherigo.ZItem{
	Cartridge = objDialogTest, 
	Container = Player
}
objActionDialog.Id = "db07408c-c95c-460c-8160-1875436206ff"
objActionDialog.Name = "Action Dialog"
objActionDialog.Description = "Three Dialog screens with Action between. Variable IncVar is incremented two times, should have value 2 at the end."
objActionDialog.Visible = true
objActionDialog.Commands = {
	cmdDisplay = Wherigo.ZCommand{
		Text = "Display", 
		CmdWith = false, 
		Enabled = true, 
		EmptyTargetListText = "Nicht verfugbar"
	}
}
objActionDialog.Commands.cmdDisplay.Custom = true
objActionDialog.Commands.cmdDisplay.Id = "a23b313a-7090-4b20-93d2-ee96734f07d3"
objActionDialog.Commands.cmdDisplay.WorksWithAll = true
objActionDialog.ObjectLocation = Wherigo.INVALID_ZONEPOINT
objActionDialog.Locked = false
objActionDialog.Opened = false

-- Tasks --

-- Cartridge Variables --
incVar = 0
currentZone = "dummy"
currentCharacter = "dummy"
currentItem = "objMessageBox0buttons"
currentTask = "dummy"
currentInput = "dummy"
currentTimer = "dummy"
objDialogTest.ZVariables = {
	incVar = 0, 
	currentZone = "dummy", 
	currentCharacter = "dummy", 
	currentItem = "objMessageBox0buttons", 
	currentTask = "dummy", 
	currentInput = "dummy", 
	currentTimer = "dummy"
}

-- Timers --

-- Inputs --

-- WorksWithList for object commands --

-- functions --
function objDialogTest:OnStart()
end
function objDialogTest:OnRestore()
end
function objMessageBox0buttons:OncmdDisplay(target)
	_Urwigo.MessageBox{
		Text = "This is a MessageBox without buttons, so that the default button should be shown"
	}
end
function objMessageBox1button:OncmdDisplay(target)
	_Urwigo.MessageBox{
		Text = "This is a MessageBox with one button", 
		Buttons = {
			"Button 1"
		}, 
		Callback = function(action)
			if (action == "Button1") == true then
				_Urwigo.MessageBox{
					Text = "Button 1 clicked"
				}
			elseif (action == nil) == true then
				_Urwigo.MessageBox{
					Text = "MessageBox was canceled"
				}
			else
				_Urwigo.MessageBox{
					Text = "Undefined result"
				}
			end
		end
	}
end
function objMessageBox2buttons:OncmdDisplay(target)
	_Urwigo.MessageBox{
		Text = "This is a MessageBox with two buttons", 
		Buttons = {
			"Button 1", 
			"Button 2"
		}, 
		Callback = function(action)
			if (action == "Button1") == true then
				_Urwigo.MessageBox{
					Text = "Button 1 was selected"
				}
			elseif (action == "Button2") == true then
				_Urwigo.MessageBox{
					Text = "Button 2 was selected"
				}
			elseif (action == nil) == true then
				_Urwigo.MessageBox{
					Text = "MessageBox was canceled"
				}
			else
				_Urwigo.MessageBox{
					Text = "Undefined result"
				}
			end
		end
	}
end
function objDialog:OncmdDisplay(target)
	_Urwigo.OldDialog{
		{
			Text = "Dialog 1 (with image)", 
			Media = objImage
		}, 
		{
			Text = "Dialog 2 (without image)"
		}, 
		{
			Text = "Dialog 3 (with image)", 
			Media = objImage
		}
	}
end
function objActionDialog:OncmdDisplay(target)
	ActionDialog()
end

-- Urwigo functions --

-- Begin user functions --
function ActionDialog()
  incVar = 0
  CR = [[
]]
  Wherigo.Dialog{
		{
			Text = "Dialog 1 (with image)", 
			Media = objImage,
			Action = function () incVar = incVar + 1 end
		}, 
		{
			Text = "Dialog 2 (without image)",
			Action = function () incVar = incVar + 1 end
		}, 
		{
			Text = "Dialog 3 (with image)"..CR.."incVar is "..incVar.." and should be 2, if the Action is working", 
			Media = objImage
		}
	}
end
-- End user functions --
return objDialogTest
