repo := anvil-support

all: login build publish
mac: login build-mac publish

build:
	docker buildx build --load --platform linux/amd64 . -t $(repo)

build-mac:
	docker build . -t $(repo)-mac

login:
	aws ecr get-login-password --region $(AWS_REGION) | \
	docker login --username AWS --password-stdin $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com

publish:
	docker tag $(repo):latest $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/$(repo):latest
	docker push $(AWS_ACCOUNT).dkr.ecr.$(AWS_REGION).amazonaws.com/$(repo):latest