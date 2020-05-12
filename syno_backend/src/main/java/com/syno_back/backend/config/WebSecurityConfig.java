package com.syno_back.backend.config;

import com.syno_back.backend.jwt.auth.JwtAuthEntryPoint;
import com.syno_back.backend.jwt.auth.JwtAuthTokenFilter;
import com.syno_back.backend.service.UserDetailServiceImpl;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;
import org.springframework.security.authentication.AuthenticationManager;
import org.springframework.security.config.annotation.authentication.builders.AuthenticationManagerBuilder;
import org.springframework.security.config.annotation.method.configuration.EnableGlobalMethodSecurity;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.annotation.web.configuration.WebSecurityConfigurerAdapter;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.core.userdetails.UserDetailsService;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;

/**
 * Configures WebSecurity components: BCryptPasswordEncoder, JwtAuthTokenFilter and AuthenticationManager
 * @see BCryptPasswordEncoder
 * @see JwtAuthTokenFilter
 * @see AuthenticationManager
 */
@Configuration
@EnableWebSecurity
@EnableGlobalMethodSecurity(prePostEnabled = true)
public class WebSecurityConfig extends WebSecurityConfigurerAdapter {

    /** Service for fetching user's credentials from DB */
    @Autowired
    private UserDetailServiceImpl userDetailsService;

    /**
     * Service for filtering requests which needs auth
     */
    @Autowired
    private JwtAuthEntryPoint authHandler;

    /**
     * Gets password encoder bean
     * @return new BCryptPasswordEncoder instance
     * @see BCryptPasswordEncoder
     */
    @Bean
    BCryptPasswordEncoder bCryptPasswordEncoder() {
        return new BCryptPasswordEncoder();
    }

    /**
     * Gets JwtAuthTokenFilter bean
     * @return new JwtAuthTokenFilter instance
     * @see JwtAuthTokenFilter
     */
    @Bean
    JwtAuthTokenFilter authenticationJwtTokenFilter() {
        return new JwtAuthTokenFilter();
    }

    /**
     * Configures AuthenticationManagerBuilder with `userDetailsService` and `bCryptPasswordEncoder`
     * @param auth AuthenticationManagerBuilder instance
     */
    @Override
    protected void configure(AuthenticationManagerBuilder auth) throws Exception {
        auth.userDetailsService(userDetailsService).passwordEncoder(bCryptPasswordEncoder());
    }

    /**
     * Gets AuthenticationManager bean
     * @return new AuthenticationManager instance
     * @see AuthenticationManager
     */
    @Bean
    @Override
    public AuthenticationManager authenticationManagerBean() throws Exception {
        return super.authenticationManagerBean();
    }

    /**
     * Completes configuration for HttpSecurity
     * @param http HttpSecurity instance
     * @see HttpSecurity
     */
    @Override
    protected void configure(HttpSecurity http) throws Exception {
        http.csrf().disable().authorizeRequests()
                .antMatchers("/**").permitAll()
                .anyRequest().authenticated()
                .and()
                .exceptionHandling().authenticationEntryPoint(authHandler)
                .and()
                .sessionManagement().sessionCreationPolicy(SessionCreationPolicy.STATELESS);

        http.addFilterBefore(authenticationJwtTokenFilter(), UsernamePasswordAuthenticationFilter.class);
    }
}
