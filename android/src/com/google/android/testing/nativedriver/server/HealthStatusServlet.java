package com.google.android.testing.nativedriver.server;

import javax.servlet.ServletException;
import javax.servlet.ServletConfig;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;

import android.util.Log;

public class HealthStatusServlet extends HttpServlet
{ 
 private ServletConfig config;
 @Override
 public void init(ServletConfig config) throws ServletException
 {
  this.config = config;
 }

 @Override 
 public void service(ServletRequest req, ServletResponse res)
 {
     try
     {
  	res.getWriter().
		println("{'status': 0, 'sessionId': null, 'driverName':'Appdriver'}");
     }
     catch(Exception e)
     {
                Log.e("appdriver","HealthStatusServlet encountered a problem - "+e.toString());
     }
 }

 @Override
 public String getServletInfo()
 {
     return "For replying Grid2's /wd/hub/status queries.";
 }

 @Override
 public ServletConfig getServletConfig()
 {    
    return this.config;
 }

 @Override
 public void destroy()
 {
  //Do Nothing
 }
}
