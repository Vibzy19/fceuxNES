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
    PPUTable.SPRRAMAdReg = "SPRRAMAd  "..toBits(tonumber(memory.readbyte(0x2003)))
    --PPUTable.SPRRAMIOReg = "SPRRAMIO  "..toBits(tonumber(memory.readbyte(0x2004)))
    PPUTable.VRAMAddReg1 = "VRAMAdR1  "..toBits(tonumber(memory.readbyte(0x2005)))
    PPUTable.VRAMAddReg2 = "VRAMAdR2  "..toBits(tonumber(memory.readbyte(0x2006)))
    --PPUTable.VRAMIOReg = "VRAMIOR   "..toBits(tonumber(memory.readbyte(0x2007)))

    return PPUTable

end



local function cursesPrintPPU()
    -- Taken up 5,5 to 12,5 space
	local stdscr = curses.stdscr()
	local PPURegs = getPPURegisters()
	stdscr:mvaddstr(5,5,PPURegs.PPUControlReg1)
	stdscr:mvaddstr(6,5,PPURegs.PPUControlReg2)
	stdscr:mvaddstr(7,5,PPURegs.PPUStatusReg)
	stdscr:mvaddstr(8,5,PPURegs.SPRRAMAdReg)
	--stdscr:mvaddstr(9,5,PPURegs.SPRRAMIOReg)
	stdscr:mvaddstr(10,5,PPURegs.VRAMAddReg1)
	stdscr:mvaddstr(11,5,PPURegs.VRAMAddReg2)
	--stdscr:mvaddstr(12,5,PPURegs.VRAMIOReg)
    stdscr:refresh()
	stdscr:clear()

end

local function main()
	cursesInit()
	while true do
        cursesPrintPPU()
		gui.text(30,30,"Life is a biatch")
		emu.frameadvance()
	end
	return(0)
end


main()
