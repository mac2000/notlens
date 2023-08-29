start: build run

# IMAGE_NAME = notlens:$(shell git log --pretty=oneline --abbrev-commit -n 1 | awk '{print $1}')
IMAGE_NAME = notlens:v1

build:
	@echo "building image..."
	# copy kubeconfig to container, pls modify it if your config is not here.
	cp ~/.kube/config ./kubeconfig_tmp
	echo "server {\nlisten 8088;\nlocation / {\nproxy_pass http://127.0.0.1:8001;\n}\n}" > notlens.conf
	echo "#!/usr/bin/env sh\nnohup kubectl proxy -w /root > /dev/null 2>&1 &\nnginx -g 'daemon off;'\n" > ./run.sh
	chmod +x run.sh
	docker build -t $(IMAGE_NAME) .
	rm -fv ./kubeconfig_tmp ./notlens.conf ./run.sh

buildx:
	@echo "build mutil-platform images..."
	cp ~/.kube/config ./kubeconfig_tmp
	echo "server {\nlisten 8088;\nlocation / {\nproxy_pass http://127.0.0.1:8001;\n}\n}" > notlens.conf
	echo "#!/usr/bin/env sh\nnohup kubectl proxy -w /root > /dev/null 2>&1 &\nnginx -g 'daemon off;'\n" > ./run.sh
	chmod +x run.sh
	docker buildx build --platform linux/amd64,linux/arm/v7 -t mac2000/$(IMAGE_NAME) . --push
	rm -fv ./kubeconfig_tmp ./notlens.conf ./run.sh

clean:
	@echo "cleanning..."
	rm -fv ./kubeconfig_tmp ./notlens.conf ./run.sh
	docker rm -f notlens

run:
	@echo "run container..."
	docker run -d -p 8088:8088 --name notlens $(IMAGE_NAME)
