package com.example.config;

import io.opentelemetry.api.OpenTelemetry;
import io.opentelemetry.instrumentation.logback.appender.v1_0.OpenTelemetryAppender;
import org.springframework.boot.context.event.ApplicationReadyEvent;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.event.EventListener;

@Configuration
public class TelemetryLoggingConfig {

    private final OpenTelemetry openTelemetry;

    public TelemetryLoggingConfig(OpenTelemetry openTelemetry) {
        this.openTelemetry = openTelemetry;
    }

    @EventListener(ApplicationReadyEvent.class)
    public void installOpenTelemetryAppender(ApplicationReadyEvent event) {
        OpenTelemetryAppender.install(openTelemetry);
    }
}
