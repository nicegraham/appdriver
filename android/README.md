Android support of appdriver
=
  I use appium for iOS but appdriver for android. appium has android support, but it's sorta experimental and only supports android-17 right now. I need to test 2.3.x and 4.x. I added support for android-17.  Why am I using appium & appdriver at all? Because using Selenium framework is probably the best & widely-supported open-source way to deal with automated UI tests with parallelism. Also, it seems appium & appdriver are the best(only?) options for native iOS & Android apps to be connected to Selenium-Grid.


Other things I've added(python examples)
=
 This didn't work before, now it does:

    driver.find_element_by_tag_name()


Also, note that the following still doesn't work:

    driver.page_source()

So instead, I added special-case logic to the tag_name search such that you can get a list of all elements by giving a zero-length string to the plural tag search:

    driver.find_elements_by_tag_name("")

Finally, since I'm using python I wrote a wrapper to send Android Native Keys:

    AndroidNativeKeys.presskey(driver,AndroidNativeKeys.MENU)

Look at the source of AndroidNativeKeys.py to see all possible buttons.

Also, this works now..

    driver.get_screenshot_as_base64()

But it needs to create a temp file on the available sdcard so when you compile your app, along with the instrumentation line you add to AndroidManifest.xml be sure to add the following:

        <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" /> 

This is because accessing the view object to get a screenshot must happen
on the UI thread. AFAIK, there is no straight-forward way to return data from the
runOnUiThread(Runnable) so I have it writing the data to __/sdcard/appdriver_screenshot.png__ . After the Runnable object is done, I then read from that file, base64 encode it and return it to the WebDriver object.

