auth-service:
	cobc -x auth.cob -lzmq -o auth-service

install: auth-service
	mkdir -p "${out}/bin"
	install auth-service "${out}"/bin/auth-service
