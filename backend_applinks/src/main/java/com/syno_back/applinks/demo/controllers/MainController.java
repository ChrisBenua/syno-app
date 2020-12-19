package com.syno_back.applinks.demo.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.io.IOException;

@CrossOrigin(origins = {"*"}, maxAge = 3600)
@RestController
@RequestMapping("/")
public class MainController {

    @GetMapping(
            value = "/apple-app-site-association",
            produces = "application/pkcs7-mime"
    )
    public @ResponseBody Object getAssociation() throws IOException {
        Resource resource = new ClassPathResource("/static/association.json");

        return resource.getInputStream();
    }

    @GetMapping(
            value = "/share/{id}",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public @ResponseBody Object getShare(@PathVariable String id) throws IOException {
        return getAssociation();
    }
}
