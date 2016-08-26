require_relative './game'

class Game
  def debug(time)
    n = time * 60
    n.times do 
      @c8.emulate_cycle
      yield
    end
  end

  def register
    puts (@c8.register).to_s
  end

  def pc
    puts @c8.pc
  end

  def delay_timer
    puts @c8.delay_timer
  end

  def memory
    puts (@c8.memory)[0].to_s(16)
  end

  def opcode
    code = @c8.memory[@c8.pc] << 8 | @c8.memory[@c8.pc + 1]
    puts code.to_s(16)
  end

  def output
    line = ' ' * 64
    (0...32).each do |y|
      (0...64).each do |x|
        if @c8.gfx[y * 64 + x] == 1
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


game = Game.new('./roms/BLINKY')
game.debug(30) { game.opcode }




