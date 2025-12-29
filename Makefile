DEST=.
SRC_PATH=/root/dist
IMAGE=sync-remote-server:latest
build:
	docker build -t $(IMAGE) .
extract:
	@container=$$(docker create $(IMAGE)); \
	docker cp $$container:$(SRC_PATH) $(DEST); \
	docker rm $$container