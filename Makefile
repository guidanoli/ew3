RPC_URL= localhost:8545

.PHONY: deploy
deploy:
	@libexec/deploy.sh --fork-url $(RPC_URL)

.PHONY: request
request: deploy
	@libexec/request.sh --fork-url $(RPC_URL)
