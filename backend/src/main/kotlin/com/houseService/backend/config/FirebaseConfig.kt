package com.houseService.backend.config

import com.google.auth.oauth2.GoogleCredentials
import com.google.firebase.FirebaseApp
import com.google.firebase.FirebaseOptions
import org.springframework.context.annotation.Bean
import org.springframework.context.annotation.Configuration
import org.springframework.core.io.ClassPathResource
import java.io.FileInputStream
import java.io.IOException
import java.io.InputStream

@Configuration
class FirebaseConfig {

    // se configura la instancia de firebase pa usarla en el proyecto

    @Bean
    @Throws(IOException::class)
    fun firebaseApp(): FirebaseApp {

        // pillamos el json desde un path si estamos en docker, y si no desde resources
        val rutaJson = System.getenv("FIREBASE_SERVICE_ACCOUNT_PATH")

        // se abre el stream del json segun el entorno
        val serviceAccount: InputStream = if (!rutaJson.isNullOrBlank()) {
            FileInputStream(rutaJson)
        } else {
            ClassPathResource("firebase-service-account.json").inputStream
        }

        // bucket configurable por entorno, si no hay variable se usa el de siempre
        val bucket = System.getenv("FIREBASE_STORAGE_BUCKET")
            ?: "houseservices-7f45b.firebasestorage.app"

        val options = FirebaseOptions.builder()
            .setCredentials(GoogleCredentials.fromStream(serviceAccount))
            .setStorageBucket(bucket)
            .build()

        return if (FirebaseApp.getApps().isEmpty()) {
            FirebaseApp.initializeApp(options)
        } else {
            FirebaseApp.getInstance()
        }
    }
}
