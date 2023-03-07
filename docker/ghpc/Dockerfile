#
# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

FROM debian:bullseye-slim

ENV SHELL /bin/bash
ENV HOME /workspace

ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=C
ENV LANG=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8

VOLUME /workspace

# user stuff for dev container

RUN apt-get -qq update && apt-get -yqq install \
  sudo \
  jq \
  git \
  curl \
  wget \
  software-properties-common \
  apt-utils \
  build-essential

COPY scripts/* /tmp/
RUN bash /tmp/010-install-hpc-toolkit.sh

WORKDIR $HOME

COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["ghpc"]
