require 'tk'

class Game
  def initialize(rom)
    @ratio = 10

    @root = TkRoot.new('height' => 32 * @ratio, 'width' => 64 * @ratio,
      'background' => 'black') { title 'Chip8 Emulator' }

    c8 = Chip8.new
    @screen = Screen.new(@root)
    @keys = Keyboard.new(@root, c8)
    @timer = TkTimer.new
        
    c8.loadfile(rom)
  end

  def emulation
    c8.emulate_cycle
    if c8.draw_flag
      @screen.draw(c8.gfx)
      c8.draw_flag = false
    end
    puts (c8.memory[c8.pc] << 8 | c8.memory[c8.pc + 1]).to_s(16)
  end

  def run
    @timer.stop
    @timer.start(5, proc { emulation; run })
  end

  def debug_output
    line = ' ' * 64
    (0...32).each do |y|
      (0...64).each do |x|
        if c8.gfx[y * 64 + x] == 1
          line[x] = '*'
        else
          line[x] = ' '
        end
      end
      puts "#{line}\n"
    end
    puts "\n"
  end
end

class Screen
  def initialize(root)
    c = TkCanvas.new(root, 'background' => 'black')
    c.place('width' => 640, 'height' => 320, 'x' => 0, 'y' => 0)
    @pixs = Array.new(64 * 32)
    @pixs.each_index do |i|
      @pixs[i] = TkcRectangle.new(c,
                        (i % 64) * 10,
                        i / 64 * 10,
                        (i % 64) * 10 + 10,
                        i / 64 * 10 + 10,
                        :fill => 'black',
                        :width => 0)
    end
  end

  def draw(v_mem)
    (0...v_mem.size).each do |i|
      if v_mem[i] == 1
        @pixs[i].fill = 'white'
      else
        @pixs[i].fill = 'black'
      end
    end
  end
end

class Keyboard
  def initialize(root, chip8)
    @r = root
    c = chip8

    @r.bind('KeyPress-1', proc { c.key_input[1] = 1 })
    @r.bind('KeyRelease-1', proc { c.key_input[1] = 0 })

    @r.bind('KeyPress-2', proc { c.key_input[2] = 1 })
    @r.bind('KeyRelease-2', proc { c.key_input[2] = 0 })

    @r.bind('KeyPress-3', proc { c.key_input[3] = 1 })
    @r.bind('KeyRelease-3', proc { c.key_input[3] = 0 })

    @r.bind('KeyPress-4', proc { c.key_input[0xC] = 1 })
    @r.bind('KeyRelease-4', proc { c.key_input[0xC] = 0 })

    @r.bind('KeyPress-q', proc { c.key_input[4] = 1 })
    @r.bind('KeyRelease-q', proc { c.key_input[4] = 0 })

    @r.bind('KeyPress-w', proc { c.key_input[5] = 1 })
    @r.bind('KeyRelease-w', proc { c.key_input[5] = 0 })

    @r.bind('KeyPress-e', proc { c.key_input[6] = 1 })
    @r.bind('KeyRelease-e', proc { c.key_input[6] = 0 })

    @r.bind('KeyPress-r', proc { c.key_input[0xD] = 1 })
    @r.bind('KeyRelease-r', proc { c.key_input[0xD] = 0 })

    @r.bind('KeyPress-a', proc { c.key_input[7] = 1 })
    @r.bind('KeyRelease-a', proc { c.key_input[7] = 0 })

    @r.bind('KeyPress-s', proc { c.key_input[8] = 1 })
    @r.bind('KeyRelease-s', proc { c.key_input[8] = 0 })

    @r.bind('KeyPress-d', proc { c.key_input[9] = 1 })
    @r.bind('KeyRelease-d', proc { c.key_input[9] = 0 })

    @r.bind('KeyPress-f', proc { c.key_input[0xE] = 1 })
    @r.bind('KeyRelease-f', proc { c.key_input[0xE] = 0 })

    @r.bind('KeyPress-z', proc { c.key_input[0xA] = 1 })
    @r.bind('KeyRelease-z', proc { c.key_input[0xA] = 0 })

    @r.bind('KeyPress-x', proc { c.key_input[0] = 1 })
    @r.bind('KeyRelease-x', proc { c.key_input[0] = 0 })

    @r.bind('KeyPress-c', proc { c.key_input[0xB] = 1 })
    @r.bind('KeyRelease-c', proc { c.key_input[0xB] = 0 })

    @r.bind('KeyPress-v', proc { c.key_input[0xF] = 1 })
    @r.bind('KeyRelease-v', proc { c.key_input[0xF] = 0 })
  end
end