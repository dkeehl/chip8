require 'dxruby'
require_relative './chip8'

class Screen

  BLACK = [0, 0, 0]
  WHITE = [255, 255, 255]

  def initialize
    @scale = 10
    Window.width = 64 * @scale
    Window.height = 32 * @scale
    Window.mag_filter = TEXF_POINT
    Window.caption = 'Chip8 Emulator'
    #Window.fps = 60
    @white_pixle = Image.new(@scale, @scale, WHITE)
  end

  def draw(v_mem)
    (0...32).each do |y|
      (0...64).each do |x|
        if v_mem[y * 64 + x] == 1
          Window.draw(x * @scale, y * @scale, @white_pixle) 
        end
      end
    end
  end
end

class Keyboard
  def initialize(chip)
    @c = chip
  end

  def update
    @c.key_input[0] = 1 if Input.key_push?(K_X)
    @c.key_input[1] = 1 if Input.key_push?(K_1)
    @c.key_input[2] = 1 if Input.key_push?(K_2)
    @c.key_input[3] = 1 if Input.key_push?(K_3)
    @c.key_input[4] = 1 if Input.key_push?(K_Q)
    @c.key_input[5] = 1 if Input.key_push?(K_W)
    @c.key_input[6] = 1 if Input.key_push?(K_E)
    @c.key_input[7] = 1 if Input.key_push?(K_A)
    @c.key_input[8] = 1 if Input.key_push?(K_S)
    @c.key_input[9] = 1 if Input.key_push?(K_D)
    @c.key_input[10] = 1 if Input.key_push?(K_Z)
    @c.key_input[11] = 1 if Input.key_push?(K_C)
    @c.key_input[12] = 1 if Input.key_push?(K_4)
    @c.key_input[13] = 1 if Input.key_push?(K_R)
    @c.key_input[14] = 1 if Input.key_push?(K_F)
    @c.key_input[15] = 1 if Input.key_push?(K_V)

    @c.key_input[0] = 0 if Input.key_release?(K_X)
    @c.key_input[1] = 0 if Input.key_release?(K_1)
    @c.key_input[2] = 0 if Input.key_release?(K_2)
    @c.key_input[3] = 0 if Input.key_release?(K_3)
    @c.key_input[4] = 0 if Input.key_release?(K_Q)
    @c.key_input[5] = 0 if Input.key_release?(K_W)
    @c.key_input[6] = 0 if Input.key_release?(K_E)
    @c.key_input[7] = 0 if Input.key_release?(K_A)
    @c.key_input[8] = 0 if Input.key_release?(K_S)
    @c.key_input[9] = 0 if Input.key_release?(K_D)
    @c.key_input[10] = 0 if Input.key_release?(K_Z)
    @c.key_input[11] = 0 if Input.key_release?(K_C)
    @c.key_input[12] = 0 if Input.key_release?(K_4)
    @c.key_input[13] = 0 if Input.key_release?(K_R)
    @c.key_input[14] = 0 if Input.key_release?(K_F)
    @c.key_input[15] = 0 if Input.key_release?(K_V) 
  end
end

class Game
  def initialize(rom)
    @c8 = Chip8.new
    @screen = Screen.new
    @keyboard = Keyboard.new(@c8)
    @c8.loadfile(rom)
  end

  def run
    Window.loop do
      @keyboard.update
      4.times { @c8.emulate_cycle }
      @screen.draw(@c8.gfx)
      puts "Beep" if @c8.sound_timer == 1
      break if Input.key_push?(K_ESCAPE)
    end
  end
end

