"""
HOW TO USE:

import AndroidNativeKeys
from selenium import webdriver
driver = webdriver.Remote("http://localhost:54129/hub",{})
driver.get("and-activity://com.rackspacecloud.android.ListAccountsActivity")
AndroidNativeKeys.presskey(driver,AndroidNativeKeys.MENU)
"""

import httplib,re

ALT_LEFT='\xee\x80\x8a'
DEL='\xee\x80\x97'
DPAD_DOWN='\xee\x80\x95'
DPAD_LEFT='\xee\x80\x92'
DPAD_UP='\xee\x80\x93'
DPAD_RIGHT='\xee\x80\x94'
ENTER='\xee\x80\x87'
SHIFT_LEFT='\xee\x80\x88'
BACK='\xee\x84\x80'
HOME='\xee\x84\x81'
MENU='\xee\x84\x82'
SEARCH='\xee\x84\x83'
SYM='\xee\x84\x84'
ALT_RIGHT='\xee\x84\x85'
SHIFT_RIGHT='\xee\x84\x86'

def presskey(driver,keyevent):
    param_tuple = re.findall(".*//(.*):(.+?)/(.*)",driver.command_executor._url)[0]
    host = param_tuple[0]
    port = param_tuple[1] 
    path = param_tuple[2]
    conn = httplib.HTTPConnection(host,int(port))
    conn.connect()
    conn.putrequest('POST','/'+path+'/session/'+driver.session_id+'/element//value')#Yes, double-slashes must be here!
    headers = {}
    headers['Content-Type'] = 'application/json; charset=utf-8'
    headers['Content-Length'] = '17'
    headers['Connection'] = 'close'
    headers['User-Agent'] = 'AndroidNativeKeys.py'
    headers['Accept'] = '*/*'
    for h in headers:
        conn.putheader(h, headers[h])
    conn.endheaders()
    conn.send('{"value":["'+keyevent+'"]}')
    return conn.getresponse()

"""
How did I come up with this? I used wireshark to observe what tests written in java send over the wire.
I really have no idea where these keycodes come from; they don't match "adb input keyevent".

e.g.:
  
import com.google.android.testing.nativedriver.client.AndroidNativeDriver;
import com.google.android.testing.nativedriver.client.AndroidNativeDriverBuilder;
import com.google.android.testing.nativedriver.common.AndroidKeys;

class Keytest
{
    public static void main(String args[])
    {
            AndroidNativeDriver driver = new AndroidNativeDriverBuilder().withDefaultServer().build();
            driver.startActivity("com.rackspacecloud.android.ListAccountsActivity");
            driver.getKeyboard().sendKeys(AndroidKeys.MENU);
            driver.getKeyboard().sendKeys(AndroidKeys.BACK);
    }
}
"""
