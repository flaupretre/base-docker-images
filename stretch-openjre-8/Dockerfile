FROM debian:stretch-slim
WORKDIR /app
COPY ./install_deps_stretch-openjre-8.sh /tmp/
RUN /tmp/install_deps_stretch-openjre-8.sh && rm -f /tmp/install_deps_stretch-openjre-8.sh
CMD ["/bin/bash"]
