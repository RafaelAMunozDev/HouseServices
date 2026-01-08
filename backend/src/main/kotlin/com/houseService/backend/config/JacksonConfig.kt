import com.fasterxml.jackson.databind.ObjectMapper
import com.fasterxml.jackson.databind.PropertyNamingStrategies
import com.fasterxml.jackson.module.kotlin.KotlinModule
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration

@Configuration
class JacksonConfig {

    // se configura el objectmapper para que use snake_case y soporte kotlin

    @Bean
    fun objectMapper(): ObjectMapper {
        // se registra el modulo kotlin y se asigna la estrategia de nombres
        val mapper = ObjectMapper()
        mapper.registerModule(KotlinModule.Builder().build())
        mapper.propertyNamingStrategy = PropertyNamingStrategies.SNAKE_CASE
        return mapper
    }
}
