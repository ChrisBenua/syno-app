package com.syno_back.backend.jwt.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import org.springframework.security.core.AuthenticationException;
import org.springframework.security.web.AuthenticationEntryPoint;
import org.springframework.stereotype.Component;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

/**
 * Class for filtering unauthorized request for request that need authorization
 */
@Component
public class JwtAuthEntryPoint implements AuthenticationEntryPoint {
    @Override
    public void commence(javax.servlet.http.HttpServletRequest httpServletRequest,
                         javax.servlet.http.HttpServletResponse httpServletResponse, AuthenticationException e)
            throws IOException, ServletException {
        logger.error(String.format("Unauthorized error. Message: %s", e.getMessage()));
        httpServletResponse.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Invalid credentials");
    }

    private static final Logger logger = LoggerFactory.getLogger(JwtAuthEntryPoint.class);
}
