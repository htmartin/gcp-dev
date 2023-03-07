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

default: version list

NAMESPACE="markmims"
IMAGE=$(shell basename $(PWD))
VERSION=1.13.0

run_ghpc := docker run --rm -t \
	-v $(CURDIR):/workspace \
	--user $(shell id -u):$(shell id -g) \
	$(NAMESPACE)/ghpc-dev:latest

version: show-version
show-version:
	@echo "--- $@ $(VERSION) ---"

list: list-images
list-images:
	@echo "--- $@ $(IMAGE) ---"
	@docker images | grep $(IMAGE)

build:
	@echo "--- $@ $(IMAGE) ---"
	docker build -t $(IMAGE) .

tag: tag-version tag-latest 
tag-version:
	@echo "--- $@ $(VERSION) ---"
	docker tag $(IMAGE) $(NAMESPACE)/$(IMAGE):$(VERSION)

tag-latest:
	@echo "--- $@ latest---"
	docker tag $(IMAGE) $(NAMESPACE)/$(IMAGE):latest

publish: push
push: push-version push-latest 
push-version: tag-version
	@echo "--- $@ $(NAMESPACE)/$(IMAGE):$(VERSION) ---"
	docker push $(NAMESPACE)/$(IMAGE):$(VERSION)

push-latest: tag-latest
	@echo "--- $@ $(NAMESPACE)/$(IMAGE):latest ---"
	docker push $(NAMESPACE)/$(IMAGE):latest

run:
	@echo "--- $@ $(IMAGE):latest ---"
	docker run -it --rm $(IMAGE):latest

cluster:
	@echo "--- $@ $(IMAGE) ---"
	$(run_ghpc)  build -t $(IMAGE) .

clean-local-images:
	@echo "--- $@ $(IMAGE) ---"
	@echo "should probably make this clean up any local dev images?"

clean: clean-local-images
	@echo "--- $@ $(IMAGE) ---"
	rm -f *.html
	rm -f *.pdf

clobber: clean

