Continuation of the NativeDriver project

The original project homepage can be found here: http://code.google.com/p/nativedriver/

The primary updates involve removing the old touch emulation libary - TouchSynthesis. This seems to have become defunct and the most recent version didn't work with iOs6. We decided to try and use Apple's own UIAutomation framework, while researching this and other available tools we came across PublicAutomation which is a wrapper around this private framework which should provide a more consistent interface to program against. PublicAutomation was created by the http://testingwithfrank.com/ team, they provide a test framework fr native apps using cucumber. For our purposes NativeDriver seems like a better fit, mainly due to our infrastructure having been built around Selenium, Java is our primary language and a lot of our apps using webviews extensively. 

