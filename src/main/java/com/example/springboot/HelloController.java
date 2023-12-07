package com.example.springboot;

import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
public class HelloController {

	/*@GetMapping("/")
	public String index() {
		return "Greetings from Spring Boot!";
	}*/
	@GetMapping("/")
        public String welcome(Model model) {
            // Obtener la fecha y hora actuales
            LocalDateTime now = LocalDateTime.now();
            DateTimeFormatter formatter = DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm:ss");
            String formattedDateTime = now.format(formatter);

            // Agregar datos al modelo
            model.addAttribute("message", "¡Bienvenido!");
            model.addAttribute("currentDateTime", formattedDateTime);

            // Devolver el nombre de la plantilla (template)
            return "welcome";
        }
}
