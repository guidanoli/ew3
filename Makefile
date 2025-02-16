RPC_URL= localhost:8545

.PHONY: deploy
deploy:
	@contracts/deploy.sh --fork-url $(RPC_URL)

.PHONY: request
request: deploy
	@contracts/request.sh --fork-url $(RPC_URL)
