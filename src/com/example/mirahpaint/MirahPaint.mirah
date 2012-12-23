package com.example.mirahpaint

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.app.Activity
import android.os.Bundle
import android.os.Handler
import android.os.Message
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.View

import java.util.List


class MirahPaint < Activity

  def self.background_color
    Color.BLACK
  end

  def self.clear_id
    Menu.FIRST
  end

  def self.fade_id
    Menu.FIRST + 1
  end

  def self.msg_fade
    1
  end

  def self.fade_delay
    100
  end


  def onCreate(savedInstanceState:Bundle)
    super(savedInstanceState)

    @mView = PaintView.new(self)
    setContentView(@mView)
    @mView.requestFocus()

    @mFading = true
    @mColorIndex = 0
    unless savedInstanceState.nil?
      @mFading = savedInstanceState.getBoolean("fading", true)
      @mColorIndex = savedInstanceState.getInt("color", 0)
    end

    @mHandler = FadeHandler.new(self)
  end

  def view:PaintView
    @mView
  end

  def setContentView(view:View)
    super(view)
  end

  def onCreateOptionsMenu(menu:Menu):boolean
    menu.add(0, MirahPaint.clear_id, 0, "Clear")
    menu.add(0, MirahPaint.fade_id, 0, "Fade").setCheckable(true)
    return super(menu)
  end

  def onPrepareOptionsMenu(menu:Menu):boolean
    menu.findItem(MirahPaint.fade_id).setChecked(@mFading)
    return super(menu)
  end

  def invert_fading_state
    if @mFading
      @mFading = false
    else
      @mFading = true
    end
  end

  def scheduleFade
    @mHandler.sendMessageDelayed(@mHandler.obtainMessage(MirahPaint.msg_fade), MirahPaint.fade_delay)
  end

  def startFading
    @mHandler.removeMessages(MirahPaint.msg_fade)
    scheduleFade()
  end

  def stopFading
    @mHandler.removeMessages(MirahPaint.msg_fade)
  end

  

  def onOptionsItemSelected(item:MenuItem):boolean
    item_id = item.getItemId()
    if item_id == MirahPaint.clear_id
      @mView.clear()
      return true
    elsif item_id == MirahPaint.fade_id
      invert_fading_state
      if @mFading
        startFading()
      else
        stopFading()
      end
      return true
    end
  
    return super(item)
  end

  def onResume
    super
    if @mFading
      startFading()
    end
  end

  def onSaveInstanceState(outState:Bundle)
    super(outState)

    outState.putBoolean("fading", @mFading)
    outState.putInt("color", @mColorIndex)
  end

  def onPause
    super
    stopFading()
  end

  
end
