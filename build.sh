docker build -t athenagroup/webdev:latest --compress --force-rm -f Dockerfile .  && \
[[ $1 == '--push' ]] && docker push athenagroup/webdev:latest