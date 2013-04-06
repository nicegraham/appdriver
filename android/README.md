Android support of appdriver
=




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
