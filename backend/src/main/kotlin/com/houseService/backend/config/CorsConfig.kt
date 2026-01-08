package com.houseService.backend.config

import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.web.cors.CorsConfiguration
import org.springframework.web.cors.UrlBasedCorsConfigurationSource
import org.springframework.web.filter.CorsFilter

@Configuration
class CorsConfig {

    // se configura cors para permitir peticiones externas

    @Bean
    fun corsFilter(): CorsFilter {
        // se crean las reglas cors permitiendo todos los origenes, metodos y headers
        val source = UrlBasedCorsConfigurationSource()
        val config = CorsConfiguration()

        config.allowedOriginPatterns = listOf("*")
        config.allowedMethods = listOf("GET", "POST", "PUT", "DELETE", "OPTIONS")
        config.allowedHeaders = listOf("*")
        config.allowCredentials = true

        source.registerCorsConfiguration("/**", config)
        return CorsFilter(source)
    }
}
