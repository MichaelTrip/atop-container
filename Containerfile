FROM docker.io/fedora:40
RUN dnf -y update && \
      dnf install -y atop && \
      dnf clean all
CMD ["/bin/bash"]
