# Descrizione Parametri Helm Chart GovWay FSE Gateway

## Parametri Generali

### Cloud Provider
```bash
--set cloudProvider="aws"
```
**Descrizione:** Nome del cloud provider dove verrà installata l'applicazione. Definisce il tipo di infrastruttura cloud target per il deployment (es. aws, azure, gcp).

### Image Pull Secrets
```bash
--set imagePullSecrets[0]="gatewayfse"
```
**Descrizione:** Nome del secret per accedere al docker registry che è stato creato nel paragrafo Creazione Secret per Accedere al Registry. Necessario per permettere a Kubernetes di scaricare le immagini container da registry privati.

### Entity Name
```bash
--set "govway.entityName=<ENTE>"
```
**Descrizione:** Il parametro <ENTE>, comune a tutti i microservizi di GovWay, è scelto durante la creazione e Configurazione PostgreSQL DB. Identifica l'ente o l'organizzazione per cui viene configurato il gateway.

## Parametri Secrets

### IAM Role (AWS)
```bash
--set "secrets.imarole=IAM-ROLE"
```
**Descrizione:** ARN AWS dello IAM-ROLE per l'autenticazione IRSA (Identity and Access Management Role for Service Accounts). Utilizzato per permettere ai pod Kubernetes di assumere ruoli IAM AWS per accedere ai servizi AWS in modo sicuro.

### Certificate ARN
```bash
--set "secrets.certificateArn=arn:aws:acm:us-west-2:xxxxx:certificate/xxxxxxx"
```
**Descrizione:** CertificateArn - ARN del certificato SSL/TLS gestito da AWS Certificate Manager (ACM). Utilizzato per configurare la terminazione SSL sull'Application Load Balancer AWS.

### Truststore ARN
```bash
--set "secrets.truststoreArn=aws:elasticloadbalancing:trustStoreArn"
```
**Descrizione:** TruststoreArn - ARN del trust store per AWS Elastic Load Balancing. Utilizzato per configurare la validazione dei certificati client nell'autenticazione mTLS (mutual TLS).

## Parametri Keystore

### Keystore Auth INI
```bash
--set keystore.keystore.authIni="A1GTW-INI.pfx"
```
**Descrizione:** Nome del file keystore in formato PKCS#12 (.pfx) contenente il certificato e la chiave privata per l'autenticazione verso i servizi INI (Infrastruttura Nazionale per l'Interoperabilità).

### Keystore Auth Centralizzato
```bash
--set keystore.authCentralizzato="auth-centralized-services.pfx"
```
**Descrizione:** Nome del file keystore in formato PKCS#12 (.pfx) contenente il certificato e la chiave privata per l'autenticazione verso i servizi centralizzati del sistema FSE.

## Parametri Truststore

### Truststore CA Salute
```bash
--set truststore.caSalute="trustStore.jks"
```
**Descrizione:** Nome del file truststore in formato JKS (Java KeyStore) contenente i certificati delle Certificate Authority (CA) per la validazione dei certificati dei servizi del dominio Salute. Utilizzato nella creazione della configmap `govway-truststore-cm`.

### Truststore Auth INI
```bash
--set truststore.authIni="trustStoreINI.jks"
```
**Descrizione:** Nome del file truststore in formato JKS contenente i certificati delle CA per la validazione dei certificati dei servizi INI (Infrastruttura Nazionale per l'Interoperabilità). Utilizzato nella creazione della configmap `govway-truststore-cm`.

## Note di Utilizzo

- I file keystore e truststore devono essere presenti nel filesystem prima del deployment
- La configmap `govway-truststore-cm` viene creata utilizzando i file truststore specificati
- I parametri AWS (IAM Role, Certificate ARN, Truststore ARN) sono specifici per deployment su infrastruttura AWS
- I formati supportati sono:
  - `.pfx` (PKCS#12) per i keystore
  - `.jks` (Java KeyStore) per i truststore