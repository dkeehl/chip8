class Chip8
  attr_accessor(
    :chip8_fontset,
    :draw_flag,
    :gfx,
    :key_input,
    :pc,
    :memory,
    :index_register,
    :register,
    :stack,
    :stack_pointer,
    :delay_timer,
    :sound_timer,
  )

  def initialize
    chip8_fontset = [
      0xF0, 0x90, 0x90, 0x90, 0xF0, #0
      0x20, 0x60, 0x20, 0x20, 0x70, #1
      0xF0, 0x10, 0xF0, 0x80, 0xF0, #2
      0xF0, 0x10, 0xF0, 0x10, 0xF0, #3
      0x90, 0x90, 0xF0, 0x10, 0x10, #4
      0xF0, 0x80, 0xF0, 0x10, 0xF0, #5
      0xF0, 0x80, 0xF0, 0x90, 0xF0, #6
      0xF0, 0x10, 0x20, 0x40, 0x40, #7
      0xF0, 0x90, 0xF0, 0x90, 0xF0, #8
      0xF0, 0x90, 0xF0, 0x10, 0xF0, #9
      0xF0, 0x90, 0xF0, 0x90, 0x90, #A
      0xE0, 0x90, 0xE0, 0x90, 0xE0, #B
      0xF0, 0x80, 0x80, 0x80, 0xF0, #C
      0xE0, 0x90, 0x90, 0x90, 0xE0, #D
      0xF0, 0x80, 0xF0, 0x80, 0xF0, #E
      0xF0, 0x80, 0xF0, 0x80, 0x80, #F
    ]
    
    @draw_flag = true
    @gfx = Array.new(64 * 32, 0)

    @key_input = Array.new(16, 0)

    @pc = 0x200                    #location where the rom is loaded
    @memory = Array.new(4096, 0)
    @register = Array.new(16, 0)
    @index_register = 0

    @stack_pointer = 0
    @stack = Array.new(16, 0)

    @delay_timer = 0
    @sound_timer = 0

    #load fontset to memory
    (0...80).each { |i| @memory[i] = chip8_fontset[i] }

    srand
  end

  def emulate_cycle
    opcode = @memory[pc] << 8 | @memory[pc + 1]
    @pc &= 0xFFF
    @index_register &= 0xFFF

    case opcode & 0xF000
    when 0x0000
      case opcode
      when 0x00E0 #Clear then screen
        @gfx.map! { 0x0 }
        @draw_flag = true
        @pc += 2
      when 0x00EE #Return from a subroutine
        @stack_pointer -= 1
        @pc = @stack[@stack_pointer]
        @pc += 2
      else
        puts "Unknown opcode #{opcode}"
      end
    when 0x1000 #1NNN Jumps to adress NNN
      @pc = opcode & 0x0FFF
    when 0x2000 #2NNN Calls subroutine at NNN
      @stack[@stack_pointer] = pc
      @stack_pointer += 1
      @pc = opcode & 0x0FFF
    when 0x3000 #3XNN Skips the next instruction if VX equals NN
      @register[(opcode & 0x0F00) >> 8] == opcode & 0x0FF ? @pc += 4 : @pc += 2
    when 0x4000 #4XNN Skips the next instruction if VX doesn't equal NN
      @register[(opcode & 0x0F00) >> 8] != opcode & 0x0FF ? @pc += 4 : @pc += 2
    when 0x5000 #5XY0 Skips the next instruction if VX equals VY
      @register[(opcode & 0x0F00) >> 8] == @register[(opcode & 0x00F0) >> 4] ? @pc += 4 : @pc += 2
    when 0x6000 #6XNN Sets VX to NN
      @register[(opcode & 0x0F00) >> 8] = opcode & 0x00FF
      @pc += 2
    when 0x7000 #7XNN Adds NN to VX
      @register[(opcode & 0x0F00) >> 8] = (@register[(opcode & 0x0F00) >> 8] + (opcode & 0x00FF)) & 0xFF
      @pc += 2
    when 0x8000
      case opcode & 0x000F
      when 0x0000 #8XY0 Sets VX to the value of VY
        @register[(opcode & 0x0F00) >> 8] = @register[(opcode & 0x00F0) >> 4]
        @pc += 2
      when 0x0001 #8XY1 Sets VX to VX or VY
        @register[(opcode & 0x0F00) >> 8] |= @register[(opcode & 0x00F0) >> 4]
        @pc += 2
      when 0x0002 #8XY2 Sets VX to VX and VY
        @register[(opcode & 0x0F00) >> 8] &= @register[(opcode & 0x00F0) >> 4]
        @pc += 2
      when 0x0003 #8XY3 Sets VX to VX xor VY
        @register[(opcode & 0x0F00) >> 8] ^= @register[(opcode & 0x00F0) >> 4]
        @pc += 2
      when 0x0004 #8XY4 Adds VY to VX. VF is set to 1 when there is carry, and to 0 when there isn't
        sum = @register[(opcode & 0x0F00) >> 8] + @register[(opcode & 0x00F0) >> 4]
        if sum > 0xFF
          @register[0xF] = 1
        else
          @register[0xF] = 0
        end
        @register[(opcode & 0x0F00) >> 8] = sum & 0xFF
        @pc += 2
      when 0x0005 #8XY5 VY is subtructed from VX. VF is set to 0 when threre's a borrow, and 1 when there isn't
        if @register[(opcode & 0x0F00) >> 8] >= @register[(opcode & 0x00F0) >> 4]
          @register[(opcode & 0x0F00) >> 8] -= @register[(opcode & 0x00F0) >> 4]
          @register[0xF] = 1
        else
          @register[(opcode & 0x0F00) >> 8] = @register[(opcode & 0x0F00) >> 8] + 0x100 - @register[(opcode & 0x00F0) >> 4]
          @register[0xF] = 0
        end
        @pc += 2
      when 0x0006 #8XY6 Shift VX right by one
        @register[0xF] = @register[(opcode & 0x0F00) >> 8] & 0x1
        @register[(opcode & 0x0F00) >> 8] >>= 1
        @pc += 2
      when 0x0007 #8XY7 VX = VY -VX
        if @register[(opcode & 0x0F00) >> 8] <= @register[(opcode & 0x00F0) >> 4]
          @register[(opcode & 0x0F00) >> 8] = @register[(opcode & 0x00F0) >> 4] - @register[(opcode & 0x0F00) >> 8]
          @register[0xF] = 1
        else
          @register[(opcode & 0x0F00) >> 8] = @register[(opcode & 0x00F0) >> 4] + 0x100 - @register[(opcode & 0x0F00) >> 8]
          @register[0xF] = 0
        end
        @pc += 2
      when 0x000E #8XYE Shift VX left by one
        @register[0xF] = @register[(opcode & 0x0F00) >> 8] >> 7
        @register[(opcode & 0x0F00) >> 8] = @register[(opcode & 0x0F00) >> 8] & 0x7f << 1
        @pc += 2
      else
        puts "Unknown opcode #{opcode}"
      end
    when 0x9000 #9XY0 Skips the next instruction if VX doesn't equal VY
      @register[(opcode & 0x0F00) >> 8] != @register[(opcode & 0x00F0) >> 4] ? @pc += 4 : @pc += 2
    when 0xA000 #ANNN Sets index register to NNN
      @index_register = opcode & 0x0FFF
      @pc += 2
    when 0xB000 #BNNN Jumps to adrress NNN plus V0
      @pc = ((opcode & 0x0FFF) + @register[0]) & 0xFFF
    when 0xC000 #CXNN 
      @register[(opcode & 0x0F00) >> 8] = rand(0xFF) & (opcode & 0x00FF)
      @pc += 2
    when 0xD000 #DXYN
      x = @register[(opcode & 0x0F00) >> 8]
      y = @register[(opcode & 0x00F0) >> 4]
      height = opcode & 0x000F
      @register[0xF] = 0
      (0...height).each do |h|
        sprites = @memory[@index_register + h]
        (0...8).each do |w|
          if sprites & (0x80 >> w) != 0
            if @gfx[x + w + (y + h) * 64] == 1
              @register[0xF] = 1
            end
            @gfx[x + w + (y + h) * 64] ^= 1
          end
        end
      end
      @draw_flag = true
      @pc += 2
    when 0xE000
      case opcode & 0x00FF
      when 0x009E #EX9E Skips the next instruction if the key stored in VX is pressed
        if @key_input[@register[(opcode & 0x0F00) >> 8]] != 0
          @pc += 4
        else
          @pc += 2
        end
      when 0x00A1 #EXA1 Skips the next instruction if the key stored in VX isn't pressed
        if @key_input[@register[(opcode & 0x0F00) >> 8]] == 0
          @pc += 4
        else
          @pc += 2
        end
      else
        puts "Unknown opcode #{opcode}"
      end
    when 0xF000
      case opcode & 0x00FF
      when 0x0007 #FX07 Sets VX to the value of the delay timer
        @register[(opcode & 0x0F00) >> 8] = @delay_timer
        @pc += 2
      when 0x000A #FX0A A key press is awaited, and then stored in VX
        if @key_input.include?(1)
          @register[(opcode & 0x0F00) >> 8] = @key_input.index(1)
          @pc += 2
        end
      when 0x0015 #FX15 Sets the delay timer to VX
        @delay_timer = @register[(opcode & 0x0F00) >> 8]
        @pc += 2
      when 0x0018 #FX18 Sets the sound timer to VX
        @sound_timer = @register[(opcode & 0x0F00) >> 8]
        @pc += 2
      when 0x001E #FX1E Adds VX to I
        sum = @index_register + @register[(opcode & 0x0F00) >> 8]
        if sum > 0xFFF
          @register[0xf] = 1
        else
          @register[0xf] = 0
        end
        @index_register  = sum
        @pc += 2
      when 0x0029 #FX29 VX should be 0-F, sets index register to the fontset location of VX
        @index_register = @register[(opcode & 0x0F00) >> 8] * 5
        @pc += 2
      when 0x0033 #FX33 Take the decimal representation of VX, place the hundreds digit in M[I], tens in M[I + 1], and the ones in M[I + 2]
        @memory[@index_register] = @register[(opcode & 0x0F00) >> 8] / 100
        @memory[@index_register + 1] = (@register[(opcode & 0x0F00) >> 8] / 10) % 10
        @memory[@index_register + 2] = (@register[(opcode & 0x0F00) >> 8] % 100) % 10
        @pc += 2
      when 0x0055 #FX55 Stores V0 to VX in memory starting at address I
        (0..((opcode & 0x0F00) >> 8)).each { |i| @memory[@index_register + i] = @register[i] }
        #this comes with the original interpreter
        @index_register += ((opcode & 0x0F00) >> 8) + 1
        @pc += 2
      when 0x0065 #FX65 Fills V0 to VX with values from memory starting at address I
        (0..((opcode & 0x0F00) >> 8)).each { |i| @register[i] = @memory[@index_register + i] }
        @index_register += ((opcode & 0x0F00) >> 8) + 1
        @pc += 2
      else
        puts "Unknown opcode #{opcode}"
      end
    else
      puts "Unknown opcode #{opcode}"
    end

    if @delay_timer > 0
      @delay_timer -= 1
    end

    if @sound_timer > 0
      @sound_timer -= 1
    end
  end

  def loadfile(file_name)
    rom = File.binread(file_name).unpack('C*')
    if rom.size <= 4096 - 512
      (0...rom.size).each { |i| @memory[0x200 + i] = rom[i] }
    else
      puts "Error: ROM too big for memory"
    end
  end
end


