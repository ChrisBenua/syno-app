package com.syno_back.backend.jwt.auth;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.web.authentication.WebAuthenticationDetailsSource;
import org.springframework.web.filter.OncePerRequestFilter;

import javax.servlet.FilterChain;
import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;

import com.syno_back.backend.service.UserDetailServiceImpl;

/**
 * Adds authorization filtering
 */
public class JwtAuthTokenFilter extends OncePerRequestFilter {

    /**
     * Service for validating tokens
     */
    @Autowired
    private JwtProvider tokenProvider;

    /**
     * Service for fetching info about users from DB
     */
    @Autowired
    private UserDetailServiceImpl userDetailsService;

    @Override
    protected void doFilterInternal(HttpServletRequest httpServletRequest, HttpServletResponse httpServletResponse,
                                    FilterChain filterChain) throws ServletException, IOException {
        try {
            var jwt = getJwt(httpServletRequest);
            if (jwt != null && tokenProvider.validateJwtToken(jwt)) {
                var email = tokenProvider.getEmailFromJwtToken(jwt);

                var userDetails = userDetailsService.loadUserByUsername(email);
                var authentication = new UsernamePasswordAuthenticationToken(userDetails, null, userDetails.getAuthorities());

                authentication.setDetails(new WebAuthenticationDetailsSource().buildDetails(httpServletRequest));
                SecurityContextHolder.getContext().setAuthentication(authentication);
            }
        } catch (Exception e) {
            logger.error(String.format("Can NOT set user auth: %s", e.getMessage()));
        }

        filterChain.doFilter(httpServletRequest, httpServletResponse);
    }

    /**
     * Gets authorization header from request
     * @param request <code><HttpServletRequest/code> instance
     * @return bearer token
     */
    private String getJwt(HttpServletRequest request) {
        var authHeader = request.getHeader("Authorization");

        if (authHeader.startsWith("Bearer ")) {
            return authHeader.replace("Bearer ", "");
        }
        return null;
    }

    private final static Logger logger = LoggerFactory.getLogger(JwtAuthTokenFilter.class);
}
