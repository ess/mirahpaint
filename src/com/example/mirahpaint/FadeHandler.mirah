package com.example.mirahpaint

import android.os.Handler
import android.os.Message

class FadeHandler < Handler
  def initialize(mirahpaint:MirahPaint)
    super()
    @mirahPaint = mirahpaint
  end

  def handleMessage(msg:Message)
    wat = msg.what
    if wat == MirahPaint.msg_fade
      @mirahPaint.view.fade()
      @mirahPaint.scheduleFade()
    else
      Handler.new.handleMessage(msg)
    end
  end
end
