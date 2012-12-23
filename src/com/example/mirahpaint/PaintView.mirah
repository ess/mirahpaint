package com.example.mirahpaint

import android.content.Context
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.graphics.Rect
import android.graphics.RectF
import android.os.Bundle
import android.os.Handler
import android.os.Message
import android.view.Menu
import android.view.MenuItem
import android.view.MotionEvent
import android.view.View



import java.util.Random

class PaintView < View

  def self.fade_alpha
    0x06
  end

  def self.max_fade_steps
    256 / self.fade_alpha + 4
  end

  def self.trackball_scale:int
    10
  end

  def self.splat_vectors:int
    40
  end

  def initialize(c:Context)
    super(c)
    @mRandom = Random.new
    @mPaint = Paint.new
    @mPaint.setAntiAlias(true)
    @mFadePaint = Paint.new
    @mFadePaint.setColor(MirahPaint.background_color)
    @mFadePaint.setAlpha(PaintView.fade_alpha)
    @mReusableOvalRect = RectF.new
    @mColorIndex = 0
    @mOldButtonState = 0
  end

  def clear
    if (@mCanvas != nil)
      @mPaint.setColor(MirahPaint.background_color)
      @mCanvas.drawPaint(@mPaint)
      invalidate()
      @mFadeSteps = PaintView.max_fade_steps
    end
  end

  def fade
    if @mCanvas != nil && @mFadeSteps < PaintView.max_fade_steps
      @mCanvas.drawPaint(@mFadePaint)
      invalidate()
      @mFadeSteps += 1
    end
  end

  def onSizeChanged(w:int, h:int, oldw:int, oldh:int)
    curW = @mBitmap != nil ? @mBitmap.getWidth() : 0
    curH = @mBitmap != nil ? @mBitmap.getHeight() : 0

    if curW >= w && curH >= h
      return
    end

    if curW < w
      curW = w
    end
    if curH < h
      curH = h
    end

    newBitmap = Bitmap.createBitmap(curW, curH, Bitmap.Config.ARGB_8888)
    newCanvas = Canvas.new
    newCanvas.setBitmap(newBitmap)
    if @mBitmap != nil
      newCanvas.drawBitmap(@mBitmap, 0, 0, nil)
    end
    @mBitmap = newBitmap
    @mCanvas = newCanvas
    @mFadeSteps = PaintView.max_fade_steps
  end

  def onDraw(canvas:Canvas)
    if @mBitmap != nil
      canvas.drawBitmap(@mBitmap, 0, 0, nil)
    end
  end

  def advanceColor
    @mColorIndex = (@mColorIndex + 1) % ColorChart.length
  end

  def onTrackBallEvent(event:MotionEvent):boolean
    action = event.getActionMasked()
    if action == MotionEvent.ACTION_DOWN
      advanceColor()
    end

    if action == MotionEvent.ACTION_DOWN || action == MotionEvent.ACTION_MOVE
      _N = event.getHistorySize()
      scaleX = event.getXPrecision() * PaintView.trackball_scale
      scaleY = event.getYPrecision() * PaintView.trackball_scale
      i = 0
      while i < _N
        moveTrackball(event.getHistoricalX(i) * scaleX, event.getHistoricalY(i) * scaleY)
        i = i + 1
      end
      moveTrackball(event.getX() * scaleX, event.getY() * scaleY)
    end
    return true
  end

  def moveTrackball(deltaX:float, deltaY:float)
    curW = @mBitmap != nil ? @mBitmap.getWidth() : 0
    curH = @mBitmap != nil ? @mBitmap.getHeight() : 0

    @mCurX = Math.max(Math.min(@mCurX + deltaX, curW - 1), 0)
    @mCurY = Math.max(Math.min(@mCurY + deltaY, curH - 1), 0)
    paint(PaintMode.Draw, @mCurX, @mCurY)
  end

  def onTouchEvent(event:MotionEvent):boolean
    return onTouchOrHoverEvent(event, true)
  end

  def onHoverEvent(event:MotionEvent):boolean
    return onTouchOrHoverEvent(event, false)
  end

  def onTouchOrHoverEvent(event:MotionEvent, isTouch:boolean):boolean
    buttonState = event.getButtonState()
    pressedButtons = buttonState & ~(@mOldButtonState)
    @mOldButtonState = buttonState

    if (pressedButtons & MotionEvent.BUTTON_SECONDARY) != 0
      advanceColor()
    end

    mode = PaintMode.Draw

    if (buttonState & MotionEvent.BUTTON_TERTIARY) != 0
      mode = PaintMode.Splat
    elsif isTouch || (buttonState & MotionEvent.BUTTON_PRIMARY) != 0
      mode = PaintMode.Draw
    else
      return false
    end

    action = event.getActionMasked()
    if action == MotionEvent.ACTION_DOWN || action == MotionEvent.ACTION_MOVE || action == MotionEvent.ACTION_HOVER_MOVE
      _N = event.getHistorySize()
      _P = event.getPointerCount()
      i = 0
      while i < _N
        j = 0
        while j < _P
          paint(getPaintModeForTool(event.getToolType(j), mode),
                event.getHistoricalX(j, i),
                event.getHistoricalY(j, i),
                event.getHistoricalPressure(j, i),
                event.getHistoricalTouchMajor(j, i),
                event.getHistoricalTouchMinor(j, i),
                event.getHistoricalOrientation(j, i),
                event.getHistoricalAxisValue(MotionEvent.AXIS_DISTANCE, j, i),
                event.getHistoricalAxisValue(MotionEvent.AXIS_TILT, j, i)
               )
          j = j + 1
        end
        i = i + 1
      end

      j = 0
      while j < _P
        paint(getPaintModeForTool(event.getToolType(j), mode),
              event.getX(j),
              event.getY(j),
              event.getPressure(j),
              event.getTouchMajor(j),
              event.getTouchMinor(j),
              event.getOrientation(j),
              event.getAxisValue(MotionEvent.AXIS_DISTANCE, j),
              event.getAxisValue(MotionEvent.AXIS_TILT, j)
             )
        j = j + 1
      end
      @mCurX = event.getX()
      @mCurY = event.getY()
    end
    return true
  end

  def getPaintModeForTool(toolType:int, defaultMode:int):int
    if toolType == MotionEvent.TOOL_TYPE_ERASER
      return PaintMode.Erase
    else
      return defaultMode
    end
  end

  def paint(mode:int, x:float, y:float)
    paint(mode, x, y, float(1.0), 0, 0, 0, 0, 0)
  end

  def drawSplat(canvas:Canvas, x:float, y:float, orientation:float, distance:float, tilt:float, paint:Paint):void
    z = distance * 2 + 10

    nx = float(Math.sin(orientation) * Math.sin(tilt))
    ny = float(- Math.sin(orientation) * Math.sin(tilt))
    nz = float(Math.cos(tilt))
    if nz < 0.05
      return
    end

    cd = z / nz
    cx = nx * cd
    cy = ny * cd

    i = 0
    while i < PaintView.splat_vectors
      direction = @mRandom.nextDouble() * Math.PI * 2
      dispersion = @mRandom.nextGaussian() * 0.02
      vx = Math.cos(direction) * dispersion
      vy = Math.sin(direction) * dispersion
      vz = double(1)

      temp = vy
      vy = temp * Math.cos(tilt) - vz * Math.sin(tilt)
      vz = temp * Math.sin(tilt) + vz * Math.cos(tilt)

      temp = vx
      vx = temp * Math.cos(orientation) - vy * Math.sin(orientation)
      vy = temp * Math.sin(orientation) + vy * Math.cos(orientation)

      if vz < 0.05
        next
      end

      pd = float(z / vz)
      px = float(vx * pd)
      py = float(vy * pd)

      @mCanvas.drawCircle(x + px - cy, y + py - cy, float(1.0), paint)
      i = i + 1
    end
  end

  def pick_a_color:int
    /*if @mColorIndex == nil*/
      /*@mColorIndex = 0*/
    /*end*/
    ColorChart.get(@mColorIndex)
  end

  def paint(mode:int, x:float, y:float, pressure:float, major:float, minor:float, orientation:float, distance:float, tilt:float)
    if @mBitmap != nil
      if major <= 0 || minor <= 0
        major = minor = float(16)
      end

      if mode == PaintMode.Draw
        @mPaint.setColor(pick_a_color)
        @mPaint.setAlpha(Math.min(int(pressure * 128), 255))
        drawOval(@mCanvas, x, y, major, minor, orientation, @mPaint)
      elsif mode == PaintMode.Erase
        @mPaint.setColor(MirahPaint.background_color)
        @mPaint.setAlpha(Math.min(int(pressure * 128), 255))
        drawOval(@mCanvas, x, y, major, minor, orientation, @mPaint)
      elsif mode == PaintMode.Splat
        @mPaint.setColor(pick_a_color)
        @mPaint.setAlpha(64)
        drawSplat(@mCanvas, x, y, orientation, distance, tilt, @mPaint)
      end
    end
    @mFadeSteps = 0
    invalidate()
  end

  def drawOval(canvas:Canvas, x:float, y:float, major:float, minor:float, orientation:float, paint:Paint)
    canvas.save(Canvas.MATRIX_SAVE_FLAG)
    canvas.rotate(float(orientation * 180 / Math.PI), x, y)
    @mReusableOvalRect.left = x - minor / 2
    @mReusableOvalRect.right = x + minor / 2
    @mReusableOvalRect.top = y - major / 2
    @mReusableOvalRect.bottom = y + major / 2
    canvas.drawOval(@mReusableOvalRect, paint)
    canvas.restore()
  end
end
