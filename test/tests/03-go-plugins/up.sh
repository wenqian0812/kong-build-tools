
# clone plugins
git clone https://github.com/Kong/go-plugins
pushd go-plugins
  echo "Go builder image: $DOCKER_GO_BUILDER"
  rm -rf go-plugins/*.so

  for src in *.go; do
    echo "compile $src"
    docker run --rm -v $(pwd):/plugins $DOCKER_GO_BUILDER build $src
  done

popd

echo $KONG_TEST_IMAGE_NAME
docker build --build-arg KONG_TEST_IMAGE_NAME=$KONG_TEST_IMAGE_NAME \
  -f Dockerfile.custom_kong -t custom-kong-with-go-plugin .

rm -rf go-plugins

KONG_PLUGINS=go-hello KONG_GO_PLUGINS_DIR=/usr/local/kong start_kong custom-kong-with-go-plugin
wait_kong

