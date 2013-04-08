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
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />

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

But it needs to create a temp file on the available sdcard so when the app is compiled, along with the instrumentation line in AndroidManifest.xml be sure to add: 

        <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" /> 

This is because accessing the view object to get a screenshot must happen
on the UI thread. AFAIK, there is no straight-forward way to return data from the
runOnUiThread(Runnable) so the image is first written to __/sdcard/appdriver_screenshot.png__ . After the Runnable object is done, the image is then read back into memory and returned to the WebDriver as a base64 encoded string. e.g.

    import base64
    fd = open("whatmyapplookslike.png","w")
    fd.write(base64.decodestring(driver.get_screenshot_as_base64()))
    fd.close()
