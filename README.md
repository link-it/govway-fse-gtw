# govway-fse-gtw

Il repository **govway-fse-gtw** contiene i chart Helm relativi ai servizi connessi al **Fascicolo Sanitario Elettronico (FSE)**, in particolare la componente GovWay del **Gateway Distruito**.

## Prerequisiti

Prima di procedere con l'installazione, assicurati di avere:

1. **Cluster Kubernetes** configurato e funzionante.
2. **Helm** installato (versione 3 o superiore).
3. **Oggetti ConfigMap e Secret** necessari creati nel namespace di destinazione.
4. **Postgres DB** su Azure o su AWS, poiché sono essenziali per il corretto funzionamento dei servizi da deployare.

## Aggiungere il Repository Helm

Aggiungi il repository Helm del progetto ed esegui l'aggiornamento:
```bash
helm repo add govway-fse https://link-it.github.io/govway-fse-gtw
helm repo update

helm fetch govway-fse/govway-fse-gtw-run --version ${VERSION}
helm fetch govway-fse/govway-fse-gtw-manager --version ${VERSION}
helm fetch govway-fse/govway-fse-gtw-batch --version ${VERSION}
```

## Installazione di un Chart

Per installare un chart nel cluster Kubernetes:
```bash



helm install <nome-release> govway-fse/<nome-chart> \
  --namespace <namespace> \
  --values <percorso-file-valori>
```

### Configurazione tramite variabili `--set`

In alternativa, è possibile configurare i valori direttamente durante l'installazione utilizzando il parametro `--set`. Esempio:
```bash
helm install <nome-release> govway-fse/<nome-chart> \
  --set cloud.provider=<azure o aws> \
  --set "imagePullSecrets[0].name=<nome-secret>" \
  --set secrets.keyvaultName="<keyvault-name>" \
  --set secrets.tenantId="<tenant-id>" \
  --set secrets.secretKeyVaultName="<secret-keyvault-name>" \
  -n <namespace>
```

Sostituisci i segnaposto `<...>` con i valori appropriati per il tuo ambiente.


Assicurati che tutte le configurazioni nei file `values.yaml` siano aggiornate in base al tuo ambiente di destinazione. In particolare è necessario impostare la variabile **"cloud.provider"** ad uno dei due valori ammissibili **"azure"** o **"aws"**