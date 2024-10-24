FROM docker.io/fedora:40

# Installing basic ATOP
RUN dnf -y update && \
      dnf install -y atop && \
      dnf clean all

# Fixing, or forcing the TERM variable to be in xterm-256color.
# This because atop -B won't work without it
RUN echo "export TERM=xterm-256color" >> /etc/profile

# Basiscally running a bash shell. Should be de init system when s6 is implemented
CMD ["/bin/bash"]
