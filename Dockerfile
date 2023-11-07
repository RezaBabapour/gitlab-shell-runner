FROM debian:12.2

RUN apt-get update && apt upgrade -y && apt install procps curl git tini unzip jq -y
RUN curl -L --output /tmp/docker-ce-cli.deb https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/docker-ce-cli_24.0.7-1~debian.11~bullseye_amd64.deb && dpkg -i /tmp/docker-ce-cli.deb
RUN curl -L --output /usr/local/bin/gitlab-runner "https://gitlab-runner-downloads.s3.amazonaws.com/latest/binaries/gitlab-runner-linux-amd64" && chmod +x /usr/local/bin/gitlab-runner
RUN curl -L --output /tmp/docker-ce-compose.deb https://download.docker.com/linux/debian/dists/bullseye/pool/stable/amd64/docker-compose-plugin_2.21.0-1~debian.11~bullseye_amd64.deb && dpkg -i /tmp/docker-ce-compose.deb
RUN curl --location --output /usr/local/bin/release-cli "https://gitlab.com/api/v4/projects/gitlab-org%2Frelease-cli/packages/generic/release-cli/latest/release-cli-linux-amd64" && chmod +x /usr/local/bin/release-cli
RUN curl --location --output /usr/local/bin/download-secure-files "https://gitlab.com/gitlab-org/incubation-engineering/mobile-devops/download-secure-files/-/releases/v0.1.9/downloads/download-secure-files-linux-amd64" && chmod +x /usr/local/bin/download-secure-files
RUN curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 && chmod 700 get_helm.sh && ./get_helm.sh

RUN apt-get install wget gnupg software-properties-common -y
RUN wget -O- https://apt.releases.hashicorp.com/gpg | \
    gpg --dearmor | \
    tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
RUN echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] \
    https://apt.releases.hashicorp.com $(lsb_release -cs) main" | \
    tee /etc/apt/sources.list.d/hashicorp.list

RUN apt-get update && apt-get install terraform=1.5.7-1

RUN apt-get remove wget gnupg software-properties-common -y && apt-get autoremove -y \
    && rm /tmp/docker-ce-cli.deb && rm /tmp/docker-ce-compose.deb && rm -rf /var/lib/apt/lists/* && rm ./get_helm.sh

ENTRYPOINT ["tini", "--"]

CMD ["gitlab-runner", "run", "--working-directory", "/root", "--config", "/etc/gitlab-runner/config.toml", "--user", "root"]

