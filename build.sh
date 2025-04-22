#!/bin/bash
VERSION=${1:?Indicare la versione}
cd govway-fse-gtw-image
docker build -t linkitaly/govway-fse-gtw:${VERSION}_run -f Dockerfile.run .
docker build -t linkitaly/govway-fse-gtw:${VERSION}_manager -f Dockerfile.manager .
docker build -t linkitaly/govway-fse-gtw:${VERSION}_batch -f Dockerfile.batch .
cd ..

docker push linkitaly/govway-fse-gtw:${VERSION}_run
docker push linkitaly/govway-fse-gtw:${VERSION}_manager 
docker push linkitaly/govway-fse-gtw:${VERSION}_batch 


sed -r -i -e "s/^version:.*$/version: ${VERSION}/" */Chart.yaml
for chart in govway-fse-gtw-run govway-fse-gtw-manager govway-fse-gtw-batch
do
    helm package $chart --destination govway-fse-gtw-helm --version ${VERSION}
done

helm repo index .


echo 
echo "helm repo add govway-fse https://link-it.github.io/govway-fse-gtw"
echo
echo "helm fecth govway-fse/govway-fse-gtw-run --version ${VERSION}"
echo "helm fecth govway-fse/govway-fse-gtw-manager --version ${VERSION}"
echo "helm fecth govway-fse/govway-fse-gtw-batch --version ${VERSION}"
echo