.DEFAULT_GOAL := build
build:
	npm run build
	docker build -t js-miniapp-sample:latest -f ./Dockerfile ./../
	docker save --output js-miniapp-sample.tar js-miniapp-sample:latest
	open .

run:
	docker container stop js-miniapp-sample || true && \
		 docker container rm js-miniapp-sample || true
	docker load -i js-miniapp-sample.tar
	docker run -d --name js-miniapp-sample -p 8080:8080 -t js-miniapp-sample:latest

stop:
	docker container stop js-miniapp-sample