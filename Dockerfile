FROM debian:stable-slim AS build
# Install from package manager.
RUN apt update && \
    apt install -y apt-transport-https ca-certificates curl gpg && \
	curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg && \
	echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list && \
	apt update && apt install -y kubectl

# OR Install with curl.
# RUN apt update && \
#    apt install -y curl && \
#    curl -L "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl" -s -o /usr/bin/kubectl && \
#    chmod +x /usr/bin/kubectl

FROM nginx:mainline-alpine3.18-slim
WORKDIR /root

COPY --from=build /usr/bin/kubectl /usr/bin/kubectl
COPY ./kubeconfig_tmp /root/.kube/config
COPY ./notlens.conf /etc/nginx/conf.d
COPY ./run.sh .
COPY ./index.html .

EXPOSE 8088

CMD [ "./run.sh" ]
