package com.google.android.testing.nativedriver.server;

import javax.servlet.ServletException;
import javax.servlet.ServletConfig;
import javax.servlet.ServletRequest;
import javax.servlet.ServletResponse;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;

import android.util.Log;

public class SeleGridProxyServlet extends HttpServlet
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
     HttpServletRequest httpreq = (HttpServletRequest)req;
     try
     {
       if(httpreq.getPathInfo().endsWith("hub/status"))//Answer Grid's health pings
  	res.getWriter().
		println("{'status': 0, 'sessionId': null, 'value': {'build': {'version': 'AppDriver Android Native Apps'}}}");
       else 
		this.getServletContext().getContext("/hub")
		.getRequestDispatcher(httpreq.getPathInfo().replaceAll("/hub",""))
		.forward(req, res);
     }
     catch(Exception e)
     {
       Log.e("appdriver","Problem processing "+httpreq.getPathInfo()+" - "+e.toString());
     }
 }

 @Override
 public String getServletInfo()
 {
     return "For Selenium Grid2 support";
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
