package com.example.mirahpaint

import android.graphics.Color

class ColorChart
  def self.get(index:int):int
    if index == 1
      return Color.RED
    elsif index == 2
      return Color.YELLOW
    elsif index == 3
      return Color.GREEN
    elsif index == 4
      return Color.CYAN
    elsif index == 5
      return Color.BLUE
    elsif index == 6
      return Color.MAGENTA
    else
      return Color.WHITE
    end
  end

  def self.length:int
    7
  end
end
