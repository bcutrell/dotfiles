# Test image for setup.sh. Pick the base with --build-arg:
#   docker build --build-arg BASE_IMAGE=debian:12 -t dotfiles-test-debian .
#   docker build --build-arg BASE_IMAGE=ubuntu:22.04 -t dotfiles-test-ubuntu .
ARG BASE_IMAGE=debian:12
FROM ${BASE_IMAGE}

ENV DEBIAN_FRONTEND=noninteractive

# Only what a real bare box has before setup.sh runs. Deliberately NO stow:
# setup.sh must work without it.
# Keep the apt index in the image on purpose: the test suite runs setup.sh
# several times per container, and re-fetching the index each time dominates
# the suite's wall clock. Image size does not matter for a throwaway test box.
RUN apt-get update && apt-get install -y --no-install-recommends \
        sudo ca-certificates curl git

RUN useradd -m -s /bin/bash tester \
    && echo "tester ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/tester

USER tester
WORKDIR /home/tester/dotfiles
COPY --chown=tester:tester . .

CMD ["/bin/bash"]
