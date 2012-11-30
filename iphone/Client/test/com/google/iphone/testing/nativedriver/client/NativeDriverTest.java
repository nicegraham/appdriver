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

import com.sun.jna.ptr.PointerByReference;
import junit.framework.TestCase;

import org.openqa.selenium.*;
import org.openqa.selenium.By;
import org.openqa.selenium.interactions.touch.TouchActions;
import org.openqa.selenium.remote.DesiredCapabilities;
import org.openqa.selenium.server.RemoteControlConfiguration;
import org.openqa.selenium.server.SeleniumServer;


import java.net.URL;
import java.util.ArrayList;
import java.util.List;
import java.util.concurrent.TimeUnit;

/**
 * Sample test for iOS NativeDriver.
 *
 * @author Tomohiro Kaizu
 */
public class NativeDriverTest extends TestCase {

    SeleniumServer seleniumServer;
    WebDriver driver;


    public void testNativeDriver() throws Exception {

        driver = new IosNativeDriver();
        //driver = new IosNativeDriver("http://192.168.0.102:3001/hub");
        driver.manage().timeouts().implicitlyWait(10, TimeUnit.SECONDS);

        messWithHybridApp();

        //findAndPrintAllElements();

        //UITextField
        //WebElement fromGps = driver.findElement(By.placeholder("From GPS"));
        //fromGps.click();

        //WebElement dummy = driver.findElement(By.placeholder("From GPS"));

        //WebElement fromGps = driver.findElements(org.openqa.selenium.By.className("UIButton")).get(6);
        //fromGps.click();


        //TouchActions touchActions = new TouchActions(driver);
        //touchActions.flick(fromGps, 10, 0, 0);
        //touchActions.longPress(fromGps).perform();
//        touchActions.down(50, 50).perform();
//        Thread.sleep(500);
//        touchActions.up(50, 50).perform();
//        touchActions.move(50, 50).perform();
//        touchActions.scroll(fromGps, 50, 50).perform();
//        touchActions.doubleTap(fromGps).perform();
//        touchActions.longPress(fromGps).perform();
//        touchActions.flick(50, 50).perform();
//        touchActions.flick(fromGps, 50, 50, 10);



        //findAndPrintAllElements();


        //fromGps.click();

        // Type user name
        //WebElement userName = driver.findElement(By.placeholder("User Name"));
        //userName.clear();
        //userName.sendKeys("NativeDriver");

        //driver.findElement(By.placeholder("From GPS")).sendKeys("12345");


        /*
        // Type user name
        WebElement userName = driver.findElement(By.placeholder("User Name"));
        userName.clear();
        userName.sendKeys("NativeDriver");
        // Type password
        WebElement password = driver.findElement(By.placeholder("Password"));
        password.clear();
        password.sendKeys("abcdefgh");
        // Tap "Sign in" button
        driver.findElement(By.text("Sign in")).click();

        // Verify correct title is displayed
        String text = driver.getTitle();
        assertEquals("NativeDriver", text);

        // Type text in WebView
        WebElement element = driver.findElement(By.name("q"));
        element.sendKeys("NativeDriver");
        element.submit();

        // Click link
        driver.findElement(By.partialLinkText("GUI automation")).click();
        // Verify the page
        assertEquals("nativedriver", driver.findElement(By.id("pname")).getText());
        */
    }

    public DesiredCapabilities getCapabilities() {

        DesiredCapabilities capabilities = new DesiredCapabilities();
        capabilities = DesiredCapabilities.iphone();
        capabilities.setVersion("8");

        return capabilities;
    }


    public void messWithHybridApp() throws InterruptedException {

        WebElement webViewElement = driver.findElement(By.className("UIWebView"));
        //WebElement loginhomepage = webViewElement.findElement(By.xpath("//span[.='Login']"));
        //WebElement loginbutton = webViewElement.findElement(By.id("LoginButtonId"));
        //WebElement edtUsername = webViewElement.findElement(By.name("userName"));
        //WebElement edtPassword = webViewElement.findElement(By.name("password"));

        String username = "jorge_abernathy_4bmv";
        String password = "testing1";

        webViewElement.findElement(By.xpath("//span[.='Login']")).click();
        Thread.sleep(1000);
        webViewElement.findElement(By.name("userName")).sendKeys(username);
        webViewElement.findElement(By.name("password")).sendKeys(password);
        Thread.sleep(1000);
        webViewElement.findElement(By.id("LoginButtonId")).click();
        Thread.sleep(6000);
        if (webViewElement.findElement(By.className("prompt_button")).isDisplayed()){
            webViewElement.findElement(By.className("prompt_button")).click();
            System.out.println("'Invalid_username' button FOUND");
            System.out.println("'Invalid_username' button textlabel = " + webViewElement.findElement(By.className("prompt_button")).getText());
            System.out.println("'Invalid_username' button location coords = " + webViewElement.findElement(By.className("prompt_button")).getLocation());
            Thread.sleep(2000);
        } else {
            System.out.println("Invalid username button NOT FOUND");
        }

        webViewElement.findElement(By.className("button_home")).click();
        Thread.sleep(2000);

        if (webViewElement.findElement(By.id("cat_Table Games")).isDisplayed()){
            System.out.println("'Table Games' button FOUND");
            System.out.println("'Table Games' button textlabel = " + webViewElement.findElement(By.id("cat_Table Games")).getText());
            System.out.println("'Table Games' button location coords = " + webViewElement.findElement(By.id("cat_Table Games")).getLocation());
            webViewElement.findElement(By.id("cat_Table Games")).click();
            Thread.sleep(2000);

        }

        webViewElement.findElement(By.className("button_home")).click();



        //login.clear();
        /*
        String getText = login.getText();
        boolean isdisplayed = login.isDisplayed();
        //String getAttribute = login.getAttribute("placeholder");
        //Point getLocation = login.getLocation();
        //Dimension getSize = login.getSize();      //not implemented
        boolean isEnabled = login.isEnabled();
        boolean isSelected = login.isSelected();
        login.sendKeys(Keys.ENTER);
        */

        //List<WebElement> spans = webViewElement.findElements(By.id("cat_Table Games"));




    }


    public void findAndPrintAllElements() {

        ArrayList<String> uiElements = new ArrayList<String>();
        uiElements.add("UIButton");
        uiElements.add("UISwitch");
        uiElements.add("UITextField");
        uiElements.add("UITextView");
        uiElements.add("UIWebView");
        uiElements.add("UIView");
        uiElements.add("UISwitch");
        uiElements.add("UILabel");


        for (String element : uiElements) {

            List<WebElement> webelement = driver.findElements(org.openqa.selenium.By.className(element));

            for (int i = 0; i < webelement.size(); i++) {
                System.out.println("");
                System.out.println(element + " Placeholder -- > " + webelement.get(i).getAttribute("placeholder"));
                System.out.println(element + " Text -- > " + webelement.get(i).getText());
                System.out.println(element + " Displayed -- > " + webelement.get(i).isDisplayed());
                System.out.println(element + " Enabled -- > " + webelement.get(i).isEnabled());
                System.out.println("");
            }

        }

    }

}
