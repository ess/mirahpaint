package com.example.mirahpaint

import android.content.Context
import android.graphics.Canvas
import android.graphics.Picture
import android.graphics.Rect
import android.graphics.drawable.Drawable
import android.util.AttributeSet
import android.view.View
import android.view.ViewGroup
import android.view.ViewGroup.LayoutParams
import android.view.ViewParent

class PictureLayout < ViewGroup

  def initialize(context:Context)
    super(context)
    @mPicture = Picture.new
  end

  def initialize(context:Context, attrs:AttributeSet)
    super(context, attrs)
  end

  def addView(child:View)
    if getChildCount > 1
      raise IllegalStateException.new("PictureLayout can host only one direct child")
    end

    super(child)
  end

  def addView(child:View, index:fixnum)
    if getChildCount > 1
      raise IllegalStateException.new("PictureLayout can host only one direct child")
    end

    super(child, index)
  end

  def addView(child:View, params:LayoutParams)
    if getChildCount > 1
      raise IllegalStateException.new("PictureLayout can host only one direct child")
    end

    super(child, params)
  end

  def addView(child:View, index:fixnum, params:LayoutParams)
    if getChildCount> 1
      raise IllegalStateException.new("PictureLayout can host only one direct child")
    end

    super(child, index, params)
  end

  def generateDefaultLayoutParams():LayoutParams
    LayoutParams.new(ViewGroup.LayoutParams.FILL_PARENT, ViewGroup.LayoutParams.FILL_PARENT)
  end

  def onMeasure(widthMeasureSpec, heightMeasureSpec)
    count = getChildCount

    maxHeight = 0
    maxWidth = 0

    i = 0
    while i < count
      child = getChildAt(i)
      if child.getVisibility() != View.GONE
        measureChild(child, widthMeasureSpec, heightMeasureSpec)
      end
      i = i + 1
    end

    maxWidth = getPaddingLeft() + getPaddingRight()
    maxHeight = getPaddingTop() + getPaddingBottom()

    drawable = getBackground()
    if drawable != nil
      maxHeight = Math.max(maxHeight, drawable.getMinimumHeight())
      maxWidth = Math.max(maxWidth, drawable.getMinimumWidth())
    end

    setMeasuredDimension(ViewGroup.resolveSize(maxWidth, widthMeasureSpec), ViewGroup.resolveSize(maxHeight, heightMeasureSpec))
  end

  def drawPict(canvas:Canvas, x:int, y:int, w:int, h:int, sx:float, sy:float)
    canvas.save()
    canvas.translate(x, y)
    canvas.clipRect(0, 0, w, h)
    canvas.scale(float(0.5), float(0.5))
    canvas.scale(sx, sy, w, h)
    canvas.drawPicture(@mPicture)
    canvas.restore()
  end

  def dispatchDraw(canvas:Canvas)
    super(@mPicture.beginRecording(getWidth(), getHeight()))
    @mPicture.endRecording()

    x = getWidth() / 2
    y = getHeight() / 2

    if false
      canvas.drawPicture(@mPicture)
    else
      drawPict(canvas, 0, 0, x, y, 1, 1)
      drawPict(canvas, x, 0, x, y, -1, 1)
      drawPict(canvas, 0, y, x, y, 1, -1)
      drawPict(canvas, x, y, x, y, -1, -1)
    end
  end

  def invalidateChildInParent(location:int[], dirty:Rect)
    location[0] = getLeft()
    location[1] = getTop()
    dirty.set(0, 0, getWidth(), getHeight())
    return getParent()
  end

  def onLayout(changed:Boolean, l:int, t:int, r:int, b:int)
    count = getChildCount()
    i = 0
    while i < count
      child = getChildAt(i)
      if child.getVisibility() != View.GONE
        childLeft = getPaddingLeft()
        childTop = getPaddingTop()
        child.layout(childLeft, childTop, childLeft + child.getMeasuredWidth(), childTop + child.getMeasuredHeight())
      end
      i = i + 1
    end
  end
end
