COMPOSE_FILE:=
all:
	docker-compose build android_srt_example
	docker-compose up -d --force-recreate android_srt_example
	docker exec android_srt_example find /android_srt_example/ -name '*.apk' | while read line ; do \
		docker cp android_srt_example:$$line . ; \
	done
	docker-compose down || true
