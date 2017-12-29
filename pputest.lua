require 'ppu'
require 'curses'

curses.initscr() --start curses mode
curses.raw() -- disable line buffering
curses.echo(false) --switch off echoing


local function getPatternTable()
	local tables = {}
	tables.left = ppu.readbytes(0x0000,0x0FFF)
	tables.right = ppu.readbytes(0x1000,0x0FFF)
end

local function cursesLeftPatternTable()
	pati = 0
	stdscr = curses.stdscr()
	height,width = stdscr:getmaxyx()
	pat = ppu.readleftpatterntable()
	--print(ppu.readpatterntable())

	for y=0,height do
		for x=0,width/2 do
			stdscr:mvaddstr(y,x+2*x,string.format("%x",pat[pati]))
			pati = pati+1
		end
	end

end


local function cursesRightPatternTable()
	pati = 0
	stdscr = curses.stdscr()
	height,width = stdscr:getmaxyx()
	pat = ppu.readrightpatterntable()
	--print(ppu.readpatterntable())

	for y=0,height do
		for x=0,width/2 do
			stdscr:mvaddstr(y,x+2*x,string.format("%x",pat[pati]))
			pati = pati+1
		end
	end
end

local function cursesRefresh()
	stdscr = curses.stdscr()
	stdscr:refresh()
	stdscr:clear()
end


while true do
	cursesLeftPatternTable()
	cursesRightPatternTable()
	cursesRefresh()
	emu.frameadvance()
end