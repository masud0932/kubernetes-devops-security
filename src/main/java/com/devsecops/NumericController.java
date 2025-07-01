package com.devsecops;

import org.springframework.web.bind.annotation.*;

@RestController
public class NumericController {

    @GetMapping("/")
    public String welcome() {
        return "Kubernetes DevSecOps";
    }

    @GetMapping("/compare/{value}")
    public String compareToFifty(@PathVariable int value) {
        if (value > 50) {
            return "Greater than 50";
        } else {
            return "Smaller than or equal to 50";
        }
    }
}
