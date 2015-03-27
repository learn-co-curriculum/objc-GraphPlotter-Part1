---
tags: Core Graphics, DrawRect, Maths
languages: objc
---

# objc-GraphPlotter: Part I

## Objective

More practice with Core Graphics

## Instructions

Draw a line on a view that has the following array of coordinates:

```
(-1,0)
(-5,2)
(4,-2)
(10,-1)
(-2,-2)
(-1,-1)
(10,-5)
(5,5)
(5,6)
(-6,1)
```

Requirements:

1) Let's start by considering the center of your  `UIView` the "origin" of the graph. 

2) Make sure all points are on screen.

3) Make sure that your line is drawn without turning back on itself (like a graph!) and also as a rule we'll draw coordinates that have the same X value from lower Y value to higher Y value.

4) Make the color and width of the line able to be changed by the user of your view class without them having to inspect the implementation code in detail.

5) Make it possible for the user to add more lines to the view using an `NSArray` of lines.

6) Add a graph background gradient. Make the colors also easily changed by the user. Ideally, make them updateable from the Storyboard Attributes Inspector and the gradient render in your storyboard.

Here is what your output should look like when you are finished:

![](http://ironboard-curriculum-content.s3.amazonaws.com/iOS/graphPlotter-Part1/graphPlotter-Part1.png)

## Resources

If you need a reminder on how to make objects `IBInspectable` and views `IB_DESIGNABLE`, check out [an article](http://nshipster.com/ibinspectable-ibdesignable/).

## Hints

* Helper methods might be useful to create to save you some time with repetitive tasks!

* Don't forget to release references you create yourself!
