/*
Copyright 2011 NativeDriver committers
Copyright 2011 Google Inc.

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

     http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package com.google.iphone.testing.nativedriver.client;

import com.google.common.collect.ImmutableMap;
import org.openqa.selenium.*;
import org.openqa.selenium.remote.*;
import org.openqa.selenium.remote.internal.JsonToWebElementConverter;
import org.openqa.selenium.html5.Location;
import org.openqa.selenium.html5.LocationContext;
import org.openqa.selenium.remote.html5.RemoteLocationContext;


import java.net.MalformedURLException;
import java.net.URL;
import java.util.List;

/**
 * Represents an iOS NativeDriver client used to drive native iOS applications.
 *
 * @author Tomohiro Kaizu
 */
public class IosNativeDriver
        extends RemoteWebDriver implements FindsByText, FindsByPlaceholder, HasTouchScreen, Rotatable  {
    /**
     * Default URL for iOS NativeDriver.
     */
    protected static final String DEFAULT_URL = "http://localhost:3001/hub";
    private TouchScreen touch;

    /**
     * Creates an {@code IosNativeDriver} connected to the remote address.
     *
     * @param remoteAddress The full URL of the remote client (device or
     *                      simulator) running NativeDriver.
     */
    public IosNativeDriver(URL remoteAddress) {
        super(remoteAddress, DesiredCapabilities.iphone());
        setElementConverter(new JsonToWebElementConverter(this) {
            @Override
            protected RemoteWebElement newRemoteWebElement() {
                return new IosNativeElement(IosNativeDriver.this);
            }
        });
        init();
    }

    /**
     * Creates an {@code IosNativeDriver} connected to the remote address.
     *
     * @param remoteAddress The full URL of the remote client (device or
     *                      simulator) running NativeDriver.
     * @param capabilities  The DesiredCapabilities
     */
    public IosNativeDriver(URL remoteAddress, DesiredCapabilities capabilities) {
        super(remoteAddress, capabilities);
        setElementConverter(new JsonToWebElementConverter(this) {
            @Override
            protected RemoteWebElement newRemoteWebElement() {
                return new IosNativeElement(IosNativeDriver.this);
            }
        });
        init();
    }

    /**
     * Creates an {@code IosNativeDriver} connected to the remote address.
     *
     * @param remoteAddress The full URL of the remote client (device or
     *                      simulator) running NativeDriver.
     * @param capabilities  The DesiredCapabilities
     * @param location      Set the Geographical location of the remote client
     *                      (device or simulator) running NativeDriver.
     *
     */
    public IosNativeDriver(URL remoteAddress, DesiredCapabilities capabilities, Location location) {
        super(remoteAddress, capabilities);
        setElementConverter(new JsonToWebElementConverter(this) {
            @Override
            protected RemoteWebElement newRemoteWebElement() {
                return new IosNativeElement(IosNativeDriver.this);
            }
        });
        initWithLocation(location);
    }

    /**
     * Creates an {@code IosNativeDriver} connected to the remote address.
     *
     * @param remoteAddress The full URL of the remote client (device or
     *                      simulator) running NativeDriver.
     */
    public IosNativeDriver(String remoteAddress) {
        this(newUrl(remoteAddress));
        init();
    }

    /**
     * Creates an {@code IosNativeDriver} connected to a client (device or
     * simulator) running on the local machine.
     */
    public IosNativeDriver() {
        this(DEFAULT_URL);
        init();
    }

    /**
     * Converts address to URL object. If the address is malformed, throws a
     * runtime exception.
     */
    private static URL newUrl(String address) {
        try {
            return new URL(address);
        } catch (MalformedURLException exception) {
            throw new RuntimeException(exception);
        }
    }

    @Override
    public IosNativeElement findElement(org.openqa.selenium.By by) {
        return (IosNativeElement) super.findElement(by);
    }

    @SuppressWarnings({"unchecked", "rawtypes"})
    public List<IosNativeElement> findIosNativeElements(
            org.openqa.selenium.By by) {
        return (List) findElements(by);
    }

    @Override
    public WebElement findElementByPlaceholder(String using) {
        return findElement(USING_PLACEHOLDER, using);
    }

    @Override
    public List<WebElement> findElementsByPlaceholder(String using) {
        return findElements(USING_PLACEHOLDER, using);
    }

    @Override
    public WebElement findElementByText(String using) {
        return findElement(USING_TEXT, using);
    }

    @Override
    public List<WebElement> findElementsByText(String using) {
        return findElements(USING_TEXT, using);
    }

    @Override
    public WebElement findElementByPartialText(String using) {
        return findElement(USING_PARTIALTEXT, using);
    }

    @Override
    public List<WebElement> findElementsByPartialText(String using) {
        return findElements(USING_PARTIALTEXT, using);
    }

    private void init() {
        touch = new RemoteTouchScreen(getExecuteMethod());
    }

    /**
     * Initialise with GeoLocation
     */
    private void initWithLocation(Location location) {
        touch = new RemoteTouchScreen(getExecuteMethod());
        setLocation(location);
    }

    public TouchScreen getTouch() {
        return touch;
    }

    /**
     * Private method to set the geo location on the device or emulator
     */
    private void setLocation(Location loc) {
        RemoteLocationContext rc = new RemoteLocationContext(getExecuteMethod());
        rc.setLocation(loc);
    }


    public void rotate(ScreenOrientation orientation) {
        execute(DriverCommand.SET_SCREEN_ORIENTATION, ImmutableMap.of("orientation", orientation));
    }

    public ScreenOrientation getOrientation() {
        return ScreenOrientation.valueOf(
                (String) execute(DriverCommand.GET_SCREEN_ORIENTATION).getValue());
    }
}
