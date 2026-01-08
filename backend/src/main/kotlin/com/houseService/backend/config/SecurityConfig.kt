package com.houseService.backend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.security.config.annotation.web.builders.HttpSecurity
import org.springframework.security.web.SecurityFilterChain

@Configuration
class SecurityConfig {

    // se configura la seguridad http, por ahora se permite todo

    @Bean
    fun filterChain(http: HttpSecurity): SecurityFilterChain {
        // se desactiva la proteccion csrf y se permiten todas las rutas
        http
            .csrf { it.disable() }
            .authorizeHttpRequests {
                it
                    .requestMatchers("/**").permitAll()
                    .anyRequest().authenticated()
            }

        return http.build()
    }
}
