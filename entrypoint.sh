#/bin/bash
set -x
cd ./kolla-master
git pull
. .venv/kolla-builds/bin/activate
pip install -e .

oslo-config-generator --config-file etc/oslo-config-generator/kolla-build.conf
mkdir -p /etc/kolla
mv -v etc/kolla/kolla-build.conf /etc/kolla

echo "Crude cleanup of old images"
docker images | grep ${NAMESPACE}/${BASE}-${TYPE} | grep " ${TAG} " | xargs -l1 docker rmi

echo "Building & pushing kolla images"
echo "*******************************"
kolla-build \
  --push \
  --push-threads=4 \
  --base ${BASE} \
  --type ${TYPE} \
  --namespace ${NAMESPACE} \
  --tag ${TAG}
