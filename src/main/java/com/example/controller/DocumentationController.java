package com.example.controller;

import com.example.config.ApiRoutes;
import io.swagger.v3.oas.annotations.Hidden;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@Hidden
@RequestMapping(ApiRoutes.BASE_V1)
public class DocumentationController {

    @GetMapping({"/redoc", "/redoc.html"})
    public String redoc() {
        return "forward:/redoc.html";
    }
}
