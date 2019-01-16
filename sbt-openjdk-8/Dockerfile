FROM openjdk:8u181
WORKDIR /app
COPY ./install_deps_sbt-openjdk-8.sh /tmp/
RUN /tmp/install_deps_sbt-openjdk-8.sh && rm -f /tmp/install_deps_sbt-openjdk-8.sh
CMD ["/bin/bash"]
