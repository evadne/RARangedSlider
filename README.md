# RARangedSlider

Ranged two-knob slider for iOS implemented as an `UIControl` subclass.


## Sample

Look at the [Sample App](https://github.com/evadne/RARangedSlider-Sample).  It contains a vanilla application with a ranged slider and logging set-up in place.


## What’s Inside

You’ll mostly find `RARangedSlider`, which takes four things: `minValue`, `maxValue`, `lowValue` and `highValue`. The `minValue` and `maxValue` properties are modeled after `UISlider`: by default, it goes from `0.0f` to `1.0f`, but you can specify another range for the slider to emit `lowValue` and `highValue` in. The `lowValue` and `highValue` are represented by two visually identical thumbs; the one on the left uses `lowValue`.

If you drag a thumb over another, it’ll still work. You can switch `continuous` on or off to control if `UIControlEventValueChanged` is sent to your target immediately upon tracking changes. There’s a `-setLowValue:highValue:animated:completion:` provided for your pleasure. 

Drop the control into your project as a static library, and drop the bundle containing stock artwork into your project as well. Appearance customization and value configuration animation are both supported.


## Licensing

This project is in the public domain.  You can use it and embed it in whatever application you sell, and you can use it for evil.  However, it is appreciated if you provide attribution, by linking to the project page ([https://github.com/evadne/RAContentStretchingView](https://github.com/evadne/RARangedSlider)) from your application.


## Credits

*	[Evadne Wu](http://twitter.com/evadne) at Radius ([Info](http://radi.ws))
