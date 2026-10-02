# Test image for setup.sh:  docker build --build-arg BASE_IMAGE=ubuntu:22.04 -t dotfiles-test-ubuntu .
ARG BASE_IMAGE=debian:12
FROM ${BASE_IMAGE}
ENV DEBIAN_FRONTEND=noninteractive

# A bare box, deliberately without stow. The apt index is kept: the suite runs setup.sh repeatedly.
RUN apt-get update && apt-get install -y --no-install-recommends sudo ca-certificates curl git
RUN useradd -m -s /bin/bash tester && echo "tester ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/tester

USER tester
WORKDIR /home/tester/dotfiles
COPY --chown=tester:tester . .
CMD ["/bin/bash"]
