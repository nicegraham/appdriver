Android support of appdriver
=

A quick re-cap of how to use this,
- git clone this repo
- cd appdriver/android
- ant clean standalone-server
- cp build/server-standalone.jar /path/to/your/android/app/libs/.

Then make sure your app's AndroidManifest.xml has this added:

    <instrumentation android:targetPackage="com.yourcompany.appname"
           android:name="com.google.android.testing.nativedriver.server.ServerInstrumentation" />
    

NOTE: That targetPackage must be equal to your app's package name that's already in AndroidManifest.xml.

If you're using eclipse, be sure to rightclick on your project, BuildPath->ConfigureBuildPath->Libraries Tab-> then add the server-standalone.jar you just copied. Then click Order-and-export tab and make sure server-standalone.jar is checked.

If you plan on using ant,
- cd /path/to/your/android/app
- /path/to/androidsdk/tools/android update project -n com.yourcompany.yourapp -p .
- ant clean release

Install the app into the emulator or physical device and you should be ready to go:

    adb shell am instrument com.yourcompany.appname/com.google.android.testing.nativedriver.server.ServerInstrumentation

Port 54129 will now be ready for selenium requests to physical device or emulator. Note that emulator binds
localhost so you'll need some kinda socat/iptabes tool to do port-forwarding and make an emulator reachable from another machine.

__UPDATE__ 2013-04-28

This doesn't work:
    
    driver.get_window_size()
 
So, you can do this now:

    >>> driver.execute_script("getscreeninfo")
    u"{'heightPixels':'552','widthPixels':'1024','density':'1.0','scaledDensity':'1.0','xdpi':'164.61772','ydpi':'165.65218'}"


This now works:

     >>> driver.find_element('text','DEB').location_once_scrolled_into_view

For future features I may add, I've added being able to get the internal android viewId. Note that this can return null; apparently having a viewId isn't required by Android.:

    >>> driver.find_element("text","DEB").get_attribute("androidViewId")
    u'2131099713'

Some views can be cast to ScrollView, giving them the method fling(). If the view has an android view id, you can fling it by:

    >>> driver.find_element("text","DEB").get_attribute("androidViewId")
    u'2131099713'
    >>> driver.execute_script("fling", 2131099713, 52)
   
Where that 52 is equal to the velocity along the Y-axis of the fling. See documentation on ScrollView.fling()


And finally, probably the most important update.......

Touch events now use android.view.MotionEvent, so.... :

    >>> driver.find_element('text','DEB').location
    {'y': 128, 'x': 102}
    >>> driver.execute_script("tap",102,128)

Other tap commands are:

    >>> driver.execute_script("taphold",102,128)
    >>> driver.execute_script("taprelease",102,128)
    >>> driver.execute_script("tapcancel",102,128) #This stops a previous taphold
    >>> driver.execute_script("tapscroll",102,128)
    >>> driver.execute_script("tapmoveto",102,128)

I have no idea what tapscroll does, I just put it there because I see that it's defined in MotionEvent. If you want to scroll/swipe, you can do this:

    >>>  driver.execute_script("swipe",102,128,102,500)
This causes 3 MotionEvent instances. ACTION\_DOWN, ACTION\_MOVE, ACTION\_UP. So it's like you put your finger on the screen at x=102,y=128 then moved your finger straight down to x=102,y=500 then you removed your finger from the screen. If you wanted to, you could call taphold, tapmoveto, taprelease to get the same effect.

__*IMPORTANT*__ - You can only tap locations on screen that contain your app. You cannot tap on Android OS elements. Example, almost all android devices have a notification bar either at the top of the screen or the bottom of the screen. So, if you tried to tap a location on screen where the notification bar is, you will get an INJECT_EVENTS permission error. You cannot just add this permission to your AndroidManifest.xml either. The app has to be installed as system-app on a rooted device before you can click outside of the app. Same thing goes for the onscreen android keyboard.



__UPDATE__ 2013-04-06

This works now:

    driver.find_element_by_tag_name()


Still broken:

    driver.page_source()

So instead, added special-case logic to the tag_name search such that a list of all elements is returned by giving a zero-length string to the plural tag search:

    driver.find_elements_by_tag_name("")

For python people to reach Android's Native Keys, added AndroidNativeKeys.py:

    AndroidNativeKeys.presskey(driver,AndroidNativeKeys.MENU)



And screenshot now works:

    driver.get_screenshot_as_base64()

