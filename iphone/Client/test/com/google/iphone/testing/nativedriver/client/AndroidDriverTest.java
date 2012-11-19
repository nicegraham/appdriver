package com.google.iphone.testing.nativedriver.client;

import junit.framework.TestCase;
import org.openqa.selenium.WebDriver;
import org.openqa.selenium.android.AndroidDriver;

/**
 * Created with IntelliJ IDEA.
 * User: dgrace
 * Date: 16/11/2012
 * Time: 09:31
 * To change this template use File | Settings | File Templates.
 */
public class AndroidDriverTest extends TestCase {

    WebDriver driver;

    public void testAndroidDriver(){

        driver = new AndroidDriver();

    }
}
