#!/bin/bash

BASE_DIR=$(dirname "$0")

VERSION="3.2.0-1"

sh dolphinscheduler-alert-server/build.sh
sh dolphinscheduler-api/build.sh
sh dolphinscheduler-master/build.sh
sh dolphinscheduler-tools/build.sh
sh dolphinscheduler-worker/build.sh

docker push omygod613/dolphinscheduler-alert-server:${VERSION}
docker push omygod613/dolphinscheduler-api:${VERSION}
docker push omygod613/dolphinscheduler-master:${VERSION}
docker push omygod613/dolphinscheduler-tools:${VERSION}
docker push omygod613/dolphinscheduler-worker:${VERSION}