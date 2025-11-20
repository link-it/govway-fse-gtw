#!/bin/bash

convert_to_semver() {
  input="$1"

  # Match: MAJOR.MINOR.PATCH.PreReleaseNum (es. 1.2.3.Alfa1)
  if [[ "$input" =~ ^([0-9]+\.[0-9]+\.[0-9]+)\.([A-Za-z]+)([0-9]+)$ ]]; then
    base="${BASH_REMATCH[1]}"
    pre="${BASH_REMATCH[2],,}"   # lowercase
    num="${BASH_REMATCH[3]}"
    echo "${base}-${pre}.${num}"

  # Match: MAJOR.MINOR.PATCH (es. 1.2.3)
  elif [[ "$input" =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    echo "$input"

  else
    echo "Invalid version format: $input" >&2
    return 1
  fi
}

VERSION=${1:?Indicare la versione}
PUBLISH=${2:FALSE}
SEMVER=$(convert_to_semver ${VERSION})

cd govway-fse-gtw-image
docker build -t linkitaly/govway-fse-gtw:${VERSION}_run -f Dockerfile.run .
docker build -t linkitaly/govway-fse-gtw:${VERSION}_manager -f Dockerfile.manager .
docker build -t linkitaly/govway-fse-gtw:${VERSION}_batch -f Dockerfile.batch .
cd ..

 

# La versione del Chart deve essere in semver
sed -r -i -e "s/^version:.*$/version: ${SEMVER}/" */Chart.yaml
sed -r -i -e "s/^appVersion:.*$/appVersion: ${VERSION}/" */Chart.yaml

for chart in govway-fse-gtw-run govway-fse-gtw-manager govway-fse-gtw-batch
do
   helm package $chart --destination govway-fse-gtw-helm --version ${SEMVER}
done

case ${PUBLISH,,} in
si|true|1|yes|y|s)
	helm repo index .
	docker push linkitaly/govway-fse-gtw:${VERSION}_run
	docker push linkitaly/govway-fse-gtw:${VERSION}_manager 
	docker push linkitaly/govway-fse-gtw:${VERSION}_batch 


	echo 
	echo "helm repo add govway-fse https://link-it.github.io/govway-fse-gtw"
	echo
	echo "helm fetch govway-fse/govway-fse-gtw-run --version ${SEMVER}"
	echo "helm fetch govway-fse/govway-fse-gtw-manager --version ${SEMVER}"
	echo "helm fetch govway-fse/govway-fse-gtw-batch --version ${SEMVER}"
	echo
	;;
*)
	echo
	echo "helm chart pronti in govway-fse-gtw-helm/"
	;;
esac
