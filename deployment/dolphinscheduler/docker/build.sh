#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="3.2.0-2"

docker build -t omygod613/dolphinscheduler-alert-server:${VERSION} $BASE_DIR/dolphinscheduler-alert-server/.
docker build -t omygod613/dolphinscheduler-api:${VERSION} $BASE_DIR/dolphinscheduler-api/.
docker build -t omygod613/dolphinscheduler-master:${VERSION} $BASE_DIR/dolphinscheduler-master/.
docker build -t omygod613/dolphinscheduler-tools:${VERSION} $BASE_DIR/dolphinscheduler-tools/.
docker build -t omygod613/dolphinscheduler-worker:${VERSION} $BASE_DIR/dolphinscheduler-worker/.

# kind load docker-image omygod613/dolphinscheduler-alert-server:${VERSION}
# kind load docker-image omygod613/dolphinscheduler-api:${VERSION}
# kind load docker-image omygod613/dolphinscheduler-master:${VERSION}
# kind load docker-image omygod613/dolphinscheduler-tools:${VERSION}
# kind load docker-image omygod613/dolphinscheduler-worker:${VERSION}

docker push omygod613/dolphinscheduler-alert-server:${VERSION}
docker push omygod613/dolphinscheduler-api:${VERSION}
docker push omygod613/dolphinscheduler-master:${VERSION}
docker push omygod613/dolphinscheduler-tools:${VERSION}
docker push omygod613/dolphinscheduler-worker:${VERSION}