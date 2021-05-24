FROM maven:3.8.1-jdk-11
ENV MAXWELL_VERSION=1.33.0 KAFKA_VERSION=1.0.0

VOLUME ["/root/.m2"]

RUN apt-get update \
    && apt-get -y upgrade \
    && apt-get install -y make

COPY . /workspace

RUN mv /workspace/settings.xml /usr/share/maven/

RUN cp /workspace/pom.xml /tmp && cd /tmp && mvn dependency:resolve

RUN cd /workspace && KAFKA_VERSION=$KAFKA_VERSION make package MAXWELL_VERSION=$MAXWELL_VERSION

RUN mkdir /app && cp -r /workspace/target/maxwell-$MAXWELL_VERSION/maxwell-$MAXWELL_VERSION/* /app/

RUN apt-get clean

RUN rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /workspace/ /root/.m2/

RUN echo "$MAXWELL_VERSION" > /REVISION

WORKDIR /app

CMD [ "/bin/bash", "-c", "bin/maxwell-docker" ]
