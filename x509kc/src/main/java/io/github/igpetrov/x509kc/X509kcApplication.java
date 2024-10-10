package io.github.igpetrov.x509kc;

import com.fasterxml.jackson.annotation.JsonInclude;
import com.fasterxml.jackson.databind.DeserializationFeature;
import com.fasterxml.jackson.databind.ObjectMapper;
import jakarta.ws.rs.client.Client;
import jakarta.ws.rs.client.ClientBuilder;
import java.security.NoSuchAlgorithmException;
import javax.net.ssl.SSLContext;
import org.apache.http.conn.ssl.NoopHostnameVerifier;
import org.keycloak.OAuth2Constants;
import org.keycloak.admin.client.Keycloak;
import org.keycloak.admin.client.KeycloakBuilder;
import org.springframework.boot.CommandLineRunner;
import org.springframework.boot.SpringApplication;
import org.springframework.boot.autoconfigure.SpringBootApplication;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;

@SpringBootApplication
@Configuration
public class X509kcApplication implements CommandLineRunner {

  @Override
  public void run(String... args) throws Exception {
    System.out.println("Starting Keycloak...");
  }

  @Bean
  public Client resteasyClient() throws NoSuchAlgorithmException {
    var objectMapper = new ObjectMapper();
    objectMapper.configure(DeserializationFeature.FAIL_ON_UNKNOWN_PROPERTIES, false);
    objectMapper.setSerializationInclusion(JsonInclude.Include.NON_NULL);

    return ClientBuilder.newBuilder()
        .sslContext(SSLContext.getDefault())
        .hostnameVerifier(NoopHostnameVerifier.INSTANCE)
        .build();
  }

  @Bean
  public Keycloak keycloakAdmin(Client resteasyClient) {
    final Keycloak keycloakClient = KeycloakBuilder.builder()
        .serverUrl("https://localhost:18443/auth")
        .realm("master")
        .grantType(OAuth2Constants.CLIENT_CREDENTIALS)
        .clientId("qwerty")
        .clientSecret("xxxxxxx")
        .resteasyClient(resteasyClient)
        .build();
    
    // dummy call
    final var serverInfo = keycloakClient.serverInfo().getInfo();
    
    return keycloakClient;
  }

  public static void main(String[] args) {
    SpringApplication.run(X509kcApplication.class, args);
  }

}
