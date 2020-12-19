package com.syno_back.applinks.demo.controllers;

import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.io.ClassPathResource;
import org.springframework.core.io.Resource;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;

import java.io.BufferedReader;
import java.io.IOException;
import java.io.InputStreamReader;
import java.nio.charset.StandardCharsets;

@CrossOrigin(origins = {"*"}, maxAge = 3600)
@RestController
@RequestMapping("/")
public class MainController {

    @GetMapping(
            value = "/apple-app-site-association",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public @ResponseBody Object getAssociation() {
        Resource resource = new ClassPathResource("/static/association.json");
        try {
            ObjectMapper mapper = new ObjectMapper();
            return mapper.readValue(resource.getInputStream(), Object.class);
        } catch (IOException e) {
            e.printStackTrace();
        }
        return null;
    }

    @GetMapping(
            value = "/share/{id}",
            produces = MediaType.APPLICATION_JSON_VALUE
    )
    public @ResponseBody Object getShare(@PathVariable String id) throws IOException {
        return getAssociation();
    }
}
