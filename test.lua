--[[

    Notes:
        **Reading from the IO Registers can cause the PPU to not function properly.
        Hence, they lines for the code which does the same has been commented out.

]]


local torch = require 'torch'
local curses = require 'curses'
--local stdscr = curses.stdscr()

local function toBits(num)

    --returns a table of bits, least significant first
    local t = {}
    while num>0 do
        rest = math.fmod(num,2)
        t[#t+1]=rest
        num=(num-rest)/2
    end

    return table.concat(t)
end


local function cursesInit()

	curses.initscr() --start curses mode
	curses.raw() -- disable line buffering
	curses.echo(false) --switch off echoing

end

local function getPPURegisters()

    PPUTable = {}
    PPUTable.PPUControlReg1 = "PPUCR1    "..toBits(tonumber(memory.readbyte(0x2000)))
    PPUTable.PPUControlReg2 = "PPUCR2    "..toBits(tonumber(memory.readbyte(0x2001)))
    PPUTable.PPUStatusReg = "PPUStR    "..toBits(tonumber(memory.readbyte(0x2002)))
    PPUTable.SPRRAMAdReg = "SPRRAMAd  "..toBits(tonumber(memory.readbyte(0x2003)))..string.format(" 0x%x",memory.readbyte(0x2003))
    PPUTable.VRAMAddReg1 = "VRAMAdR1  "..toBits(tonumber(memory.readbytes(0x2005)))
    PPUTable.VRAMAddReg2 = "VRAMAdR2  "..toBits(tonumber(memory.readbyte(0x2006)))

    --PPUTable.VRAMIOReg = "VRAMIOR   "..toBits(tonumber(memory.readbyte(0x2007)))
    --PPUTable.SPRRAMIOReg = "SPRRAMIO  "..toBits(tonumber(memory.readbyte(0x2004)))

    return PPUTable

end

local function cursesPrintPPU()
    -- Taken up 5,5 to 12,5 space
	local stdscr = curses.stdscr()
	local PPURegs = getPPURegisters()
    local y=1
    local x=3
	stdscr:mvaddstr(y,x,PPURegs.PPUControlReg1)
	stdscr:mvaddstr(y+1,x,PPURegs.PPUControlReg2)
	stdscr:mvaddstr(y+2,x,PPURegs.PPUStatusReg)
	stdscr:mvaddstr(y+3,x,PPURegs.SPRRAMAdReg)
	--stdscr:mvaddstr(9,5,PPURegs.SPRRAMIOReg)
	stdscr:mvaddstr(y+4,x,PPURegs.VRAMAddReg1)
	stdscr:mvaddstr(y+5,x,PPURegs.VRAMAddReg2)
	--stdscr:mvaddstr(12,5,PPURegs.VRAMIOReg)
    stdscr:refresh()
	stdscr:clear()

end

local function cursesPrintOAM()

end

local function main()
	cursesInit()
	while true do
        cursesPrintPPU()
        gui.text(30,30,"nes")
		emu.frameadvance()
	end
	return(0)
end


main()
