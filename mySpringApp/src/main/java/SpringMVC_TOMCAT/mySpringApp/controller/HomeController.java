package SpringMVC_TOMCAT.mySpringApp.controller;

import java.io.IOException;

import javax.servlet.http.HttpServletResponse;
import javax.ws.rs.client.Client;
import javax.ws.rs.client.ClientBuilder;
import javax.ws.rs.core.MediaType;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.servlet.ModelAndView;

@Controller
public class HomeController {

	@RequestMapping(value="/helloMVC")
	public ModelAndView test(HttpServletResponse response) throws IOException{
		
		System.out.println("Spring MVC");
		Client client1 = ClientBuilder.newClient();
		System.out.println("setting client");
		String name = client1.target("http://springtomcat:8082/helloTomcat")
		        .request(MediaType.TEXT_PLAIN)
		        .get(String.class);
		/*String name = client1.target("http://rating:8082/Hello")
		        .request(MediaType.TEXT_PLAIN)
		        .get(String.class);*/
		
		return new ModelAndView("home");
	}
}
