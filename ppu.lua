ppu = {}

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

local function bitsToDec(bin)

	bin = string.reverse(bin) 
	local sum = 0 
	for i = 1, string.len(bin) do 
		num = string.sub(bin, i,i) == "1" and 1 or 0 
		sum = sum + num * math.pow(2, i-1) 
	end 
	return (sum)

end

local function getPPURegisters()

    PPUTable = {}
    PPUTable.controlReg1 = toBits(tonumber(memory.readbyte(0x2000)))
    PPUTable.controlReg2 = toBits(tonumber(memory.readbyte(0x2001)))
    PPUTable.statusReg = toBits(tonumber(memory.readbyte(0x2002)))
    PPUTable.PRRAMAdReg = toBits(tonumber(memory.readbyte(0x2003)))--..string.format(" 0x%x",memory.readbyte(0x2003))
    PPUTable.VRAMAddReg1 = toBits(tonumber(memory.readbyte(0x2005)))
    PPUTable.VRAMAddReg2 = toBits(tonumber(memory.readbyte(0x2006)))

    --PPUTable.VRAMIOReg = "VRAMIOR   "..toBits(tonumber(memory.readbyte(0x2007)))
    --PPUTable.SPRRAMIOReg = "SPRRAMIO  "..toBits(tonumber(memory.readbyte(0x2004)))

    return PPUTable

end


function ppu.readbyte(a)
    memory.writebyte(0x2001,0x00) -- Turn off rendering
    memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
    memory.writebyte(0x2006,math.floor(a/0x100)) -- PPUADDR high byte
    memory.writebyte(0x2006,a % 0x100) -- PPUADDR low byte
    if a < 0x3f00 then 
        dummy=memory.readbyte(0x2007) -- PPUDATA (discard contents of internal buffer if not reading palette area)
    end
    ret=memory.readbyte(0x2007) -- PPUDATA
    memory.writebyte(0x2001,0x1e) -- Turn on rendering
    return ret
end

function ppu.readbytes(a,l)
    memory.writebyte(0x2001,0x00) -- Turn off rendering
    local ret
    local i
    ret=""
    for i=0,l-1 do
        memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
        memory.writebyte(0x2006,math.floor((a+i)/0x100)) -- PPUADDR high byte
        memory.writebyte(0x2006,(a+i) % 0x100) -- PPUADDR low byte
        if (a+i) < 0x3f00 then 
            dummy=memory.readbyte(0x2007) -- PPUDATA (discard contents of internal buffer if not reading palette area)
        end
        ret=ret..string.char(memory.readbyte(0x2007)) -- PPUDATA
    end
    memory.writebyte(0x2001,0x1e) -- Turn on rendering
    return ret
end


function ppu.writebyte(a,v)
    memory.writebyte(0x2001,0x00) -- Turn off rendering
    memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
    memory.writebyte(0x2006,math.floor(a/0x100)) -- PPUADDR high byte
    memory.writebyte(0x2006,a % 0x100) -- PPUADDR low byte
    memory.writebyte(0x2007,v) -- PPUDATA
    memory.writebyte(0x2001,0x1e) -- Turn on rendering
end

function ppu.writebytes(a,str)
    memory.writebyte(0x2001,0x00) -- Turn off rendering

    local i
    for i = 0, #str-1 do
        memory.readbyte(0x2002) -- PPUSTATUS (reset address latch)
        memory.writebyte(0x2006,math.floor((a+i)/0x100)) -- PPUADDR high byte
        memory.writebyte(0x2006,(a+i) % 0x100) -- PPUADDR low byte
        memory.writebyte(0x2007,string.byte(str,i+1)) -- PPUDATA
    end

    memory.writebyte(0x2001,0x1e) -- Turn on rendering
end



function ppu.readcontrol()
	
	---nametable currently in use
	---pattern table address in use

	control = {}

	ppuregs = getPPURegisters()
	PPUCR1 = ppuregs.controlReg1

	setXScrollIncrement = 0
	setYScrollIncrement = 0

	nametableNumberBin=string.sub(PPUCR1,1,2)
	if nametableNumberBin == "00" then
		control.nametableAddress = 0x2000
		setXScrollIncrement = 0
		setYScrollIncrement = 0
	elseif nametableNumberBin == "01" then
		control.nametableAddress = 0x2400
		setXScrollIncrement = 0
		setYScrollIncrement = 1
	elseif nametableNumberBin == "10" then
		control.nametableAddress = 0x2800
		setXScrollIncrement = 1
		setYScrollIncrement = 0
	elseif nametableNumberBin == "11" then
		control.nametableAddress = 0x2C00
		setXScrollIncrement = 1
		setYScrollIncrement = 1
	end

	control.setXScrollIncrement = setXScrollIncrement
	control.setYScrollIncrement = setYScrollIncrement

	spritepatterntableNumberBin = string.sub(PPUCR1,4,4)
	if spritepatterntableNumberBin == "0" then
		control.spritepatterntableAddress = 0x0000
	elseif spritepatterntableNumberBin == "1" then
		control.spritepatterntableAddress = 0x1000
	end
	bgpatterntableNumberBin = string.sub(PPUCR1,5,5)

	if bgpatterntableNumberBin == "0" then
		control.bgpatterntableAddress = 0x0000
	elseif bgpatterntableNumberBin == "1" then
		control.bgpatterntableAddress = 0x1000
	end
	spritesizeNumberBin = string.sub(PPUCR1,6,6)
	if spritesizeNumberBin == "0" then
		control.spritesize = 0 --8x8
	elseif spritesizeNumberBin == "1" then
		control.spritesize = 1 --8x16
	end

	return control
end

function ppu.readleftpatterntable()

    --Read Pattern tables from PPU
	patterntable = {}
	control = ppu.readcontrol()

	for i=0x0000,0x0FFF do
		patterntable[i] = ppu.readbyte(i)
	end

	return patterntable

end

function ppu.readrightpatterntable()

    --Read Pattern tables from PPU
	patterntable = {}
	control = ppu.readcontrol()

	for i=0x1000,0x1FFF do
		patterntable[i-0x1000] = ppu.readbyte(i)
	end

	return patterntable

end



return ppu