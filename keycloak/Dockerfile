FROM quay.io/keycloak/keycloak:26.3.3

ENV KC_HEALTH_ENABLED=true
ENV KC_METRICS_ENABLED=true

EXPOSE 8080

ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start-dev"]
