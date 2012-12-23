## MirahPaint - TouchPaint ported to Mirah ##

First thing being first, holy crap, it works.

The thing that comes after the first thing is the second thing, and it's a bit
of a doozy ... this code is UGLY.

Granted, it's not as ugly as the Java (which actually wasn't that bad in the
first place). In some places, though, it's not just ugly, it'd downright stupid
(which is what we get for using a youngish language).

At any rate, here's a pindah project that builds reliably on my Gentoo box.
Given my general lack of luck getting anything Java-related working on it, I'm
going to go ahead and claim that it should build on pretty much anything.

## There Be Dragons ##

* **No Nested Classes** - Nesting PaintView inside MirahPaint seemed to be the
  cause of an issue somewhat early on in this process, so I moved it into its
  own file. As it were, I prefer it this way, so I kept the new structure.

* **No GraphicsActivity** - MirahPaint < GraphicsActivity < Activity just plain
  did not fly. Saw some related chatter regarding inconsistency with super in
  cases like this, and I will be happy to verify that the chatter is apt. Also,
  to be fair, this abstraction really didn't make much sense. So, things have
  been absorbed directly into MirahPaint, which now inherits directly from
  Activity.

* **No enums** - Instead, these were shipped off to utility classes. The only
  real example is that the PaintMode enum became the PaintMode class, which has
  class methods for each of the modes.

* **No constants** - I saw chatter all over the place (that is, in the two
  relevant, unique Google results) that class constants might be working. I can
  verify that they're not (or at least that the documentation for these is
  unsurprisingly lacking). At any rate, these were converted to class methods
  that return the proper values. The side-effect of this is that they require
  tacking the class name on the front when used (unless used in their own class
  context, and that's proven to be a little iffy over the last six hours). One
  exception is that the COLORS constant was especially problematic (due to the
  next point), so it was shipped off to the ColorChart class.

* **No Mirah Arrays** - These things are currently made of badness, and the
  accepted way to get a real array has proven to make the Dalvik optimizer
  take to heavy drinking. There's a lot of chatter about making them better,
  so this may be revisited eventually.

* **Not Idiomatic** - This is a straight translation from Java to Mirah except
  for the places where that was terribly problematic (like the mHandler bit in
  the original piece).

* **Stuff I've Forgotten** - This translation was born of insomnia, so there is
  a pretty good chance that I've missed a few dragons.

## History ##

* 1.0.1 - 20121223 - Replaced busted while loops with idiomatic "times do" loops
* 1.0.0 - 20121223 - Initial Commit shiz
